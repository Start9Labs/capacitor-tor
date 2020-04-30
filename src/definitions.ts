import { Observable } from "rxjs";

// @ts-ignore
declare module "@capacitor/core" {
  interface PluginRegistry {
    TorPlugin: TorPlugin;
  }
}

export interface TorPlugin {
  start(opt?: { socksPort: number }): Observable<number>
  stop()   : Promise<void>
  newnym() : Promise<void>
  running(): Promise<{running: boolean}>
}
