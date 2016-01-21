
Pod::Spec.new do |s|
  s.name         = "Hakuba"
  s.version      = "1.3.2"
  s.summary      = "A new way to manage UITableView"
  s.homepage     = "https://github.com/beng341/Hakuba"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.authors             = { "Le Van Nghia" => "nghialv2607@gmail.com", "Ben Armstrong" => "beng341+github@gmail.com" }

  s.platform     = :ios
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/beng341/Hakuba.git", :tag => "1.3.1" }
  s.source_files  = "Source/*"
  s.requires_arc = true
end