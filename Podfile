# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'BGGeoSwift' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks! :linkage => :static
  
  pod 'TSLocationManager', '~> 4.0.0-beta.7'
  pod 'CocoaLumberjack', '~> 3.8.5'
  # Pods for BGGeoSwift
  
  target 'BGGeoSwiftTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'BGGeoSwiftUITests' do
    # Pods for testing
  end
  
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    # Disable Xcode's sandboxing for CocoaPods' build scripts (rsync, etc).
    config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
  end
end
