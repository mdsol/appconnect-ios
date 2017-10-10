import UIKit

class SecurityQuestionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
   
    var tableDataSource = [String]()
    var securityQuestion = "What year were you born?"
    var securityQuestionID = -1
    var createAccountViewController = CreateAccountViewController()
    var userEmail : String!
    var userPassword : String!
    
    var securityIdsByQuestion = [String : Int]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        let clientFactory = MDClientFactory.sharedInstance()
        let client = clientFactory.client(of: MDClientType.hybrid)
        
        client.loadSecurityQuestions() { (questions: [AnyHashable: Any]?, error: Error?) -> Void in
            if error != nil {
                OperationQueue.main.addOperation() {
                    self.showDialog("Error", message: "There was an error retrieving the security questions", completion: nil)
                }
                
                return
            }
            
            for (questionId, question) in questions as! [String : String] {
                self.securityIdsByQuestion[question] = Int(questionId)
                self.tableDataSource.append(question)
            }
            
            OperationQueue.main.addOperation() {
                self.tableView.reloadData()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "Cell")! as UITableViewCell
        
        cell.textLabel?.text = self.tableDataSource[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.securityQuestion = tableDataSource[indexPath.row]
        self.securityQuestionID = securityIdsByQuestion[self.securityQuestion]!
        self.performSegue(withIdentifier: "SecuritySuccess", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the userEmail, userPassword, securityQuestionID for creating account 
        if segue.identifier == "SecuritySuccess" {
            createAccountViewController = segue.destination as! CreateAccountViewController
            createAccountViewController.userEmail = userEmail
            createAccountViewController.userPassword = userPassword
            createAccountViewController.userSecurityQuestionID = securityQuestionID
            createAccountViewController.securityQuestion = self.securityQuestion
        }
    }
}
