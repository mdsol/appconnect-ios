import UIKit

class PasswordViewController: UIViewController, UITextFieldDelegate {
    
    var userEmail : String!
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfirmField: UITextField!
    @IBOutlet weak var confirmPasswordsMatching: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Keep the confirm label hidden till password text fields submitted are satisfying criteria
        confirmPasswordsMatching.isHidden = true
        passwordField.addTarget(self, action: #selector(UITextFieldDelegate.textFieldDidBeginEditing(_:)), for: UIControl.Event.editingChanged)
        passwordConfirmField.addTarget(self, action: #selector(UITextFieldDelegate.textFieldDidBeginEditing(_:)), for: UIControl.Event.editingChanged)
    }
    
    // Valid password condition:
    //    •  At least 8 characters long
    //    •  At least one upper-case letter
    //    •  At least one lower-case letter
    //    •  At least one numeric digit
    //    •  Spaces in the middle are allowed
    
    @IBAction func doSubmit(_ sender: AnyObject) {
        // Trim leading and trailing white spaces
        guard let password = passwordField.text?.trimmingCharacters(in: .whitespaces), let confirmedPassword = passwordConfirmField.text?.trimmingCharacters(in: .whitespaces) else {
            return
        }
        
        guard password == confirmedPassword else {
            setErrorMessage("Your passwords do not match")
            return
        }
        
        if PasswordViewController.validatePassword(password) {
            self.performSegue(withIdentifier: "PasswordSuccess", sender: nil)
        } else {
            setErrorMessage("Password criteria is not met")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "PasswordSuccess", let securityQuestionViewController = segue.destination as? SecurityQuestionViewController else {
            return
        }
        
        // Pass the userEmail, userPassword for creating account
        securityQuestionViewController.userEmail = userEmail
        securityQuestionViewController.userPassword = passwordField.text?.trimmingCharacters(in: .whitespaces)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Once textfield is in focus remove the error label and borders from the fields
        confirmPasswordsMatching.isHidden = true
        textField.layer.borderWidth = 0.0
        textField.layer.cornerRadius = 0.0
    }
    
    static func validatePassword(_ password: String) -> Bool {
        do {
            let passwordRegEx = try NSRegularExpression(pattern: "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[\\S\\s]{8,}$", options: [])
            let range = NSRange(password.startIndex..., in: password)
            let matchRange = passwordRegEx.rangeOfFirstMatch(in: password, options: .reportProgress, range: range)
            
            return matchRange.location != NSNotFound
        } catch {
            fatalError("Error initializing regular expressions. Exiting.")
        }
    }
    
    private func setErrorMessage(_ message: String) {
        confirmPasswordsMatching.isHidden = false
        confirmPasswordsMatching.text = message
        confirmPasswordsMatching.textColor = UIColor.red
        passwordField.layer.borderWidth = 2.0
        passwordField.layer.cornerRadius = 5.0
        passwordField.layer.borderColor = UIColor.red.cgColor
    }
}
