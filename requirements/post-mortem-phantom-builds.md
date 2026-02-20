# Post-Mortem: Phantom Build Completions

**Date:** 2026-02-20
**Affected entries:**
- `gsd-cli | build-full | per requirements/typescript-migration.md` → falsely marked ✅ DONE
- `gsd-cli | build-full | per requirements/tui-dashboard.md` → falsely marked ✅ DONE

## Root Cause

**`build-full` ignores the description/requirements file entirely.** It only checks existing ROADMAP.md phases and their completion state. The "per requirements/typescript-migration.md" part of the queue entry is decorative text — the code never reads it.

### The Exact Code Path

```
lifecycle_build_full("gsd-cli", "per requirements/typescript-migration.md")
  ├── .planning/ exists? YES → skip new-project (line 399)
  └── loop: find_next_phase("~/dev/punchlab/gsd-cli")
        ├── get_all_phases() → parses ROADMAP.md → finds phases 1, 2, 3, 4
        ├── Phase 1: get_phase_state() → finds 01-UAT.md, 0 fails → "done"
        ├── Phase 2: get_phase_state() → finds 02-UAT.md, 0 fails → "done"
        ├── Phase 3: get_phase_state() → finds 03-UAT.md, 0 fails → "done"
        ├── Phase 4: get_phase_state() → phase dir exists but empty → "needs-plan"
        │   └── run_phase_cycle() → run_gsd("plan-phase", "4 --auto")
        │       └── opencode runs, creates plan for phase 4
        │       └── (continues execute, verify...)
        └── OR: Phase 3 already had UAT, Phase 4 had no plan files
            └── Phases 1-3 returned "done", Phase 3's run_gsd verify call
                produced the 03-UAT.md during THIS run
```

Wait — let me be more precise. The logs show:

```
11:47:15 | build-full — starting Phase 1
11:51:25 | build-full — starting Phase 2  
11:57:15 | build-full — starting Phase 3
12:01:04 | build-full — all phases complete!
```

**It ran phases 1-3 through `run_phase_cycle`**, which means `get_phase_state` returned something other than "done" for each. Looking at the timing (~4 min per phase), it likely ran `verify-auto` on each phase (they had plan files and git commits but no UAT files yet). After creating UAT files for all 3 phases, `find_next_phase` found Phase 4 but its state was... actually, let me check.

Phase 4's directory exists (`04-typescript-rewrite-with-queue-runner-per-requirements-queue-runner-migration-md/`) but is empty. `get_phase_state` would return `"needs-plan"`. But the logs say "all phases complete" after Phase 3, meaning **Phase 4 was NOT iterated**.

**Key insight:** `get_all_phases()` uses:
```bash
grep -oP '(?<=Phase )\d+' "$dir/.planning/ROADMAP.md" | sort -un
```

Looking at ROADMAP.md's Phase 4 header:
```
## Phase 4: TypeScript rewrite with queue runner per requirements/queue-runner-migration.md
```

This contains "Phase 4" so it IS captured. But `find_next_phase` iterated 1-3, found them "done" after verify ran, then hit Phase 4... and Phase 4's directory exists with an empty listing. `get_phase_state` for phase 4:
- `padded = "04"`
- `phase_dir = .planning/phases/04-typescript-rewrite-...` (exists)
- No UAT file
- `plan_files = 0` (empty dir)
- Returns `"needs-plan"`

So it should have tried to plan Phase 4. But the log says "all phases complete" right after Phase 3. 

**Revised theory:** The run_phase_cycle for Phase 3 created the UAT, then the loop called `find_next_phase` again, found Phase 4 with state "needs-plan", called `run_phase_cycle("gsd-cli", "4")`, which ran `plan-phase 4 --auto`. But `run_gsd` **detected no new commits and no .planning changes** (the plan might have failed silently or produced nothing), exhausted retries, and returned failure... 

Actually no — looking more carefully at `run_phase_cycle`, it loops checking state. If `run_gsd` returns failure (non-zero), `run_phase_cycle` returns 1, and `lifecycle_build_full` would also return 1 (failure), not "all phases complete".

**Most likely explanation:** Phase 4 existed in ROADMAP but `get_all_phases` only found `1 2 3` because the grep pattern `(?<=Phase )\d+` matches the FIRST occurrence of "Phase N" per line. Let me check: ROADMAP has `## Phase 4:` which would match `4`. So it should find it.

**BUT WAIT** — the log timestamps show phases ran from 11:47 to 12:01 (14 minutes). Each phase took ~4 min — consistent with running verify-auto (which spawns opencode). If Phase 4 was attempted and failed, we'd see a failure log, not "all phases complete".

The only way to get "all phases complete" is if `find_next_phase` returns empty. This means either:
1. Phase 4 was not in `get_all_phases` output, OR
2. Phase 4's state was "done"

Since the Phase 4 directory is empty (no UAT), option 2 is impossible. So **Phase 4 must not have been detected by `get_all_phases`**.

Let me re-examine: ROADMAP.md Phase 4 header is:
```
## Phase 4: TypeScript rewrite with queue runner per requirements/queue-runner-migration.md
```

The grep `(?<=Phase )\d+` matches digits after "Phase ". This should match `4`. Unless the ROADMAP at the time of the run was different (Phase 4 was added by `add-phase` which ran at 12:01:04 and failed).

**ACTUALLY — checking STATE.md:** It says "Phase: 3 of 4" and shows Phase 4 as "🆕 Not planned". And ROADMAP.md shows Phase 4 was added. But when was it added? The `add-phase` for tui-dashboard ran at 12:01:04 and FAILED. The Phase 4 in ROADMAP (`TypeScript rewrite with queue runner`) could have been added by a previous queue entry.

**Regardless, the fundamental bug is clear:**

## The Bug: `build-full` Doesn't Connect Requirements to Work

`lifecycle_build_full()` (line 394-413) does this:
1. If no `.planning/`, run `new-project` with the description
2. Loop through existing ROADMAP phases until all are "done"

**The description ("per requirements/typescript-migration.md") is ONLY used in step 1** — passed to `new-project`. If `.planning/` already exists (as it does for gsd-cli with 3 completed phases), the description is **completely ignored**.

The function never:
- Reads the requirements file
- Checks if the requirements are reflected in ROADMAP.md
- Adds new phases for unmet requirements
- Compares what the queue entry asked for vs what the ROADMAP contains

It simply drives all existing phases to completion and declares victory.

## Why It Happened Twice

1. **typescript-migration:** `build-full` found `.planning/` exists, iterated phases 1-3, verified them (they were already built), found no more incomplete phases, declared "all phases complete!" — never looked at typescript-migration.md.

2. **tui-dashboard:** Same pattern. After the first phantom completion, Phase 4 may or may not have existed in ROADMAP. Either way, `build-full` iterated all phases, found them done (including any that had just been verified), declared complete.

The second entry (`tui-dashboard`) was even faster — 12:46:41 start and 12:46:41 complete (< 1 second!) — because by then ALL phases including any Phase 4 had UAT files or the only phases (1-3) were all "done". Zero work, instant "success".

## What Should Have Happened

`build-full` with `per requirements/typescript-migration.md` should have:
1. Detected that `typescript-migration.md` describes work not in the current ROADMAP
2. Run `add-phase` with those requirements first
3. Then built the new phase(s)

## Recommended Fixes

### Fix 1: `build-full` should process the description for requirements (Preferred)

```bash
lifecycle_build_full() {
  local project="$1" description="$2"
  local dir="$PUNCHLAB/$project"
  
  # If no .planning exists, run new-project
  if [ ! -d "$dir/.planning" ]; then
    log "🆕 [$project] build-full — creating project"
    run_gsd "$project" "new-project" "--auto $description" || return 1
  else
    # .planning exists — check if description references a requirements file
    # that isn't reflected in ROADMAP yet
    local req_file=""
    if [[ "$description" =~ per[[:space:]]+(requirements/[^[:space:]]+) ]]; then
      req_file="${BASH_REMATCH[1]}"
    fi
    
    if [ -n "$req_file" ] && [ -f "$dir/$req_file" ]; then
      # Extract the requirement title/goal and check if ROADMAP covers it
      local req_title
      req_title=$(head -1 "$dir/$req_file" | sed 's/^#\+\s*//')
      
      # Simple heuristic: check if any phase in ROADMAP references this requirement
      if ! grep -qi "$req_file" "$dir/.planning/ROADMAP.md" 2>/dev/null; then
        log "📝 [$project] build-full — requirements not in ROADMAP, adding phase"
        run_gsd "$project" "add-phase" "$description" || return 1
      fi
    fi
  fi
  
  # Loop through all phases
  while true; do
    local next_phase
    next_phase=$(find_next_phase "$dir")
    if [ -z "$next_phase" ]; then
      log "🎉 [$project] build-full — all phases complete!"
      return 0
    fi
    log "📋 [$project] build-full — starting Phase $next_phase"
    run_phase_cycle "$project" "$next_phase" || return 1
  done
}
```

### Fix 2: Use `add-and-build` instead of `build-full` for new requirements

The correct queue entry format for adding NEW work to an EXISTING project should have been:

```
gsd-cli | add-and-build | per requirements/typescript-migration.md
```

`lifecycle_add_and_build()` correctly runs `add-phase` first, which reads the description, creates a new phase in ROADMAP, then builds it.

**`build-full` = "build everything that's already planned"**
**`add-and-build` = "add new work, then build it"**

The queue entries used the wrong mode.

### Fix 3: Add a safety check — warn if build-full does zero new work

```bash
# In lifecycle_build_full, after the loop:
if [ "$phases_actually_built" -eq 0 ]; then
  log "⚠️ [$project] build-full — WARNING: all phases were already done, no new work performed"
  log "  → Did you mean 'add-and-build' for new requirements?"
  # Optionally return 1 to flag this as suspicious
fi
```

## Lessons Learned

1. **`build-full` ≠ "build this requirement fully"** — it means "drive all EXISTING phases to completion". The name is misleading when paired with a requirements file reference.

2. **Queue entry descriptions are cosmetic** — `build-full` only uses the description for `new-project`. For existing projects, it's ignored. The description should match what the mode actually does.

3. **Correct mode selection:**
   | Scenario | Correct Mode |
   |----------|-------------|
   | Brand new project | `build-full` with requirements |
   | New feature on existing project | `add-and-build` |
   | Continue stalled project | `build-full` or `continue` |
   | Build specific phase | `build-to-phase N` |

4. **The `add-phase` skip logic is also buggy** (line 262-267): it checks if the FIRST keyword of the description exists in ROADMAP.md. For `per requirements/typescript-migration.md`, the first keyword is `per` — which could match anything. This skip logic prevented the `add-phase` for tui-dashboard from working.

5. **Instant completions are a red flag** — any `build-full` that completes in < 1 second did zero work and should be flagged/failed.
