import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet var usernameField : UITextField!;
    @IBOutlet var passwordField : UITextField!;
    @IBOutlet var loginButton   : UIButton!;
    @IBOutlet weak var signUpButton: UIButton!

    var userID : Int64?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        loginButton.setTitle("Logging In", forState: UIControlState.Disabled)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    
    @IBAction func doLogin(sender: UIButton) {
        loginButton.enabled = false
        
        let username = usernameField.text
        let password = passwordField.text
        
        let clientFactory = MDClientFactory.sharedInstance()
        let client = clientFactory.clientOfType(MDClientType.Hybrid);
        
        var bgQueue : NSOperationQueue! = NSOperationQueue()
        bgQueue.addOperationWithBlock {
            // Each secondary thread must create its own datastore instance and
            // dispose of it when done
            var datastore = MDDatastoreFactory.create()
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
                        // Keep the datastore and queue alive until after the request is completed
                        bgQueue = nil
                        datastore = nil
                    }
                } else if (error != nil) {
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        var message = error.localizedDescription
                        if (MDClientErrorCause(rawValue: error.code) == MDClientErrorCause.AuthenticationFailure) {
                            message = "The provided credentials are incorrect."
                        }
                        
                        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(
                            UIAlertAction(title: "Error", style: UIAlertActionStyle.Default) { (alert: UIAlertAction) in }
                        )
                        self.presentViewController(alert, animated: true, completion: nil)
                        self.loginButton.enabled = true
                        // Keep the datastore and queue alive until after the request is completed                        
                        bgQueue = nil
                        datastore = nil
                    }
                }
            }
        }
    }
    @IBAction func doSignUp(sender: AnyObject) {
        self.navigationController?.navigationBarHidden = false
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
