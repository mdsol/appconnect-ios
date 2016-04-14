import UIKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var client: MDClient?
    var UIDatastore: MDDatastore?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Start AppConnect. This must be done as early as possible during the
        // lifetime of the app, so doing it in the AppDelegate is ideal.
        // The passed directory is used to store the database. The key is used
        // to encrypt sensitive information in the database. It must be 32-bytes
        // long and must be the same between runs.
        let dir = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last
        let key = "12345678901234567890123456789012".dataUsingEncoding(NSUTF8StringEncoding)
        // TODO: Substitute the apiToken value with proper token
        MDBabbage.startWithEnvironment(MDClientEnvironment.Validation, apiToken: "Random String", publicDirectory: dir, privateDirectory: dir, encryptionKey: key)
        
        // The client that will be used to make requests to the backend can be
        // created once and reused as needed throughout the app
        client = MDClientFactory.sharedInstance().clientOfType(MDClientType.Network)
        
        // All UI code must get objects from the same datastore, so it's a good
        // idea to create it once and make it available to the rest of the app
        UIDatastore = MDDatastoreFactory.create()
        
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().toolbarManageBehaviour = IQAutoToolbarManageBehaviour.ByPosition
        
        return true
    }
}
