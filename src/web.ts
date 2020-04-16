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

  connect(host: string, port: number): Promise<number> {
    return TorNative.connect({ host, port }).then(a => a.socketfd)
  }

  send(socketfd: number, buf: string, buflen: number): Promise<number> {
    return TorNative.send({ socketfd, buf, buflen }).then(a => a.bytessent)
  }

  recv(socketfd: number, maxlen: number): Promise<string> {
    return TorNative.recv({ socketfd, maxlen }).then(a => a.bytes)
  }

  close(socketfd: number): Promise<void> {
    return TorNative.close({ socketfd })
  }


}
// npm run sbuild
// ./rebuild