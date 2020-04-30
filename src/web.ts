import { Plugins } from '@capacitor/core'
import { TorPlugin } from './definitions'
import { Subject, Observable } from 'rxjs'
const { TorPlugin : TorNative } = Plugins;

// Provides TS type safety for calling code.
export class Tor implements TorPlugin {
  constructor() {}

  initTor(opt?: { socksPort: number }): Observable<number> {
    const initProgress = new Subject<number>()
    
    const eventListener = TorNative.addListener("torInitProgress", info => {
      initProgress.next(info.progress)
      if(Number(info.progress) >= 100) { 
        eventListener.remove() 
        initProgress.complete()
      }
    })

    TorNative.initTor(opt)
    return initProgress
  }

  stop(): Promise<void> {
    return TorNative.stop()
  }

  newnym(): Promise<void> {
    return TorNative.newnym()
  }
}
