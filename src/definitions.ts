import { Observable } from "rxjs"

declare module "@capacitor/core" {
  interface PluginRegistry {
    TorPlugin: ITorPlugin
  }
}

export interface ITorPlugin {
  start (options?: StartOptions): Observable<number>
  stop (): Promise<void>
  reconnect (): Promise<void>
  newnym (): Promise<void>
  isRunning (): Promise<boolean>
}

export interface StartOptions {
  socksPort: number
  initTimeout?: number
}