import { Subject, Observable, of, Subscription } from 'rxjs'
import { delay } from 'rxjs/operators'
import { ITorPlugin } from './definitions'
import { Plugins } from '@capacitor/core'
const { TorPlugin } = Plugins

// Provides TS type safety for calling code.
export class Tor implements ITorPlugin {
  private timeoutSubs: Subscription[] = []
  constructor() {
    console.log(`TIMEOUT SUBS: ${typeof this.timeoutSubs}`)
  }

  start(opt?: { socksPort: number, initTimeout?: number }): Observable<number> {
    const initProgress$ = new Subject<number>()
    const initTimeout = opt && opt.initTimeout

    const timeoutSub = of({}).pipe(delay(initTimeout)).subscribe(() => {
      timeoutSub.unsubscribe()
      initProgress$.error(`Tor failed to boostrap within ${initTimeout} ms.`)
      this.stop()
    })
    console.log(`TIMEOUT SUBS VAL: ${this.timeoutSubs}`)
    this.timeoutSubs.push(timeoutSub)

    const eventListener = TorPlugin.addListener("torInitProgress", info => {
      initProgress$.next(Number(info.progress))
      if(Number(info.progress) >= 100) { 
        timeoutSub.unsubscribe()
        eventListener.remove() 
        initProgress$.complete()
      }
    })

    TorPlugin.start(opt)
    return initProgress$
  }

  stop(): Promise<void> {
    this.timeoutSubs.forEach(sub => sub.unsubscribe())
    this.timeoutSubs = []
    return TorPlugin.stop()
  }

  reconnect(): Promise<void> {
    return TorPlugin.reconnect()
  }

  newnym(): Promise<void> {
    return TorPlugin.newnym()
  }
  
  async isRunning(): Promise<boolean> {
    const res = await TorPlugin.isRunning()
    return res.running
  }
}
