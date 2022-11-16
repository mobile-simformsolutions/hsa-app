# HSA app

_The native iOS application of HSA built with SwiftUI._

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
