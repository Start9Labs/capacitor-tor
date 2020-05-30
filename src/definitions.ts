import { Observable } from "rxjs"

// @ts-ignore
declare module "@capacitor/core" {
  interface PluginRegistry {
    TorPlugin: TorPluginContract;
  }
}

export interface TorPluginContract {
  start(opt?: { socksPort: number, initTimeout?: number }): Observable<number>
  stop()   : Promise<void>
  reconnect(): Promise<void>
  newnym() : Promise<void>
  isRunning(): Promise<boolean>
}