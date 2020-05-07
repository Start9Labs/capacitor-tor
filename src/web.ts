import { Plugins } from '@capacitor/core'
import { TorPlugin } from './definitions'
import { Subject, Observable, interval } from 'rxjs'
const { TorPlugin : TorNative } = Plugins;

// Provides TS type safety for calling code.
export class Tor implements TorPlugin {
  constructor() {}

  start(opt?: { socksPort: number, initTimeout?: number }): Observable<number> {
    const initProgress$ = new Subject<number>()
    const initTimeout = (opt || {}).initTimeout || 15000

    interval(100).subscribe(i => {
      if(i > initTimeout) {
        initProgress$.error(`Tor failed to boostrap within ${initTimeout} ms.`)
      }
    })

    const eventListener = TorNative.addListener("torInitProgress", info => {
      initProgress$.next(Number(info.progress))
      if(Number(info.progress) >= 100) { 
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
    const completionPromise = new Promise<void>((res, rej) => {
      const reconnectListener = TorNative.addListener("torReconnectSucceeded", ({ success }) => {
        reconnectListener.remove()
        if (success) {
          res()
        } else {
          rej("Tor Reconnection Failed!")
        }
      })
    })
    TorNative.reconnect()
    return completionPromise
  }

  newnym(): Promise<void> {
    const completionPromise = new Promise<void>((res, rej) => {
      const reconnectListener = TorNative.addListener("torReconnectSucceeded", ({ success }) => {
        reconnectListener.remove()
        if (success) {
          res()
        } else {
          rej("Tor Circuit Rebuild Failed!")
        }
      })
    })
    TorNative.newnym()
    return completionPromise
  }
  
  running(): Promise<{running: boolean}> {
    return TorNative.running()
  }
}
