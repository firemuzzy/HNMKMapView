Pod::Spec.new do |s|
  s.name = 'FZMapKit'
  s.version = '0.0.23'
  s.platform = :ios
  s.ios.deployment_target = '7.0'

  s.prefix_header_file = 'HNMKMapView/FZMapKit-Prefix.pch'
  s.source_files = 'HNMKMapView/libSrc/*.{h,m}'
 
  s.framework = 'MapKit'
  s.requires_arc = true
end
