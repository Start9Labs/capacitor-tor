import { Plugins } from '@capacitor/core'
import { TorPlugin } from './definitions'
const { TorPlugin : TorNative } = Plugins;

// Provides TS type safety for calling code.
export class Tor implements TorPlugin {
  constructor() {
  }

  initTor(): Promise<void> {
    return TorNative.initTor()
  }
}
// npm run sbuild
// ./rebuild