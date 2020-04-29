// @ts-ignore
declare module "@capacitor/core" {
  interface PluginRegistry {
    TorPlugin: TorPlugin;
  }
}

export interface TorPlugin {
  initTor(opt?: { socksPort: number }): Promise<void>;
}
