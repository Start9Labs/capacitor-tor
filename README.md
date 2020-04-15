# capacitor-tor-client
A client capable of making JSON api requests over the Tor network for IOS and Android. *Web is not yet supported.*

WIP (only GET requests, no https)

To install into your ionic project: 
```
$ npm i --save capacitor-tor-client
$ npx cap update

... add module into the typescript how you like ...

$ ionic build
$ npx cap sync
$ npx cap open ios && npx cap open android
```

You MUST also add the following lines to the `build.gradle` within your `android` folder:
1. In the 'dependencies:{ ... }' section include this line: `implementation 'org.torproject:tor-android-binary:0.4.2.5'`
1. In the 'repositories:{ ... }' section include this line: `maven { url "https://raw.githubusercontent.com/guardianproject/gpmaven/master" }`
as well as edit your android 'android/app/src/main/java/.../MainActivity.java'

```
...
import tor.client.plugin.TorClientPlugin;

public class MainActivity extends BridgeActivity {
  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    // Initializes the Bridge
    this.init(savedInstanceState, new ArrayList<Class<? extends Plugin>>() {{
      // Additional plugins you've installed go here
       add(TorClientPlugin.class);
    }});
  }
}

```

Sample use in an ionic app:

```
import { Component } from '@angular/core';
import { TorClient, HttpVerb, JSON_ } from 'capacitor-tor-client';
@Component({
  selector: 'app-tab1',
  templateUrl: 'tab1.page.html',
  styleUrls: ['tab1.page.scss']
})
export class Tab1Page {
  private readonly torClient = new TorClient();

  torReply: JSON_;

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

We use the javascript capacitor plugin import syntax `import { TorClient, HttpVerb } from 'capacitor-tor-client';` to get typescript type safety in the Ionic code. 
