import Foundation
import UIKit

extension UIViewController {
    // Extension method to easily access the shared, UI thread datastore that is stored in the AppDelegate
    func UIThreadDatastore() -> MDDatastore! {
        return (UIApplication.shared.delegate as! AppDelegate).UIDatastore!
    }
    
    // Helper method for showing an UIAlertController
    func showDialog(_ title: String, message: String, completion: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { alert in
            completion?()
        })
        self.present(alert, animated: true)
    }
}
