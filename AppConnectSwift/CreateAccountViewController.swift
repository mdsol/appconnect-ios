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
        
        let clientFactory = MDClientFactory.sharedInstance()
        let client = clientFactory.client(of: MDClientType.hybrid);
        
        if let answer = userSecurityQuestionAnswer.text, answer.count < 2 {
            showAlert("Account Creation Failure", message: "Security answer must have at least 2 characters")
            return
        }
        
        client.registerSubject(withEmail: userEmail, password: userPassword, securityQuestionID: userSecurityQuestionID, securityQuestionAnswer: userSecurityQuestionAnswer.text) { err in
            
            guard let error = err as NSError?, let errorCause = MDClientErrorCause(rawValue: error.code) else {
                OperationQueue.main.addOperation({
                    self.showAlert("Account Creation Success", okHandler:self.successfulAccountCreationHandler)
                })
                return
            }
            
            var alertMessage = "Unable to register user"
            
            switch errorCause {
            case .invalidRegistrationToken:
                alertMessage = "Invalid Registration Token"
            case .subjectAlreadyExistsWithEmail:
                alertMessage = "User already exists with the given email"
            case .iMedidataFailure:
                alertMessage = "iMedidata Authentication Error"
            default:
                break
            }
            
            OperationQueue.main.addOperation({
                self.showAlert(alertMessage)
            })
        }
    }
    
    func showAlert(_ title: String, message: String = "", okHandler: ((UIAlertAction) -> Void)? = nil) {
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
