/* tslint:disable */
/* eslint-disable */

export function send_message(content: string): void;

/**
 * Start the chat node and connect to the relay.
 *
 * `on_message(local_peer_id, sender_id, content)` is called for every
 * incoming gossipsub message so the JS side can filter out its own echoes.
 */
export function start_chat(relay_addr: string, on_message: Function): Promise<void>;

export type InitInput = RequestInfo | URL | Response | BufferSource | WebAssembly.Module;

export interface InitOutput {
    readonly memory: WebAssembly.Memory;
    readonly send_message: (a: number, b: number) => [number, number];
    readonly start_chat: (a: number, b: number, c: any) => any;
    readonly wasm_bindgen__closure__destroy__h31beb0e2e51f33de: (a: number, b: number) => void;
    readonly wasm_bindgen__closure__destroy__h8946f70a9155d569: (a: number, b: number) => void;
    readonly wasm_bindgen__closure__destroy__h094bb8395b62df8a: (a: number, b: number) => void;
    readonly wasm_bindgen__convert__closures_____invoke__h0d04c62d3d58ebc5: (a: number, b: number, c: any) => [number, number];
    readonly wasm_bindgen__convert__closures_____invoke__h1ea248246c7ccef9: (a: number, b: number, c: any, d: any) => void;
    readonly wasm_bindgen__convert__closures_____invoke__h10f2cb8dc243d3fd: (a: number, b: number, c: any) => void;
    readonly wasm_bindgen__convert__closures_____invoke__h10f2cb8dc243d3fd_1: (a: number, b: number, c: any) => void;
    readonly wasm_bindgen__convert__closures_____invoke__h10f2cb8dc243d3fd_2: (a: number, b: number, c: any) => void;
    readonly wasm_bindgen__convert__closures_____invoke__h477e73996cf35113: (a: number, b: number) => void;
    readonly __wbindgen_malloc: (a: number, b: number) => number;
    readonly __wbindgen_realloc: (a: number, b: number, c: number, d: number) => number;
    readonly __wbindgen_exn_store: (a: number) => void;
    readonly __externref_table_alloc: () => number;
    readonly __wbindgen_externrefs: WebAssembly.Table;
    readonly __externref_table_dealloc: (a: number) => void;
    readonly __wbindgen_start: () => void;
}

export type SyncInitInput = BufferSource | WebAssembly.Module;

/**
 * Instantiates the given `module`, which can either be bytes or
 * a precompiled `WebAssembly.Module`.
 *
 * @param {{ module: SyncInitInput }} module - Passing `SyncInitInput` directly is deprecated.
 *
 * @returns {InitOutput}
 */
export function initSync(module: { module: SyncInitInput } | SyncInitInput): InitOutput;

/**
 * If `module_or_path` is {RequestInfo} or {URL}, makes a request and
 * for everything else, calls `WebAssembly.instantiate` directly.
 *
 * @param {{ module_or_path: InitInput | Promise<InitInput> }} module_or_path - Passing `InitInput` directly is deprecated.
 *
 * @returns {Promise<InitOutput>}
 */
export default function __wbg_init (module_or_path?: { module_or_path: InitInput | Promise<InitInput> } | InitInput | Promise<InitInput>): Promise<InitOutput>;
