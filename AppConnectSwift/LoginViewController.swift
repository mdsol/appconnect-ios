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
    
    var user : MDUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.text = "sample" //"sub02@sqa.com"
        passwordField.text = "Sample1234" //"Password1"
        
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
        let client = clientFactory.clientOfType(MDClientType.Demo);
        
        let datastore = MDDatastoreFactory.create()
        
        client.logIn(username, inDatastore: datastore, password: password) { (user: MDUser!, error: NSError!) -> Void in
            if (user != nil) {
                self.user = user
                print("username: \(user.username)")
                self.performSegueWithIdentifier("LoginSuccess", sender: nil)
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "LoginSuccess" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let formListViewController = navigationController.viewControllers.first as! FormListViewController
            formListViewController.setUserID(self.user!.objectID)
        }
    }

}
