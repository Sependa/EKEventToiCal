Pod::Spec.new do |s|
  s.name         = "EKEventToiCal"
  s.version      = "1.0.0"
  s.summary      = "Category on EKEvent return a string in iCal format."
  s.homepage     = "https://github.com/Taptera/EKEventToiCal.git"
  s.license      = "Taptera"
  s.author       = { "Taptera" => "ios-devs@taptera.com" }
  s.source       = { :git => "git@github.com:Taptera/EKEventToiCal.git", :tag => "v#{s.version}" }
  s.platform     = :ios, '5.0'
  s.requires_arc = false

  s.source_files = 'EKEventToiCal/Classes/**/*.{h,m}'

end
