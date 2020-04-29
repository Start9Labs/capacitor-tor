import { Observable } from "rxjs";

// @ts-ignore
declare module "@capacitor/core" {
  interface PluginRegistry {
    TorPlugin: TorPlugin;
  }
}

export interface TorPlugin {
  initTor(opt?: { socksPort: number }): Observable<number>;
}
