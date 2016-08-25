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
        let client = clientFactory.clientOfType(MDClientType.Hybrid);
        
        if userSecurityQuestionAnswer.text?.characters.count < 2 {
            showAlert("Account Creation Failure", message: "Security answer must be at least 2 characters long.", okHandler: nil)
            return
        }
        
        client.registerSubjectWithEmail(userEmail, password: userPassword, securityQuestionID: userSecurityQuestionID, securityQuestionAnswer: userSecurityQuestionAnswer.text) { (err) in

            if err == nil {
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    self.showAlert("Account Creation Success", message: "", okHandler:self.successfulAccountCreationHandler)
                })
            }
            else {
                var alertMessage = "Unable to register user"
                let errorCause = MDClientErrorCause(rawValue: err.code)

                if errorCause == MDClientErrorCause.InvalidRegistrationToken {
                    alertMessage = "Invalid Registration Token."
                } else if errorCause == MDClientErrorCause.SubjectAlreadyExistsWithEmail {
                    alertMessage = "User already exists with email."
                }


                NSOperationQueue.mainQueue().addOperationWithBlock({
                    self.showAlert(alertMessage, message: err.description, okHandler: nil)
                })
            }
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
