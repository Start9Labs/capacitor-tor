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

  connect(): Promise<number> {
    return TorNative.connect()
  }

  send(socketfd: number, buf: string, buflen: number): Promise<number> {
    return TorNative.send(socketfd, buf, buflen)
  }

  recv(socketfd: number, maxlen: number): Promise<string> {
    return TorNative.send(socketfd, maxlen)
  }

  close(socketfd: number): Promise<void> {
    return TorNative.connect(socketfd)
  }


}
// npm run sbuild
// ./rebuild