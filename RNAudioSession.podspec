
Pod::Spec.new do |s|
    s.name           = package['name']
    s.version        = package['version']
    s.summary        = package['description']
    s.description    = package['description']
    s.homepage     = "https://github.com/AmbiFi/react-native-audio-session.git"
    s.license      = "MIT"
    s.author             = { "author" => "author@domain.cn" }
    s.requires_arc   = true
    s.platform     = :ios, "7.0"
    s.source       = { :git => "https://github.com/AmbiFi/react-native-audio-session.git", :tag => "master" }
    s.source_files  = "ios/**/*.{h,m}"
  
    s.dependency "React"
    #s.dependency "others"
  
  end
