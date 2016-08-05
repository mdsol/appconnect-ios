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
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        let clientFactory = MDClientFactory.sharedInstance()
        let client = clientFactory.clientOfType(MDClientType.Hybrid)
        
        client.loadSecurityQuestionsWithCompletion() { (questions: [NSObject : AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    self.showDialog("Error", message: "There was an error retrieving the security questions", completion: nil)
                });
                
                return
            }
            
            for (questionId, question) in questions as! [String : String] {
                self.securityIdsByQuestion[question] = Int(questionId)
                self.tableDataSource.append(question)
            }
            
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.tableView.reloadData()
            });
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
        
        cell.textLabel?.text = self.tableDataSource[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.securityQuestion = tableDataSource[indexPath.row]
        self.securityQuestionID = securityIdsByQuestion[self.securityQuestion]!
        self.performSegueWithIdentifier("SecuritySuccess", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Pass the userEmail, userPassword, securityQuestionID for creating account 
        if(segue.identifier == "SecuritySuccess"){
            createAccountViewController = segue.destinationViewController as! CreateAccountViewController
            createAccountViewController.userEmail = userEmail
            createAccountViewController.userPassword = userPassword
            createAccountViewController.userSecurityQuestionID = securityQuestionID
            createAccountViewController.securityQuestion = self.securityQuestion
        }
    }
}
