import { Observable } from "rxjs"
import { PluginListenerHandle } from "@capacitor/core"

declare module "@capacitor/core" {
  interface PluginRegistry {
    TorPlugin: ITorPlugin
  }
}

export interface ITorPlugin {
  start(options?: StartOptions): Observable<number>
  stop(): Promise<void>
  reconnect(): Promise<void>
  newnym(): Promise<void>
  isRunning(): Promise<{ running: boolean }>
  addListener(eventName: string, listenerFunc: Function): PluginListenerHandle
}

export interface StartOptions {
  socksPort: number
  controlPort: number
  initTimeout?: number
}