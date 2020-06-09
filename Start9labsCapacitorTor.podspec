
  Pod::Spec.new do |s|
    s.name = 'Start9labsCapacitorTor'
    s.version = '0.1.2'
    s.summary = 'run tor process on native ios'
    s.license = 'MIT'
    s.homepage = 'git@github.com:Start9Labs/capacitor-tor.git'
    s.author = 'start9labs'
    s.source = { :git => 'git@github.com:Start9Labs/capacitor-tor.git', :tag => s.version.to_s }
    s.source_files = 'ios/Plugin/**/*.{swift,h,m,c,cc,mm,cpp}'
    s.ios.deployment_target  = '11.0'
    s.dependency 'Capacitor'
    s.dependency 'ReachabilitySwift', '~> 3'
    s.dependency 'BlueSocket'
    s.vendored_frameworks = 'ios/Pods/Tor.framework'
  end
