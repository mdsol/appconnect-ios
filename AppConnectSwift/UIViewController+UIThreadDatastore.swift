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
}