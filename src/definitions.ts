// @ts-ignore
declare module "@capacitor/core" {
  interface PluginRegistry {
    TorClientPlugin: TorClientPlugin;
  }
}

export interface TorClientPlugin {
  initTor(): Promise<void>;
}
