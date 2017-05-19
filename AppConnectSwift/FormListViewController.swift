import UIKit

class FormListViewController: UITableViewController {

    var loadedForms = [MDForm]()
    var userID : Int64!
    var primarySubjectId : Int64!
    var subject1 : MDSubject!
    
    var spinner : UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        spinner.center = CGPoint(x: view.frame.size.width/2.0, y: 22);
        spinner.hidesWhenStopped = true;
        view.addSubview(spinner)
        spinner.startAnimating()
        
        //let backButton = UIBarButtonItem(title: "Log Out", style: UIBarButtonItemStyle.plain, target: self, action: #selector(FormListViewController.doLogout))
        
        // the logout button has now been set to do the appropriate search and fetch 
        // appconnect 2.0 calls that were stubbed out...
        
        let backButton = UIBarButtonItem(title: "Log Out", style: UIBarButtonItemStyle.plain, target: self, action: #selector(FormListViewController.doSearch))
        navigationItem.setLeftBarButton(backButton, animated: true)
        
        // Begin loading the forms for the logged-in user
        loadForms()
    }

    func loadForms() {
        let clientFactory = MDClientFactory.sharedInstance()
        let client = clientFactory.client(of: MDClientType.hybrid);

        let datastore = (UIApplication.shared.delegate as! AppDelegate).UIDatastore!
        
        let user = datastore.user(withID: self.userID)
        
        client.loadSubjects(for: user) { (subjects: [Any]?, error: Error?) -> Void in
            
            if error != nil {
                OperationQueue.main.addOperation({
                    // no new forms from server
                    self.populateForms()
                    self.spinner.stopAnimating()
                });
                return;
            }
            
            guard let subjects = subjects as? [MDSubject] else {
                return
            }
            
            var subjectCount = 0
            
            for subject in subjects {
                
                self.subject1 = subject;
                
                client.loadForms(for: subject) { (forms: [Any]?, error: Error?) -> Void in
                    
                    subjectCount += 1
                    
                    // When all subjects have been loaded, populate the UI and stop the spinner
                    if subjectCount == subjects.count {
                        OperationQueue.main.addOperation({
                            self.populateForms()
                            self.spinner.stopAnimating()
                        });
                    }
                }
            }
            
            if (subjects.count > 0 ) {
                self.primarySubjectId = (subjects.first! as AnyObject).objectID
            }
        }
    }
    
    func populateForms() {
        // This is how the UI retrieves forms from the datastore for display.
        // The user could have multiple subjects if they're assigned to multiple
        // studies. Here we just gather all available forms, but you could also
        // present them organized by subject if desired.
        var forms : [MDForm]
        let datastore = (UIApplication.shared.delegate as! AppDelegate).UIDatastore!
        if let user = datastore.user(withID: Int64(self.userID)) {
            let subjects = user.subjects as! [MDSubject]
            forms = subjects.map({ (subject : MDSubject) -> [MDForm] in
                datastore.availableFormsForSubject(withID: subject.objectID) as! [MDForm]
            }).reduce([], +)
            
            self.loadedForms = forms
        }
        
        tableView.reloadData()
    }
    
    
    func doSearch() {
        
        // the following data is sample fetch only
        // used to illustrate how the appconnect 2.0 calls are supposed to work.
        let clientFactory = MDClientFactory.sharedInstance()
        let client = clientFactory.client(of: MDClientType.network);
        
        let datastore = (UIApplication.shared.delegate as! AppDelegate).UIDatastore!
        let subject = datastore.subject(withID: self.primarySubjectId)
        
        // take an arbitrary subjectUUID
       // let SubjectUUID = "045e6689-b85e-4fad-bbb1-b4a34ab75d64";
       // https://epro-sandbox.imedidata.net/api/v2/subject_submissions.json?subject_uuid=045e6689-b85e-4fad-bbb1-b4a34ab75d64&study_auth_token=7591e9775049f126709657a968784082&start_date=2017-05-16T17:37:11.627Z&end_date=2017-05-19T17:37:11.627Z
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSZ";
        let startDate = formatter.date(from: "2017-05-16T17:37:11.627Z");
        let endDate = formatter.date(from: "2017-05-19T17:37:11.627Z");
        
        let parametersDictionary = ["size": "10", "page": "1"];
        
        // make the call to fetch all available records in this given time interval
        // the results will be passed back as an NSDictionary
        // in this stubbed method it will be ["SubjectUUID", "TestSubjectUUID"];
        // when connected to a live server it will be something like 
        // 
        
        client.fetchAvailableSubjectMetadataWithSubject(withDateRange: subject, from: startDate, to: endDate, withParameters: parametersDictionary) {
            (submissions: [Any]?, error: Error?) -> Void in
            
            
            if let err = error as NSError? {
                print(err);
                //var alertMessage = "Unable to fetch metadata"
                // let the user know that there is no metadata or server has returned no information....
                // we will return various error codes along with the error cause...
 
            }
            else
            {
                guard let submissions = submissions as? [MDSubmission] else {
                   return
                }
                
                for submission in submissions {
                    
                    print(submission.submissionUUID);
                    print(submission.contentType);
                    print(submission.fileSize);
                    
                }
                OperationQueue.main.addOperation({
                    //self.showAlert("metadata fetched", message: "");
                });

            }
        }
        
      
        /*
        // section B
        // so from subjectmetadatas you will get some SubmissionUUIDs.
        // for each set of submissionUUIDS you can fetch to retrieve the actual data...
        
         let submissionUUIDS = [
         "686e525b-6608-46a3-bbb4-5079d97dcded",
         "686e525b-6608-46a3-bbb4-5079d97dcdee",
         "686e525b-6608-46a3-bbb4-5079d97dcdef",
         "686e525b-6608-46a3-bbb4-5079d97dcdeg"
         ]
         
         client.fetchAvailableSubjectData(bySubjectAndSubmissionUUIDs: SubjectUUID, submissionUUIDS: submissionUUIDS, withParameters: parametersDictionary) {
         (subjectdatas: [Any]?, error: Error?) -> Void in
            
            if let err = error as? NSError {
                print(err);
                //var alertMessage = "Unable to fetch data"
                // let the user know that there is no metadata or server has returned no information....
                
            }
            
            // Right now this will just give you an empty NSArray of Subject data.
            // in next implementation, this will return either an NSArray of 
            // Subject Data information or another class defined with this data....
            //
            /*guard let subjectdatas = subjectdatas as? [MDSubject] else {
                return
            }
            */
         */
        
       // }
        
        
   
    }
    
    func doLogout() {
        dismiss(animated: true)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            if loadedForms.count == 0 {
                navigationItem.title = "Back"
                let controller = segue.destination as! CaptureImageViewController
                controller.userID = self.userID!
                controller.subjectID = self.primarySubjectId!
            }
            else{
                let form = loadedForms[indexPath.row]
                if form.formOID == "FORM1" {
                    let controller = segue.destination as! OnePageFormViewController
                    controller.formID = form.objectID
                } else if form.formOID == "FORM2" {
                    let controller = segue.destination as! MultiPageFormViewController
                    controller.formID = form.objectID
                }
            }
        }
    }   

    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Start a view controller to fill out the form. If the form is from the SDK
        // sample CRF, we open FORM1 as a one-page form and FORM2 as a multi-page
        // form to demonstrate how to handle both cases.
        if loadedForms.count == 0 {
            performSegue(withIdentifier: "CaptureImage", sender: self)
        }
        else {
            let form = loadedForms[indexPath.row]
            let sequeIdentifier = ["FORM1" : "ShowOnePageForm", "FORM2" : "ShowMultiPageForm"][form.formOID]
            performSegue(withIdentifier: sequeIdentifier!, sender: self)
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loadedForms.count == 0 ? 1 : loadedForms.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if loadedForms.count == 0 {
            cell.textLabel!.text = "Capture Image"
            return cell
        }
        let form = loadedForms[indexPath.row]
        
        cell.textLabel!.text = form.name
        return cell
    }

}

