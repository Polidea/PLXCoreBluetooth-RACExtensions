Pod::Spec.new do |s|
  s.name             = "PLXCoreBluetooth"
  s.version          = "0.2"
  s.summary          = "Reactive Extensions for CoreBluetooth"
  s.description      = <<-DESC
PLXCoreBluetooth is a thin abstraction layer over CBCentralManager and CBPeripheral that enables programming using Reactive Cocoa.
                       DESC

  s.homepage         = "https://github.com/Polidea/PLXCoreBluetooth-RACExtensions"
  s.license          = 'MIT'
  s.authors          = { "Michal Mizera" => "axadiw@gmail.com", "Maciej Oczko" => "maciejoczko@gmail.com" }
  s.source           = { :git => "https://github.com/Polidea/PLXCoreBluetooth-RACExtensions.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/polidea'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.frameworks = 'CoreBluetooth', 'ReactiveCocoa'
  s.dependency 'ReactiveCocoa', '2.5'
end
