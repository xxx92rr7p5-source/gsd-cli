export interface QueueEntry {
  project: string;
  mode: string;
  args: string;
  status: 'pending' | 'running' | 'done' | 'failed';
  rawLine: string;
  lineNumber: number;
}

export interface SessionInfo {
  id: string;
  title: string;
  pid?: number;
  startTime: Date;
  lastActivity: Date;
  messageCount: number;
  logPath?: string;
}

export interface ProjectInfo {
  name: string;
  path: string;
  branch: string;
  dirty: boolean;
  hasPlanning: boolean;
  currentPhase?: number;
  totalPhases?: number;
}

export type LifecycleMode = 'build-full' | 'add-and-build' | 'continue' | 'continue-all' | 'build-to-phase' | 'run-command';
