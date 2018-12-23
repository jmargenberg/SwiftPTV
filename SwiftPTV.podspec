Pod::Spec.new do |s|

  s.name         = "SwiftPTV"
  s.version      = "0.0.1"
  s.summary      = "An API adaptor for the PTV Timetable API written in Swift for iOS"
  s.description  = <<-DESC
                   An API adaptor for the PTV Timetable API written in Swift for iOS.
                   Provides 3 different implem
                   DESC
  s.homepage     = "https://github.com/jmargenberg/SwiftPTV"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = "James Margenberg"
  s.platform     = :ios, "10.3"
  s.swift_version = "4.1"
  s.source       = { :git => "https://github.com/jmargenberg/SwiftPTV.git", :commit => "762ae646f3b85e912b286b9ed5b51ec5b11f3960" }
  s.source_files  = "SwiftPTV/**/*.{swift,h}"
end
