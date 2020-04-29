import { Plugins } from '@capacitor/core'
import { TorPlugin } from './definitions'
import { Subject } from 'rxjs'
const { TorPlugin : TorNative } = Plugins;

// Provides TS type safety for calling code.
export class Tor implements TorPlugin {
  constructor() {}

  // Plugins.TorPlugin.addListener("torInitProgress", info => {
  //   console.log(`Initted Tor logs: ${JSON.stringify(info)}`)
  // })
  // await this.tor.initProgress.subscribe((info) => {

  // })

  initProgress: Subject<number> = new Subject()
  eventListener: any

  initTor(opt?: { socksPort: number }): Promise<void> {
    const eventListener = TorNative.addListener("torInitProgress", info => {
      this.initProgress.next(info.progress)
      if(Number(info.progress) >= 100) { 
        eventListener.remove() 
        this.initProgress.complete()
      }
    })
    return TorNative.initTor(opt)
  }
}
