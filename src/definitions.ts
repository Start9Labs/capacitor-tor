// @ts-ignore
declare module "@capacitor/core" {
  interface PluginRegistry {
    TorPlugin: TorPlugin;
  }
}

export interface TorPlugin {
  initTor(): Promise<void>;
  connect(host: string, port: number): Promise<number>;
  send(socketfd: number, buf: string, buflen: number): Promise<number>;
  recv(socketfd: number, maxlen: number): Promise<string>;
  close(socketfd: number): Promise<void>;
}
