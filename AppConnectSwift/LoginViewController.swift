import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet var usernameField : UITextField!;
    @IBOutlet var passwordField : UITextField!;
    @IBOutlet var loginButton   : UIButton!;
    @IBOutlet weak var signUpButton: UIButton!

    var userID : Int64?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        loginButton.setTitle("Logging In", for: UIControl.State.disabled)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func doLogin(_ sender: UIButton) {
        sender.isEnabled = false;
        
        let datastore = (UIApplication.shared.delegate as! AppDelegate).UIDatastore!
        
        let clientFactory = MDClientFactory.sharedInstance()
        let client = clientFactory.client(of: MDClientType.hybrid);
        
        client.log(in: usernameField.text, in: datastore, password: passwordField.text) { (user: MDUser?, err: Error?) -> Void in
            
            if let error = err as NSError? {
                var alertMessage = error.localizedDescription;
                
                let errorCause = MDClientErrorCause(rawValue: error.code)
                
                if errorCause == MDClientErrorCause.authenticationFailure {
                    alertMessage = "The provided credentials are incorrect."
                } else if errorCause == MDClientErrorCause.userNotAssociatedWithToken {
                    alertMessage = "User is not associated with provided API token."
                }
                
                DispatchQueue.main.async {
                    self.showAlert("Error", message: alertMessage)
                    sender.isEnabled = true
                }
                
                return
            }
            
            // no error implies we have a user.
            self.userID = user?.objectID
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "LoginSuccess", sender: nil)
                sender.isEnabled = true
            }
        }
    }
    
    @IBAction func doSignUp(_ sender: AnyObject) {
        // segue'ing to sign up viewcontroller, reveal back button
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the userID into the FormList controller
        if segue.identifier == "LoginSuccess" {
            let navigationController = segue.destination as! UINavigationController
            let formListViewController = navigationController.viewControllers.first as! FormListViewController
            formListViewController.userID = self.userID!
        }
    }
    
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
