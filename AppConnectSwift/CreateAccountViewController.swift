import UIKit

class CreateAccountViewController: UIViewController {
    
    var securityQuestion = "What year were you born?"
    var userEmail : String!
    var userPassword : String!
    var userSecurityQuestionID : Int!
    
    @IBOutlet weak var userSecurityQuestionAnswer: UITextField!
    @IBOutlet weak var securityQuestionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        securityQuestionLabel.text = securityQuestion
    }
    
    @IBAction func createAccount(sender: AnyObject) {
        let clientFactory = MDClientFactory.sharedInstance()
        let client = clientFactory.clientOfType(MDClientType.Network);
        if userSecurityQuestionAnswer.text?.characters.count >= 2 {
            client.registerSubjectWithEmail(userEmail, password: userPassword, securityQuestionID: userSecurityQuestionID, securityQuestionAnswer: userSecurityQuestionAnswer.text) { (err) in
                if err == nil {
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        self.showAlert("Account Creation Success", message: "", okHandler:self.successfulAccountCreationHandler)
                    })
                }
                else {
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        self.showAlert("Account Creation Failure", message: err.description, okHandler: nil)
                    })
                }
            }
        }
        else {
           self.showAlert("Account Creation Failure", message: "Security answer must be at least 2 characters long.", okHandler: nil)
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Account created successfully takes user back to login screen
        if segue.identifier == "CreateAccountSuccess" {
            let loginViewController = segue.destinationViewController as! LoginViewController
        }
    }
    
    func showAlert(title: String, message: String,  okHandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: okHandler))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func successfulAccountCreationHandler(alert: UIAlertAction!) {
        NSOperationQueue.mainQueue().addOperationWithBlock({
                self.performSegueWithIdentifier("CreateAccountSuccess", sender: nil)
        })
    }
}
