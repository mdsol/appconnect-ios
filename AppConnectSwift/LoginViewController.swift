//
//  LoginViewController.swift
//  AppConnectSwift
//
//  Created by Nolan Carroll on 12/18/15.
//  Copyright © 2015 Medidata Solutions. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet var usernameField : UITextField!;
    @IBOutlet var passwordField : UITextField!;
    @IBOutlet var loginButton   : UIButton!;
    
    var userID : Int64?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.setTitle("Logging In", forState: UIControlState.Disabled)
        
        MDClient.setEnvironment(.Validation);
        usernameField.text = "sdk@101.com" //"sub02@sqa.com"
        passwordField.text = "Password90" //"Password1"
    }
    
    @IBAction func doLogin(sender: UIButton) {
        loginButton.enabled = false
        
        let username = usernameField.text
        let password = passwordField.text
        
        let clientFactory = MDClientFactory.sharedInstance()
        let client = clientFactory.clientOfType(MDClientType.Network);
        
        var bgQueue : NSOperationQueue! = NSOperationQueue()
        bgQueue.addOperationWithBlock {
            // Each secondary thread must create its own datastore instance and
            // dispose of it when done
            let datastore = MDDatastoreFactory.create()
            client.logIn(username, inDatastore: datastore, password: password) { (user: MDUser!, error: NSError!) -> Void in
                if (user != nil) {
                    // Babbage objects can't be shared between threads so you must pass
                    // them around by ID instead and the receiving code can get its own
                    // copy from its own datastore
                    self.userID = user.objectID
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        // Start the FormListViewController to show the forms available for the
                        // user who just logged in
                        self.performSegueWithIdentifier("LoginSuccess", sender: nil)
                        self.loginButton.enabled = true
                        bgQueue = nil
                    }
                } else if (error != nil) {
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(
                            UIAlertAction(title: "Error", style: UIAlertActionStyle.Default) { (alert: UIAlertAction) in }
                        )
                        self.presentViewController(alert, animated: true, completion: nil)
                        self.loginButton.enabled = true
                        bgQueue = nil
                    }
                }
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Pass the userID into the FormList controller
        if segue.identifier == "LoginSuccess" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let formListViewController = navigationController.viewControllers.first as! FormListViewController
            formListViewController.userID = self.userID!
        }
    }

}
