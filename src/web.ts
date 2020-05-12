import { Plugins } from '@capacitor/core'
import { TorPlugin } from './definitions'
import { Subject, Observable, of } from 'rxjs'
import { delay } from 'rxjs/operators'
const { TorPlugin : TorNative } = Plugins;

// Provides TS type safety for calling code.
export class Tor implements TorPlugin {
  constructor() {}

  start(opt?: { socksPort: number, initTimeout?: number }): Observable<number> {
    const initProgress$ = new Subject<number>()
    const initTimeout = opt && opt.initTimeout

    const timeoutSub = of({}).pipe(delay(initTimeout)).subscribe(() => {
      timeoutSub.unsubscribe()
      initProgress$.error(`Tor failed to boostrap within ${initTimeout} ms.`)
      this.stop()
    })

    const eventListener = TorNative.addListener("torInitProgress", info => {
      initProgress$.next(Number(info.progress))
      if(Number(info.progress) >= 100) { 
        timeoutSub.unsubscribe()
        eventListener.remove() 
        initProgress$.complete()
      }
    })

    TorNative.start(opt)
    return initProgress$
  }

  stop(): Promise<void> {
    return TorNative.stop()
  }

  reconnect(): Promise<void> {
    return TorNative.reconnect()
  }

  newnym(): Promise<void> {
    return TorNative.newnym()
  }
  
  async isRunning(): Promise<boolean> {
    const res = await TorNative.isRunning()
    return res.running
  }
}
