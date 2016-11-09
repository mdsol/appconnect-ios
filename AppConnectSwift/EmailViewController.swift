import UIKit

class EmailViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailConfirmTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var confirmLabelsMatching: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Keep the confirm label hidden till email text fields submitted are satisfying criteria
        confirmLabelsMatching.isHidden = true;
        emailTextField.addTarget(self, action: #selector(UITextFieldDelegate.textFieldDidBeginEditing(_:)), for: UIControlEvents.editingChanged)
        emailConfirmTextField.addTarget(self, action: #selector(UITextFieldDelegate.textFieldDidBeginEditing(_:)), for: UIControlEvents.editingChanged)
    }
    
    @IBAction func doSubmit(_ sender: AnyObject) {
        if emailTextField.text == emailConfirmTextField.text  {
            do {
                // Valid email condition
                let emailRegEx = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{1,64}", options: .caseInsensitive)
                if emailTextField.text != "" && emailRegEx.firstMatch(in: emailTextField.text!, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, emailTextField.text!.characters.count)) != nil {
                        self.performSegue(withIdentifier: "EmailSuccess", sender: nil)
                }
                else{
                    // Color the border of text field red
                    confirmLabelsMatching.isHidden = false
                    confirmLabelsMatching.text = "Enter a valid email"
                    confirmLabelsMatching.textColor = UIColor.red
                    emailTextField.layer.borderWidth = 2.0
                    emailTextField.layer.cornerRadius = 5.0
                    emailTextField.layer.borderColor = UIColor.red.cgColor
                }
            }
            catch {
                print("Issue in regular expression")
            }
        }
        else {
            // Color the border of text field red
            confirmLabelsMatching.isHidden = false
            emailConfirmTextField.layer.borderWidth = 2.0
            emailConfirmTextField.layer.cornerRadius = 5.0
            confirmLabelsMatching.textColor = UIColor.red
            emailConfirmTextField.layer.borderColor = UIColor.red.cgColor
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmailSuccess" {
            let passwordViewController = segue.destination as! PasswordViewController
            // Pass the userEmail for creating account
            passwordViewController.userEmail = emailTextField.text
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Once textfield is in focus remove the error label and borders from the fields
        confirmLabelsMatching.isHidden = true
        textField.layer.borderWidth = 0.0
        textField.layer.cornerRadius = 0.0
    }
}
