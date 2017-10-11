import UIKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var UIDatastore: MDDatastore?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Start AppConnect. This must be done as early as possible during the
        // lifetime of the app, so doing it in the AppDelegate is ideal.
        // The passed directory is used to store the database. The key is used
        // to encrypt sensitive information in the database. It must be 32-bytes
        // long and must be the same between runs.
        let dir = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last
        let key = "12345678901234567890123456789012".data(using: String.Encoding.utf8)
        // TODO: Substitute the apiToken value with proper token
        MDBabbage.start(with: MDClientEnvironment.sandbox, apiToken: "some api token", publicDirectory: dir, privateDirectory: dir, encryptionKey: key)

        // All UI code must get objects from the same datastore, so it's a good
        // idea to create it once and make it available to the rest of the app
        UIDatastore = MDDatastoreFactory.create()
        
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().toolbarManageBehaviour = IQAutoToolbarManageBehaviour.byPosition
        
        return true
    }
}
