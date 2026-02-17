#!/usr/bin/env bash
# install.sh — install gsd to ~/.local/bin
# Usage: ./install.sh
set -euo pipefail

# Resolve the repo directory (where this script lives)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GSD_SCRIPT="${SCRIPT_DIR}/gsd"
INSTALL_DIR="${HOME}/.local/bin"
INSTALL_TARGET="${INSTALL_DIR}/gsd"

printf 'Installing gsd...\n\n'

# Verify gsd script exists
if [[ ! -f "${GSD_SCRIPT}" ]]; then
  printf 'Error: gsd script not found at %s\n' "${GSD_SCRIPT}" >&2
  exit 1
fi

# §8.8 — ensure gsd is executable
chmod +x "${GSD_SCRIPT}"
printf '  chmod +x %s\n' "${GSD_SCRIPT}"

# §8.2 — create ~/.local/bin/ if it does not exist
if [[ ! -d "${INSTALL_DIR}" ]]; then
  mkdir -p "${INSTALL_DIR}"
  printf '  Created %s\n' "${INSTALL_DIR}"
fi

# §8.1 — create symlink (force-overwrite if already exists)
ln -sf "${GSD_SCRIPT}" "${INSTALL_TARGET}"
printf '  Symlinked: %s → %s\n' "${INSTALL_TARGET}" "${GSD_SCRIPT}"

# §8.4 — verify the symlink works
if ! "${INSTALL_TARGET}" --version &>/dev/null; then
  printf '\nError: symlink created but gsd --version failed\n' >&2
  printf 'Check that the gsd script is valid bash.\n' >&2
  exit 1
fi

printf '\n✓ Installed successfully!\n'
printf '  %s\n\n' "$("${INSTALL_TARGET}" --version)"

# §8.3 — warn if ~/.local/bin is not in PATH
if [[ ":${PATH}:" != *":${INSTALL_DIR}:"* ]]; then
  printf 'Warning: %s is not in your PATH\n\n' "${INSTALL_DIR}"
  printf 'Add to your shell config (~/.bashrc, ~/.zshrc, ~/.profile):\n'
  printf '  export PATH="${HOME}/.local/bin:${PATH}"\n\n'
  printf 'Then reload:\n'
  printf '  source ~/.bashrc   # or ~/.zshrc\n\n'
  printf 'Or for this session only:\n'
  printf '  export PATH="${HOME}/.local/bin:${PATH}"\n\n'
else
  printf 'Run: gsd --help\n'
fi
