Pod::Spec.new do |s|
  s.name = 'HNMKMapView'
  s.version = '0.0.2'
  s.platform = :ios
  s.ios.deployment_target = '7.0'

  s.prefix_header_file = 'HNMKMapView/HNMKMapView-Prefix.pch'
  s.source_files = 'HNMKMapView/libSrc/*.{h,m}'
 
  s.framework = 'MapKit'
  s.requires_arc = true
end
