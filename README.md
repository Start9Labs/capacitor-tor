# capacitor-tor-client
A client capable of making requests over the Tor network for IOS and Android. *Web is not yet supported.*

Sample use in an ionic app:

```
import { Component } from '@angular/core';
import { TorClient, HttpVerb } from 'tor-client-plugin';
@Component({
  selector: 'app-tab1',
  templateUrl: 'tab1.page.html',
  styleUrls: ['tab1.page.scss']
})
export class Tab1Page {
  private readonly torClient = new TorClient();

  torReply: object;

  constructor() {
  }

  async ngOnInit() {
    console.log('Initializing Tor Daemon.');
    await this.torClient.initTor();
    console.log(`Tor Daemon initialized.`);
  }

  async testTorClient() {
    this.torReply = await this.torClient.sendReq({
      verb: HttpVerb.GET,
      host: '<your-favorite-hidden-service>.onion',
      port: 80,
      path: '/'
    });
  }
}
```

We use the javascript capacitor plugin import syntax `import { TorClient, HttpVerb } from 'tor-client-plugin';` to get typescript type safety in the Ionic code. 
