Pod::Spec.new do |s|

  s.name         = "PTV"
  s.version      = "0.2.3"
  s.summary      = "An API adapter for the PTV Timetable API written in Swift for iOS"
  s.description  = <<-DESC
                   An API adapter for the PTV Timetable API written in Swift for iOS.
                   Provides 3 different adapter classes, PTV.Adapter for 'raw' calls to the PTV API, PTV.ModelledAdapter for predefined calls returning structs and PTV.CachingAdapter for automatically caching static data. 
                   DESC
  s.homepage     = "https://github.com/jmargenberg/SwiftPTV"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = "James Margenberg"
  s.platform     = :ios, "10.3"
  s.swift_version = "4.1"
  s.source       = { :git => "https://github.com/jmargenberg/SwiftPTV.git", :tag => "v0.2.3" }
  s.source_files  = "PTV/**/*.{swift,h}"

  s.subspec 'Adapter' do |sp|
    sp.source_files = "PTV/**/*.{h}", "PTV/Adapter.swift", "PTV/Models/{ErrorResponse,Status}.swift"
  end
  s.subspec 'ModelledAdapter' do |sp|
    sp.source_files = "PTV/**/*.{h}", "PTV/{Adapter, ModelledAdapter}.swift", "PTV/Models/*.{swift}"
  end
  s.subspec 'CachingAdapter' do |sp|
    sp.source_files = "PTV/**/*.{swift,h}"
  end
end
