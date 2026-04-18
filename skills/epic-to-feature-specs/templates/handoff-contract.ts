/**
 * Handoff Contract — {feature area}
 *
 * Canonical source for the FE ↔ BE boundary for {feature area}.
 * Both teams import from this file (or its generated equivalent).
 *
 * Amendment policy: changes to this file require a co-reviewed PR with
 * sign-off from each team that consumes this contract.
 *
 * Rule: this contract is deliberately coarser than BE internal state.
 * If BE has internal stages (e.g. uploading-chunk-3, whisper-running,
 * structuring-retrying), collapse them to the FE-visible states here.
 * Leaking internal states into the contract couples the teams and
 * defeats the seam.
 */

// =============================================================================
// Types — discriminated unions force exhaustive handling at the call site
// =============================================================================

/**
 * The state machine for a single {entity} from the presentation layer's view.
 *
 * Every state carries the minimum data the presentation layer needs to
 * render without calling back to BE. If you find yourself adding a field
 * that only one state uses, it belongs in that variant, not on the union.
 */
export type EntityStatus =
  | { kind: 'idle' }
  | { kind: 'queued'; queuedAt: Date; offline: boolean }
  | { kind: 'inProgress'; progress?: number /* 0..1 */ }
  | { kind: 'complete'; resultId: string }
  | {
      kind: 'failed';
      errorCode: ErrorCode;
      retriable: boolean;
      attempt: number;
      nextRetryAt?: Date;
    };

/**
 * Enumerate failure modes the presentation layer is expected to render
 * differently. Unknown/unexpected errors collapse to 'unknown'.
 */
export type ErrorCode =
  | 'network'
  | 'serverUnavailable'
  | 'quotaExceeded'
  | 'invalidInput'
  | 'unknown';

// =============================================================================
// Mutations — presentation layer calls these
// =============================================================================

/**
 * Trigger processing for one or more entities.
 * Returns once the BE has accepted the request (not once processing completes).
 * Errors surface via EntityStatus on subsequent reads, not as rejected promises.
 */
export interface TriggerProcessingMutation {
  (entityIds: string[]): Promise<void>;
}

/**
 * Manually retry a failed entity.
 * No-op if the entity is not in the 'failed' state.
 */
export interface RetryProcessingMutation {
  (entityId: string): Promise<void>;
}

/**
 * Cancel a queued or in-progress entity. No-op if already terminal.
 */
export interface CancelProcessingMutation {
  (entityId: string): Promise<void>;
}

// =============================================================================
// Selectors — presentation layer reads these
// =============================================================================

/**
 * Subscribe to a single entity's status. Re-renders on transitions.
 */
export interface UseEntityStatusHook {
  (entityId: string): EntityStatus;
}

/**
 * Aggregate counts across the queue. Useful for header badges.
 */
export interface UseQueueStatsHook {
  (): {
    queued: number;
    inProgress: number;
    failed: number;
    lastUpdatedAt: Date;
  };
}

/**
 * Whether the client currently believes it has connectivity.
 * Used by the presentation layer to show offline indicators.
 */
export interface UseOnlineStatusHook {
  (): { online: boolean; lastOnlineAt?: Date };
}

// =============================================================================
// Events — optional subscription model
// =============================================================================

/**
 * Event names and payload shapes the presentation layer MAY subscribe to.
 * Prefer the selectors above for render-driving state; use events for
 * one-shot side effects (e.g. "show a toast when an item completes").
 */
export type ContractEvent =
  | { name: 'processing.completed'; payload: { entityId: string; resultId: string } }
  | { name: 'processing.failed'; payload: { entityId: string; errorCode: ErrorCode } }
  | { name: 'processing.retrying'; payload: { entityId: string; attempt: number } };

/**
 * Subscribe to contract events. Implementation returns an unsubscribe fn.
 */
export interface SubscribeEvents {
  <T extends ContractEvent['name']>(
    eventName: T,
    handler: (payload: Extract<ContractEvent, { name: T }>['payload']) => void,
  ): () => void;
}

// =============================================================================
// Aggregate surface — the single object the presentation layer imports
// =============================================================================

/**
 * The complete surface the presentation layer sees. BE implements this
 * behind the scenes (store + hooks + network). FE tests mock this entire
 * interface for independent development.
 */
export interface FeatureContract {
  // Mutations
  triggerProcessing: TriggerProcessingMutation;
  retryProcessing: RetryProcessingMutation;
  cancelProcessing: CancelProcessingMutation;

  // Selectors / Hooks
  useEntityStatus: UseEntityStatusHook;
  useQueueStats: UseQueueStatsHook;
  useOnlineStatus: UseOnlineStatusHook;

  // Events
  subscribe: SubscribeEvents;
}
