import UIKit

class PasswordViewController: UIViewController {
    
    var userEmail : String!
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfirmField: UITextField!
    @IBOutlet weak var confirmPasswordsMatching: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Keep the confirm label hidden till password text fields submitted are satisfying criteria
        confirmPasswordsMatching.isHidden =  true
        passwordField.addTarget(self, action: #selector(UITextFieldDelegate.textFieldDidBeginEditing(_:)), for: UIControlEvents.editingChanged)
        passwordConfirmField.addTarget(self, action: #selector(UITextFieldDelegate.textFieldDidBeginEditing(_:)), for: UIControlEvents.editingChanged)
    }
    
    @IBAction func doSubmit(_ sender: AnyObject) {
        if passwordField.text == passwordConfirmField.text {
            do {
                // Valid password condition:
                //    •  At least 8 characters long
                //    •  At least one upper-case letter
                //    •  At least one lower-case letter
                //    •  At least one numeric digit
                let passwordRegEx = try NSRegularExpression(pattern: "((?=.*\\d)(?=.*[a-z])(?=.*[A-Z])){8,}", options: .caseInsensitive)
                if passwordField.text != nil && passwordRegEx.firstMatch(in: passwordField.text!, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, passwordField.text!.characters.count)) != nil && passwordField.text!.characters.count >= 8 {
                    self.performSegue(withIdentifier: "PasswordSuccess", sender: nil)
                }
                else {
                    // Color the border of text field red
                    confirmPasswordsMatching.isHidden = false
                    confirmPasswordsMatching.text = "Password criteria is not met"
                    confirmPasswordsMatching.textColor = UIColor.red
                    passwordField.layer.borderWidth = 2.0
                    passwordField.layer.cornerRadius = 5.0
                    passwordField.layer.borderColor = UIColor.red.cgColor
                }
            }
            catch {
                print("Issue in regular expression")
            }
        }
        else {
            // Color the border of text field red
            confirmPasswordsMatching.isHidden = false
            confirmPasswordsMatching.text = "Your passwords do not match"
            confirmPasswordsMatching.textColor = UIColor.red
            passwordConfirmField.layer.borderWidth = 2.0
            passwordConfirmField.layer.cornerRadius = 5.0
            passwordConfirmField.layer.borderColor = UIColor.red.cgColor
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PasswordSuccess" {
            let securityQuestionViewController = segue.destination as! SecurityQuestionViewController
            // Pass the userEmail, userPassword for creating account
            securityQuestionViewController.userEmail = userEmail
            securityQuestionViewController.userPassword = passwordField.text
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Once textfield is in focus remove the error label and borders from the fields
        confirmPasswordsMatching.isHidden = true
        textField.layer.borderWidth = 0.0
        textField.layer.cornerRadius = 0.0
    }
}
