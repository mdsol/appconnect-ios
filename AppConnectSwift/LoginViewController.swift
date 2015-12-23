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
        
        usernameField.text = "sdk@101.com" //"sub02@sqa.com"
        passwordField.text = "Password90" //"Password1"
        
        MDClient.setEnvironment(.Validation);

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doLogin(sender: UIButton) {
        let username = usernameField.text
        let password = passwordField.text
        
        let clientFactory = MDClientFactory.sharedInstance()
        let client = clientFactory.clientOfType(MDClientType.Network);
        
        let bgQueue = NSOperationQueue()
        bgQueue.addOperationWithBlock {
            let datastore = MDDatastoreFactory.create()
            client.logIn(username, inDatastore: datastore, password: password) { (user: MDUser!, error: NSError!) -> Void in
                if (user != nil) {
                    self.userID = user.objectID
                    print("username: \(user.username)")
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.performSegueWithIdentifier("LoginSuccess", sender: nil)
                    }
                } else if (error != nil) {
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(
                            UIAlertAction(title: "Error", style: UIAlertActionStyle.Default) { (alert: UIAlertAction) in }
                        )
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "LoginSuccess" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let formListViewController = navigationController.viewControllers.first as! FormListViewController
            formListViewController.setUserID(self.userID!)
        }
    }

}
