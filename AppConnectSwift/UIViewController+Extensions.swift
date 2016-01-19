import Foundation
import UIKit

extension UIViewController {
    // Extension method to easily access the shared, UI thread datastore that is stored in the AppDelegate
    func UIThreadDatastore() -> MDDatastore! {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).UIDatastore!
    }
    
    // Helper method for showing an UIAlertController
    func showDialog(title: String, message: String, completion: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { alert in completion?() })
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
