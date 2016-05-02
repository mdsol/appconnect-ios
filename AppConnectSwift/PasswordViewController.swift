import UIKit

class PasswordViewController: UIViewController {
    
    var userEmail : String!
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfirmField: UITextField!
    @IBOutlet weak var confirmPasswordsMatching: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Keep the confirm label hidden till password text fields submitted are satisfying criteria
        confirmPasswordsMatching.hidden =  true
        passwordField.addTarget(self, action: "textFieldDidBeginEditing:", forControlEvents: UIControlEvents.EditingChanged)
        passwordConfirmField.addTarget(self, action: "textFieldDidBeginEditing:", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    @IBAction func doSubmit(sender: AnyObject) {
        if passwordField.text == passwordConfirmField.text {
            do {
                // Valid password condition:
                //    •  At least 8 characters long
                //    •  At least one upper-case letter
                //    •  At least one lower-case letter
                //    •  At least one numeric digit
                let passwordRegEx = try NSRegularExpression(pattern: "((?=.*\\d)(?=.*[a-z])(?=.*[A-Z])){8,}", options: .CaseInsensitive)
                if passwordField.text != "" && passwordRegEx.firstMatchInString(passwordField.text!, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, passwordField.text!.characters.count)) != nil && passwordField.text?.characters.count >= 8 {
                    self.performSegueWithIdentifier("PasswordSuccess", sender: nil)
                }
                else {
                    // Color the border of text field red
                    confirmPasswordsMatching.hidden = false
                    confirmPasswordsMatching.text = "Password criteria not met"
                    confirmPasswordsMatching.textColor = UIColor.redColor()
                    passwordField.layer.borderWidth = 2.0
                    passwordField.layer.cornerRadius = 5.0
                    passwordField.layer.borderColor = UIColor.redColor().CGColor
                }
            }
            catch {
                print("Errored")
            }
        }
        else {
            // Color the border of text field red
            confirmPasswordsMatching.hidden = false
            confirmPasswordsMatching.text = "Passwords not matching"
            confirmPasswordsMatching.textColor = UIColor.redColor()
            passwordConfirmField.layer.borderWidth = 2.0
            passwordConfirmField.layer.cornerRadius = 5.0
            passwordConfirmField.layer.borderColor = UIColor.redColor().CGColor
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PasswordSuccess" {
            let securityQuestionViewController = segue.destinationViewController as! SecurityQuestionViewController
            // Pass the userEmail, userPassword for creating account
            securityQuestionViewController.userEmail = userEmail
            securityQuestionViewController.userPassword = passwordField.text
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Once textfield is in focus remove the error label and borders from the fields
        confirmPasswordsMatching.hidden = true
        textField.layer.borderWidth = 0.0
        textField.layer.cornerRadius = 0.0
    }
}
