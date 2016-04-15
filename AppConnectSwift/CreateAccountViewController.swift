import UIKit

class CreateAccountViewController: UIViewController {
    
    var securityQuestion = "What year were you born?"
    var userEmail : String!
    var userPassword : String!
    var userSecuirtyQuestionID : Int!
    
    @IBOutlet weak var userSecurityQuestionAnswer: UITextField!
    @IBOutlet weak var securityQuestionLabel: UILabel!
    
    @IBAction func createAccount(sender: AnyObject) {
        let clientFactory = MDClientFactory.sharedInstance()
        let client = clientFactory.clientOfType(MDClientType.Network);
        client.registerSubjectWithEmail(userEmail, password: userPassword, securityQuestionID: userSecuirtyQuestionID, securityQuestionAnswer: userSecurityQuestionAnswer.text) { (err) -> Void in
            print(err!=nil ? self.performSegueWithIdentifier("CreateAccountSuccess", sender: nil): err?.description)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        securityQuestionLabel.text = securityQuestion
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CreateAccountSuccess" {
            let loginViewController = segue.destinationViewController as! LoginViewController
        }
    }
}
