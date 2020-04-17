import { Plugins } from '@capacitor/core'
import { TorClientPlugin } from './definitions'
const { TorClientPlugin : TorNative } = Plugins;

// Provides TS type safety for calling code.
export class TorClient implements TorClientPlugin {
  constructor() {
  }

  initTor(): Promise<void> {
    return TorNative.initTor()
  }
}
// npm run sbuild
// ./rebuild