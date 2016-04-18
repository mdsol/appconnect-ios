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
        client.registerSubjectWithEmail(userEmail, password: userPassword, securityQuestionID: userSecurityQuestionID, securityQuestionAnswer: securityQuestionLabel.text) { (err) in
            err != nil ? self.performSegueWithIdentifier("CreateAccountSuccess", sender: nil) : print(err?.description)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Account created successfully takes user back to login screen
        if segue.identifier == "CreateAccountSuccess" {
            let loginViewController = segue.destinationViewController as! LoginViewController
        }
    }
}
