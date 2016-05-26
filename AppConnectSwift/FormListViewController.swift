import UIKit

class FormListViewController: UITableViewController {

    var loadedForms = [MDForm]()
    var userID : Int64!
    var primarySubjectId : Int64!
    
    var spinner : UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner = UIActivityIndicatorView.init(activityIndicatorStyle: .Gray)
        spinner.center = CGPointMake(self.view.frame.size.width/2.0, 22);
        spinner.hidesWhenStopped = true;
        self.view.addSubview(spinner)
        spinner.startAnimating()
        
        let backButton = UIBarButtonItem(title: "Log Out", style: UIBarButtonItemStyle.Plain, target: self, action: "doLogout")
        self.navigationItem.setLeftBarButtonItem(backButton, animated: true)
        
        // Begin loading the forms for the logged-in user
        loadForms()
    }

    func loadForms() {
        let client = MDClientFactory.sharedInstance().clientOfType(MDClientType.Network);
        
        let datastore = (UIApplication.sharedApplication().delegate as! AppDelegate).UIDatastore!
        
        let user = datastore.userWithID(Int64(self.userID))
        
        client.loadSubjectsForUser(user) { (subjects: [AnyObject]!, error: NSError!) -> Void in
            
            if error != nil {
                
                dispatch_async(dispatch_get_main_queue()) {
                    // no new forms from server
                    self.populateForms()
                    self.spinner.stopAnimating()
                }
                return;
            }
            
            var subjectCount = 0
            
            for subject in subjects as! [MDSubject]! {
                client.loadFormsForSubject(subject) { (forms: [AnyObject]!, error: NSError!) -> Void in
                    
                    subjectCount += 1
                    
                    // When all subjects have been loaded, populate the UI and stop the spinner
                    if subjectCount == subjects.count {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.populateForms()
                            self.spinner.stopAnimating()
                        }
                    }
                }
            }
            
            if (subjects.count > 0 ) {
                self.primarySubjectId = subjects[0].objectID
            }
        }
    }
    
    func populateForms() {
        // This is how the UI retrieves forms from the datastore for display.
        // The user could have multiple subjects if they're assigned to multiple
        // studies. Here we just gather all available forms, but you could also
        // present them organized by subject if desired.
        var forms : [MDForm]
        let datastore = (UIApplication.sharedApplication().delegate as! AppDelegate).UIDatastore!
        if let user = datastore.userWithID(Int64(self.userID)) {
            let subjects = user.subjects as! [MDSubject]
            forms = subjects.map({ (subject : MDSubject) -> [MDForm] in
                datastore.availableFormsForSubjectWithID(subject.objectID) as! [MDForm]
            }).reduce([], combine: +)
            
            self.loadedForms = forms
        }
        
        self.tableView.reloadData()
    }
    
    func doLogout() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            if loadedForms.count == 0 {
                self.navigationItem.title = "Back"
                let controller = segue.destinationViewController as! CaptureImageViewController
                controller.userID = self.userID!
                controller.subjectID = self.primarySubjectId!
            }
            else{
                let form = loadedForms[indexPath.row]
                if form.formOID == "FORM1" {
                    let controller = segue.destinationViewController as! OnePageFormViewController
                    controller.formID = form.objectID
                } else if form.formOID == "FORM2" {
                    let controller = segue.destinationViewController as! MultiPageFormViewController
                    controller.formID = form.objectID
                }
            }
        }
    }

    // MARK: - Table View
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Start a view controller to fill out the form. If the form is from the SDK
        // sample CRF, we open FORM1 as a one-page form and FORM2 as a multi-page
        // form to demonstrate how to handle both cases.
        if loadedForms.count == 0 {
            performSegueWithIdentifier("CaptureImage", sender: self)
        }
        else {
            let form = loadedForms[indexPath.row]
            let sequeIdentifier = ["FORM1" : "ShowOnePageForm", "FORM2" : "ShowMultiPageForm"][form.formOID]
            performSegueWithIdentifier(sequeIdentifier!, sender: self)
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loadedForms.count == 0 ? 1 : loadedForms.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        if loadedForms.count == 0 {
            cell.textLabel!.text = "Capture Image"
            return cell
        }
        let form = loadedForms[indexPath.row]
        
        cell.textLabel!.text = form.name
        return cell
    }

}

