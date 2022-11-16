# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

target 'HSAapp' do
  # Comment the next line if you don't want to use dynamic frameworks
  platform :ios, '14.0'
  use_frameworks! #:linkage => :static
  inhibit_all_warnings!

  # Pods for HSAapp
  pod 'Firebase/Analytics', '~> 8.3'
  pod 'Firebase/Crashlytics', '~> 8.3'
  pod 'Resolver'
  pod 'RealmSwift', '~> 10.15.0'
  pod 'Introspect', '~> 0.1.4'
  pod 'CocoaLumberjack/Swift'
  pod 'SwiftLint'
  
  target 'HSAappTests' do
     inherit! :search_paths
     # Pods for testing
   end
  
  post_install do |installer|
    puts 'Removing unneeded Realm static libraries' 
    system("ls -d #{Dir.pwd}/Pods/Realm/core/realm-monorepo.xcframework/\*/ | grep -v ios | xargs rm -fR") 
  end
end
