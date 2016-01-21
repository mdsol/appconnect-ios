import UIKit

class FormListViewController: UITableViewController {

    var objects = [AnyObject]()
    var userID : Int64!
    
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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Populate the list with forms that are already in the datastore
        populateForms()
    }
    
    func loadForms() {
        // Start an asynchronous task to load the forms
        var bgQueue : NSOperationQueue! = NSOperationQueue()
        bgQueue.addOperationWithBlock() {
            // Each secondary thread must create its own datastore instance and
            // dispose of it when done
            let clientFactory = MDClientFactory.sharedInstance()
            let client = clientFactory.clientOfType(MDClientType.Network);
            var datastore = MDDatastoreFactory.create()
            let user = datastore.userWithID(Int64(self.userID))
            
            // Keep track of loaded subjects so that we know when all have been loaded
            var loadedSubjectsAndErrors : [AnyObject] = []
            
            client.loadSubjectsForUser(user) { (subjects: [AnyObject]!, error: NSError!) -> Void in
                if error != nil {
                    loadedSubjectsAndErrors.append(error)
                    if loadedSubjectsAndErrors.count == subjects.count {
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            self.populateForms()
                            self.spinner.stopAnimating()
                            datastore = nil
                            bgQueue = nil
                        }
                    }
                    return
                }

                // Get the subjects for the current user and then iterate over
                // the subjects to sync their forms. The objects returned from
                // these methods are only usable during the lifetime of this
                // temporary datastore.
                for subject in subjects as! [MDSubject]! {
                    client.loadFormsForSubject(subject) { (forms: [AnyObject]!, error: NSError!) -> Void in
                        loadedSubjectsAndErrors.append(subject)
                        
                        // When all subjects have been loaded, populate the UI and stop the spinner
                        if loadedSubjectsAndErrors.count == subjects.count {
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                self.populateForms()
                                self.spinner.stopAnimating()
                                datastore = nil
                                bgQueue = nil
                            }
                        }
                    }
                }
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
            self.objects = forms
        }
        self.tableView.reloadData()
    }
    
    func doLogout() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let form = objects[indexPath.row] as! MDForm
            if form.formOID == "FORM1" {
                let controller = segue.destinationViewController as! OnePageFormViewController
                controller.formID = form.objectID
            } else if form.formOID == "FORM2" {
                let controller = segue.destinationViewController as! MultiPageFormViewController
                controller.formID = form.objectID
            }
        }
    }

    // MARK: - Table View
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Start a view controller to fill out the form. If the form is from the SDK
        // sample CRF, we open FORM1 as a one-page form and FORM2 as a multi-page
        // form to demonstrate how to handle both cases.
        let form = objects[indexPath.row] as! MDForm
        let sequeIdentifier = ["FORM1" : "ShowOnePageForm", "FORM2" : "ShowMultiPageForm"][form.formOID]
        performSegueWithIdentifier(sequeIdentifier!, sender: self)
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let object = objects[indexPath.row] as! MDForm
        
        cell.textLabel!.text = object.name
        return cell
    }

}

