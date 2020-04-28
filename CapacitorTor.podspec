
  Pod::Spec.new do |s|
    s.name = 'CapacitorTor'
    s.version = '0.0.3'
    s.summary = 'tor'
    s.license = 'MIT'
    s.homepage = 'git@github.com:Start9Labs/capacitor-tor.git'
    s.author = 'AGSpan'
    s.source = { :git => 'git@github.com:Start9Labs/capacitor-tor.git', :tag => s.version.to_s }
    s.source_files = 'ios/Plugin/**/*.{swift,h,m,c,cc,mm,cpp}'
    s.ios.deployment_target  = '11.0'
    s.dependency 'Capacitor'
    s.dependency 'ReachabilitySwift', '~> 3'
    s.dependency 'BlueSocket'
    s.vendored_frameworks = 'ios/Pods/Tor.framework'
  end