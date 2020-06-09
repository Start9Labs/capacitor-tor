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
import { Observable } from "rxjs"
import { PluginListenerHandle } from "@capacitor/core"

declare module "@capacitor/core" {
  interface PluginRegistry {
    TorPlugin: ITorPlugin
  }
}

export interface ITorPlugin {
  start(options?: StartOptions): Observable<number>
  stop(): Promise<void>
  reconnect(): Promise<void>
  newnym(): Promise<void>
  isRunning(): Promise<{ running: boolean }>
  addListener(eventName: string, listenerFunc: Function): PluginListenerHandle
}

export interface StartOptions {
  socksPort: number
  controlPort: number
  initTimeout?: number
}