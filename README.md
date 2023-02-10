# HSA app

_The native iOS application of HSA built with SwiftUI._

# Quick Start

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites
- iOS 15.0+
- Xcode 14.0+
- [CocoaPods](http://cocoapods.org/)
- [Swift Package Manager](https://www.swift.org/package-manager/)


### How to setup project?

1. Clone this repository into a location of your choice, like your projects folder
2. Open terminal - > Navigate to  the directory containing ``Podfile``
3. Then install pods into your project by typing in terminal: ```pod install```
4. Once completed, there will be a message that says
`"Pod installation complete! There are X dependencies from the Podfile and X total pods installed."`
5. You are all set now. Open the .xcworkspace file from now on and hit Xcode's 'run' button.  🚀 

### How to use?
There are 3 schemes available to run the project in Debug, Staging, Release environment.
1. Debug - Set the active scheme as `HSAapp - Debug` to run the project in Debug environment.
2. Staging  - Set the active scheme as `HSAapp - Staging` to run the project in Staging environment. 
3. Release - Set the active scheme as `HSAapp - Release` to run the project in Release environment.

### Swift Style Guide
Code follows [Swift standard library](https://google.github.io/swift/) style guide.
Project uses [SwiftLint](https://github.com/realm/SwiftLint) to enforce Swift style and conventions before sending a pull request.

### Dependencies
A few dependencies are required to begin developing the application:
- [SwiftLint](https://github.com/realm/SwiftLint#installation) 
- [Firebase/Analytics](https://github.com/firebase/firebase-ios-sdk/tree/master/FirebaseAnalyticsSwift#installation) 
- [Firebase/Crashlytics](https://github.com/firebase/firebase-ios-sdk/tree/master/Crashlytics#installation) 
- [Resolver](https://github.com/hmlongco/Resolver#installation) 
- [RealmSwift](https://github.com/realm/realm-swift#installation) 
- [Introspect](https://github.com/siteline/SwiftUI-Introspect#installation) 
- [KeychainAccess](https://github.com/kishikawakatsumi/KeychainAccess#installation) 
- [TextView](https://github.com/kenmueller/TextView#installation) 

### Architecture

HSA app follows MVVM architecture. All views and related viewModels are grouped based on the modules and separated by folders.

##### File Structure

HSA app's files are grouped by folders. Here's the list of main folders and what kind of files are included in each.

- **Configs** - It consists of files which includes initial configurations required and for different environments.

- **UI** - This folder consists of extension, helpers class, modifiers, utils, UIKitBridges, custom and common views used across the application.

- **Models** - Models is divided into subfolders for database model, request / response model as well as data models.

- **Scenes** - All the views and viewmodel used are included in this folder. They are divided into subfolders based on the application's modules.

- **Services** - It includes files which handles database operations, storing data to user defaults or Keychain, handling API calls, network status, dependency injection and analytics.

- **HSAappXCUITests** - This folder has UI test cases related to application flow, validating the existence of UIElement on relative screens. 

- **HSAappTests** - It includes unit test cases for validating the views. It consists of methods to validate data and API responses. 
