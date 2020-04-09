
  Pod::Spec.new do |s|
    s.name = 'TorClientPlugin'
    s.version = '0.0.1'
    s.summary = 'tor client'
    s.license = 'MIT'
    s.homepage = 'git@github.com:Start9Labs/capaciTor1.git'
    s.author = 'AGSpan'
    s.source = { :git => 'git@github.com:Start9Labs/capaciTor1.git', :tag => s.version.to_s }
    s.source_files = 'ios/Plugin/**/*.{swift,h,m,c,cc,mm,cpp}'
    s.ios.deployment_target  = '11.0'
    s.dependency 'Capacitor'
    s.dependency 'ReachabilitySwift', '~> 3'
    s.vendored_frameworks = 'ios/Pods/Tor.framework'
  end
