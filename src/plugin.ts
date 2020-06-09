/*
Copyright (c) 2020 Start9 Labs, LLC

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
import { Subject, Observable, of, Subscription } from 'rxjs'
import { delay } from 'rxjs/operators'
import { Plugins } from '@capacitor/core'
import { ITorPlugin } from './definitions'
const TorPlugin = Plugins['TorPlugin'] as ITorPlugin

// Provides TS type safety for calling code.
export class Tor {
  private timeoutSubs: Subscription[] = []
  constructor() {
    console.log(`TIMEOUT SUBS: ${typeof this.timeoutSubs}`)
  }

  start(opt?: { socksPort: number, controlPort: number, initTimeout?: number }): Observable<number> {
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
      if (Number(info.progress) >= 100) {
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
