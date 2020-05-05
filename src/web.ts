import { Plugins } from '@capacitor/core'
import { TorPlugin } from './definitions'
import { Subject, Observable } from 'rxjs'
const { TorPlugin : TorNative } = Plugins;

// Provides TS type safety for calling code.
export class Tor implements TorPlugin {
  constructor() {}

  start(opt?: { socksPort: number }): Observable<number> {
    const initProgress = new Subject<number>()
    
    const eventListener = TorNative.addListener("torInitProgress", info => {
      initProgress.next(Number(info.progress))
      if(Number(info.progress) >= 100) { 
        eventListener.remove() 
        initProgress.complete()
      }
    })

    TorNative.start(opt)
    return initProgress
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

  networkChange(): Promise<void> {
    const completeionPromise = new Promise<void>((res, rej) => {
      const reconnectListener = TorNative.addListener("torReconnectSucceeded", ({ success }) => {
        reconnectListener.remove()
        if (success) {
          res()
        } else {
          rej("Tor Network Change Handler Failed!")
        }
      })
    })
    TorNative.networkChange()
    return completeionPromise
  }

  newnym(): Promise<void> {
    const completeionPromise = new Promise<void>((res, rej) => {
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
    return completeionPromise
  }
  
  running(): Promise<{running: boolean}> {
    return TorNative.running()
  }
}
