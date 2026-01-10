// $PAI_DIR/hooks/lib/observability.ts
// Shared utilities for hooks - logging and event sending

export function getSourceApp(): string {
  return process.env.PAI_SOURCE_APP || process.env.DA || 'PAI';
}

export function getCurrentTimestamp(): string {
  return new Date().toISOString();
}

interface ObservabilityEvent {
  source_app: string;
  session_id: string;
  hook_event_type: string;
  timestamp: string;
  [key: string]: any;
}

// Stub for observability - can be extended to send to a server
export async function sendEventToObservability(event: ObservabilityEvent): Promise<void> {
  // Log locally for now - could be extended to send to observability server
  if (process.env.PAI_DEBUG) {
    console.error(`[Observability] ${event.hook_event_type}: ${JSON.stringify(event, null, 2)}`);
  }
}
