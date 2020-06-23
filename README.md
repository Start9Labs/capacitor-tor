# capacitor-tor
capacitor-tor, also known internally as "captor" is an [Ionic/Capacitor](https://capacitor.ionicframework.com/) plugin
for managing the [Tor](https://www.torproject.org/) daemon on mobile platforms in a hybrid mobile application. This
ultimately makes it possible to communicate over tor as a transport layer for your mobile app's communications.

## What this plugin does
This plugin allows you to start, stop, reconnect, and change tor circuits. Since Tor is not a core operating system feature
like a TCP/IP stack, a mobile app that depends on tor functionality must have a way to access it in another app (which 
is not feasible on iOS), or it must bring its own Tor functionality with it. This plugin gives you a fairly easy way to
"bring your own tor daemon" into a mobile app.

## What this plugin does *not* do
This plugin is not an HTTP library, nor any kind of networking library for that matter. It's only job is to manage the
Tor [SOCKS5](https://en.wikipedia.org/wiki/SOCKS) proxy that networking applications can route its traffic through. As
such, in order to use an arbitrary networking protocol with this plugin, it is necessary that the code you have written
or pulled in that has SOCKS5 support.

It does not matter whether the code that negotiates a socks5 connection is written in a hybrid (JS/TS) or native environment.
Since the SOCSK5 protocol is entirely network driven, as long as you can talk to the port that is listening for SOCKS
connections, you can make use of it.

## Installation

To install into your ionic project:

```bash
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

As with other capacitor Plugins, you will have to specifically register the plugin in your activity with the java side.

```java
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

## Usage

Sample use in an ionic app:

```typescript
import { Component } from '@angular/core';
import { Tor } from 'capacitor-tor';
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
    /* Start tor socks listener on socksPort (9250).
       If tor takes longer than initTimeout (15000) to start and bootstrap fully,
       the returned observable will error out. If initTimeout is omitted, tor
       will attempt to connect forever and the observable will never error out.
    */
    this.tor.start({socksPort: 9250, controlPort: 9251, initTimeout: 15000}).subscribe({
       next: progressPercentage => this.handleConnecting(progressPercentage),
       error: whatHappened => { throw new Error('Tor subscription blew up: ' + whatHappened) }
    })
    console.log(`Tor Daemon initialized.`);
  }
  ...
}
```

## State of the Project

We have been using this in production at Start9 Labs since May 2020, but that does not mean it is without its quirks.
The tor binaries themselves are still maturing for use in this kind of an environment, and the internals are still
quite rough around the edges. We currently use this in Ionic applications for iOS and Android. If you are trying to use
it in a project that exceeds that scope (Electron, React Native), you should expect to do some trailblazing.

## Contributions

Contributions are welcome. This project is very much in the spirit of FOSS. If you want to submit PR's to the code or
documentation, please feel free to do so. If you want to get in contact with us about this project, please email
keagan@start9labs.com or aaron@start9labs.com
