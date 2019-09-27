Pod::Spec.new do |s|
    s.name         = "RNAudioSession"
    s.version      = "1.0.0"
    s.summary      = "RNAudioSession"
    s.description  = <<-DESC
                    RNAudioSession
                     DESC
    s.homepage     = "https://bitbucket.org/ambifi/react-native-audio-session"
    s.license      = "MIT"
    s.author             = { "author" => "author@domain.cn" }
    s.requires_arc   = true
    s.platform     = :ios, "7.0"
    s.source       = { :git => "https://bitbucket.org/ambifi/react-native-audio-session.git", :tag => "master" }
    s.source_files  = "ios/**/*.{h,m}"
  
    s.dependency "React"
    #s.dependency "others"
  
  end
