import UIKit

class CreateAccountViewController: UIViewController {
    
    var securityQuestion = "What year were you born?"
    @IBOutlet weak var securityQuestionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        securityQuestionLabel.text = securityQuestion
    }
    
    @IBAction func doSubmit(sender: AnyObject) {
        self.performSegueWithIdentifier("AccountSuccess", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Pass the userID into the FormList controller
        if segue.identifier == "AccountSuccess" {
            let securityQuestionViewController = segue.destinationViewController as! SecurityQuestionViewController
        }
    }
}
