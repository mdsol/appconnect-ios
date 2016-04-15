import UIKit

class SecurityQuestionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
   
    var tableDataSource: [String]  = ["What year were you born?",
        "Last four digits of SSN or Tax ID number?",
        "What is your fathers middle name?",
        "What was the name of your first school?",
        "Who was your childhood hero?",
        "What is your favorite pastime?",
        "What is your all-time favorite sports team?",
        "What is your high school team or mascot?",
        "What make was your first car or bike?",
        "What is your pets name?",
        "What is your mothers middle name?"
    ]
    var securityQuestion = "What year were you born?"
    var createAccountViewController = CreateAccountViewController()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
        
        cell.textLabel?.text = self.tableDataSource[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
         self.performSegueWithIdentifier(
            "SecuritySuccess", sender: nil)
        var s = tableDataSource[indexPath.row]
        self.securityQuestion = tableDataSource[indexPath.row]
        createAccountViewController.securityQuestion = self.securityQuestion
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "SecuritySuccess"){
            createAccountViewController = segue.destinationViewController as! CreateAccountViewController
        }
    }
    
}