# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'HSAapp' do
  # Comment the next line if you don't want to use dynamic frameworks
  platform :ios, '15.0'
  use_frameworks! #:linkage => :static
  inhibit_all_warnings!

  # Pods for HSAapp
  pod 'Firebase/Analytics', '~> 8.3'
  pod 'Firebase/Crashlytics', '~> 8.3'
  pod 'Resolver', '~> 1.4.4'
  pod 'RealmSwift', '~> 10.15.0'
  pod 'Introspect', '~> 0.1.4'
  pod 'CocoaLumberjack/Swift', '~> 3.7.2'
  pod 'SwiftLint', '~> 0.44.0'
  pod 'R.swift', '~> 7.2.0'
  pod 'KeychainAccess',  '~> 4.2.2'
  
  target 'HSAappTests' do
     inherit! :search_paths
     # Pods for testing
   end
  
  post_install do |installer|
    puts 'Removing unneeded Realm static libraries' 
    system("ls -d #{Dir.pwd}/Pods/Realm/core/realm-monorepo.xcframework/\*/ | grep -v ios | xargs rm -fR")
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
           if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 15.0
             config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
           end
        end
    end
  end
  

end
