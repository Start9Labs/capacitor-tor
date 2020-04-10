import { Plugins } from '@capacitor/core'
import { TorClientPlugin, HttpRequest, JSON_ } from './definitions'
const { TorClientPlugin : TorNative } = Plugins;

// Provides TS type safety for calling code.
export class TorClient implements TorClientPlugin {
  constructor() {
  }

  initTor(): Promise<void> {
    return TorNative.initTor()
  }

  sendReq (req: HttpRequest): Promise<JSON_> {    
    if(!req.path.startsWith('/')) req.path = '/' + req.path
    return TorNative.sendReq(req)
  }
}