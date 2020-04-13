// @ts-ignore
declare module "@capacitor/core" {
  interface PluginRegistry {
    TorClientPlugin: TorClientPlugin;
  }
}

export interface TorClientPlugin {
  initTor(): Promise<void>;
  connect(): Promise<number>;
  send(socketfd: number, buf: string, buflen: number): Promise<number>;
  recv(socketfd: number, maxlen: number): Promise<string>;
  close(socketfd: number): Promise<void>;
}
