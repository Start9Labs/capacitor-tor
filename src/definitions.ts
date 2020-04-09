// @ts-ignore
declare module "@capacitor/core" {
  interface PluginRegistry {
    TorClientPlugin: TorClientPlugin;
  }
}

export enum HttpVerb {
  GET="GET", 
  POST="POST", 
  PUT="PUT", 
  PATCH="PATCH", 
  DELETE="DELETE"
}

export interface HttpRequest {
  host: string
  path: string
  port: number
  verb: HttpVerb
  data?: Object
}

export interface TorClientPlugin {
  initTor(): Promise<void>;
  sendReq(req: HttpRequest): Promise<any>;
}
