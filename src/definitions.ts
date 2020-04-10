// @ts-ignore
declare module "@capacitor/core" {
  interface PluginRegistry {
    TorClientPlugin: TorClientPlugin;
  }
}

export type JSON_ = undefined |
                    null      |
                    string    |
                    number    |
                    JSON_[]   |
                    { [key: string]: JSON_ }

// const sample0: JSON_ = 3
// const sample1: JSON_ = 'hey'
// const sample2: JSON_ = undefined
// const sample3: JSON_ = null
// const sample4: JSON_ = [sample0, sample1, sample2]
// const sample5: JSON_ = {"someKey0": sample0, "someKey1": sample1, "someKey2": sample2}

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
  sendReq(req: HttpRequest): Promise<JSON_>;
}
