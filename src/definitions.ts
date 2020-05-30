import { Observable } from "rxjs";
import { PluginListenerHandle } from '@capacitor/core'

// @ts-ignore
declare module "@capacitor/core" {
  interface PluginRegistry {
    TorPlugin: TorNative;
  }
}

export interface TorPlugin {
  start(opt?: { socksPort: number, initTimeout?: number }): Observable<number>
  stop()   : Promise<void>
  reconnect(): Promise<void>
  newnym() : Promise<void>
  isRunning(): Promise<boolean>
}

export interface TorNative extends Plugin {
  start(opt?: { socksPort: number, initTimeout?: number }): Observable<number>
  stop()   : Promise<void>
  reconnect(): Promise<void>
  newnym() : Promise<void>
  isRunning(): Promise<{ running: boolean }>
}
export interface Plugin {
  addListener(eventName: string, listenerFunc: Function): PluginListenerHandle;
}