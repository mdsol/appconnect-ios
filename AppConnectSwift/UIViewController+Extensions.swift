//
//  UIViewController+UIThreadDatastore.swift
//  AppConnectSwift
//
//  Created by Nolan Carroll on 12/28/15.
//  Copyright © 2015 Medidata Solutions. All rights reserved.
//

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
        alert.addAction(
            UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (alert: UIAlertAction) -> Void in
                completion?()
            })
        )
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
