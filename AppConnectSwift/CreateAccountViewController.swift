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
    
    @IBAction func createAccount(_ sender: AnyObject) {
        
        let clientFactory = MDClientFactory.sharedInstance()!
        let client = clientFactory.client(of: MDClientType.hybrid);
        
        if let answer = userSecurityQuestionAnswer.text {
            if answer.characters.count < 2 {
                showAlert("Account Creation Failure", message: "Security answer must be at least 2 characters long.")
            }
        }
        
        client?.registerSubject(withEmail: userEmail, password: userPassword, securityQuestionID: userSecurityQuestionID, securityQuestionAnswer: userSecurityQuestionAnswer.text) { (err) in

            if let error = err as? NSError {
                var alertMessage = "Unable to register user"
                let errorCause = MDClientErrorCause(rawValue: error.code)
                
                if errorCause == MDClientErrorCause.invalidRegistrationToken {
                    alertMessage = "Invalid Registration Token."
                } else if errorCause == MDClientErrorCause.subjectAlreadyExistsWithEmail {
                    alertMessage = "User already exists with email."
                }
                
                OperationQueue.main.addOperation({
                    self.showAlert(alertMessage, message: error.description)
                })
            } else {
                OperationQueue.main.addOperation({
                    self.showAlert("Account Creation Success", message: "", okHandler:self.successfulAccountCreationHandler)
                })
            }
        }
    }
    
    func showAlert(_ title: String, message: String,  okHandler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: okHandler))
        self.present(alert, animated: true)
    }
    
    func successfulAccountCreationHandler(_ alert: UIAlertAction!) {
        OperationQueue.main.addOperation() {
            self.performSegue(withIdentifier: "CreateAccountSuccess", sender: nil)
        }
    }
}
