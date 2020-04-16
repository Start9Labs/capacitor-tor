# capacitor-tor
A plugin capable of starting (and stopping) an instance of tor on your mobile device. This includes spinning up a SOCK5H proxy server which can proxy http requests through the tor network (including targeting V3 onion urls).

WIP

To install into your ionic project: 
```
$ npm i --save capacitor-tor
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
import tor.plugin.TorPlugin;

public class MainActivity extends BridgeActivity {
  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    // Initializes the Bridge
    this.init(savedInstanceState, new ArrayList<Class<? extends Plugin>>() {{
      // Additional plugins you've installed go here
       add(TorPlugin.class);
    }});
  }
}

```

Sample use in an ionic app:

```
import { Component } from '@angular/core';
import { Tor, HttpVerb, JSON_ } from 'capacitor-tor';
@Component({
  selector: 'app-tab1',
  templateUrl: 'tab1.page.html',
  styleUrls: ['tab1.page.scss']
})
export class Tab1Page {
  private readonly tor = new Tor();

  constructor() {
  }

  async ngOnInit() {
    console.log('Initializing Tor Daemon.');
    await this.tor.initTor();
    console.log(`Tor Daemon initialized.`);
  }
}
```

We use the javascript capacitor plugin import syntax `import { Tor } from 'capacitor-tor';` to get typescript type safety in the Ionic code. 
