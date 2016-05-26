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
        sender.enabled = false;
        
        let client = MDClientFactory.sharedInstance().clientOfType(MDClientType.Network);
        
         let datastore = (UIApplication.sharedApplication().delegate as! AppDelegate).UIDatastore!
        
        client.logIn(usernameField.text, inDatastore: datastore, password: passwordField.text) { (user: MDUser!, error: NSError!) -> Void in
            
            if(error != nil) {
                var alertMessage = error.localizedDescription;
                
                if(MDClientErrorCause(rawValue: error.code) == MDClientErrorCause.AuthenticationFailure) {
                    alertMessage = "The provided credentials are incorrect."
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.showAlert("Error", message: alertMessage)
                    sender.enabled = true
                }
                
                return
            }
            
            // no error implies we have a user.
            self.userID = user.objectID

            dispatch_async(dispatch_get_main_queue()) {
                self.performSegueWithIdentifier("LoginSuccess", sender: nil)
                sender.enabled = true
            }
        }
    }
    
    @IBAction func doSignUp(sender: AnyObject) {
        // segue'ing to sign up viewcontroller, reveal back button
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
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }


}
