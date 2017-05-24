//
//  AppConnectViewController.swift
//  AppConnectSwift
//
//  Created by Richard Brett on 5/22/17.
//  Copyright © 2017 Medidata Solutions. All rights reserved.
//
import UIKit

class AppConnectViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate {
    
    var userID : Int64!
    var primarySubjectId : Int64!
    var subjectID: Int64!
    var loadedSubmissions : [MDSubmission] = []
    
    @IBOutlet weak var fromDateTxtField: UITextField!
    
    @IBOutlet weak var toDateTxtField: UITextField!
    
    @IBOutlet weak var submissionsTxtField: UITextField!
    
    @IBOutlet weak var SortTxtField: UITextField!
   
    @IBOutlet weak var paginationLbl: UILabel!
    
    // Data model: These strings will be the data for the table view cells
    //var subids: [String] = []
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    
    
    @IBOutlet weak var tableView: UITableView!
    var spinner : UIActivityIndicatorView!
    
    @IBOutlet weak var dateSearch: UIButton!
    @IBOutlet weak var submissionSearch: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Keep the confirm label hidden till email text fields submitted are satisfying criteria
        loadSubjects();
        
        // load default strings.
        fromDateTxtField.text = "2017-05-16"
        toDateTxtField.text = "2017-05-19"
        submissionsTxtField.text = "afa06f82-d844-4820-a699-df1bbff79d3b"

    }
    
    
    func loadSubjects() {
        let clientFactory = MDClientFactory.sharedInstance()
        let client = clientFactory.client(of: MDClientType.hybrid);
        
        let datastore = (UIApplication.shared.delegate as! AppDelegate).UIDatastore!
        let user = datastore.user(withID: self.userID)
        
        client.loadSubjects(for: user) { (subjects: [Any]?, error: Error?) -> Void in
            guard error == nil, let subjects = subjects as? [MDSubject] else {
                return
            }
            
            if let primarySubject = subjects.first {
                self.primarySubjectId = primarySubject.objectID
                print(self.primarySubjectId);
            }
        }
    }

    @IBAction func doSearch(_ sender: Any) {
        
        // the following data is sample fetch only
        // used to illustrate how the appconnect 2.0 calls are supposed to work.
        let clientFactory = MDClientFactory.sharedInstance()
        let client = clientFactory.client(of: MDClientType.network)
        
        print(self.primarySubjectId)
        print(self.userID);
        self.paginationLbl.text = ""
        
        
        let datastore = (UIApplication.shared.delegate as! AppDelegate).UIDatastore!
        let subject = datastore.subject(withID: self.primarySubjectId)
        
        // take an arbitrary subjectUUID
        // let SubjectUUID = "045e6689-b85e-4fad-bbb1-b4a34ab75d64";
        // https://epro-sandbox.imedidata.net/api/v2/subject_submissions.json?subject_uuid=045e6689-b85e-4fad-bbb1-b4a34ab75d64&study_auth_token=7591e9775049f126709657a968784082&start_date=2017-05-16T17:37:11.627Z&end_date=2017-05-19T17:37:11.627Z
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSZ"
        
        guard var startDateStr = fromDateTxtField.text, var endDateStr = toDateTxtField.text else {
            return
        }
        
        let dateEnd = "T00:00:00.000Z"
        startDateStr.append(dateEnd)
        endDateStr.append(dateEnd)
        
        let startDate = formatter.date(from: startDateStr)
        let endDate = formatter.date(from: endDateStr)

        var parametersDictionary = [String:String]();
        
        if let sortParam = SortTxtField.text, ["asc", "desc"].contains(sortParam) {
            parametersDictionary["sort_order"] = sortParam
        }
        
        client.fetchAvailableSubjectMetadataWithSubject(withDateRange: subject, from: startDate, to: endDate, withParameters: parametersDictionary) {
            (appConnectResponse: MDAppConnectResponse?, error: Error?) -> Void in

            if let err = error as NSError? {
                print(err);
                // var alertMessage = "Unable to fetch metadata"
                // let the user know that there is no metadata or server has returned no information....
                // we will return various error codes along with the error cause...
                
            } else {
                if let pagination = appConnectResponse?.pagination {
                    print(pagination)
                    self.paginationLbl.text = pagination
                }
                
                self.loadedSubmissions.removeAll()
                if let submissions = appConnectResponse?.submissions as? [MDSubmission] {
                    self.loadedSubmissions.append(contentsOf: submissions)
                }

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    


    @IBAction func doSearchSubmissions(_ sender: Any) {
        
        // the following data is sample fetch only
        // used to illustrate how the appconnect 2.0 calls are supposed to work.
        let clientFactory = MDClientFactory.sharedInstance()
        let client = clientFactory.client(of: MDClientType.network);
        
        let datastore = (UIApplication.shared.delegate as! AppDelegate).UIDatastore!
        let subject = datastore.subject(withID: self.primarySubjectId)
        self.paginationLbl.text = ""
        
        // take an arbitrary subjectUUID
        // let SubjectUUID = "045e6689-b85e-4fad-bbb1-b4a34ab75d64";
        // https://epro-sandbox.imedidata.net/api/v2/subject_submissions.json?subject_uuid=045e6689-b85e-4fad-bbb1-b4a34ab75d64&study_auth_token=7591e9775049f126709657a968784082&start_date=2017-05-16T17:37:11.627Z&end_date=2017-05-19T17:37:11.627Z
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSZ";
        
        
        var parametersDictionary = [String:String]();
        
        if let sortParam = SortTxtField.text, ["asc", "desc"].contains(sortParam) {
            parametersDictionary["sort_order"] = sortParam
        }
        
        // make the call to fetch all available records in this given time interval
        // the results will be passed back as an NSDictionary
        // in this stubbed method it will be ["SubjectUUID", "TestSubjectUUID"];
        // when connected to a live server it will be something like
        //
        let submissionsArray = [submissionsTxtField.text];
        
        client.fetchAvailableSubjectMetadata(bySubjectAndSubmissionUUIDs: subject, submissionUUIDS:submissionsArray, withParameters: parametersDictionary) {
            (appConnectResponse: MDAppConnectResponse?, error: Error?) -> Void in
            
            if let err = error as NSError? {
                print(err);
                // var alertMessage = "Unable to fetch metadata"
                // let the user know that there is no metadata or server has returned no information....
                // we will return various error codes along with the error cause...
                
            } else {
                if let pagination = appConnectResponse?.pagination {
                    print(pagination)
                    self.paginationLbl.text = pagination
                }
                
                self.loadedSubmissions.removeAll()
                if let submissions = appConnectResponse?.submissions as? [MDSubmission] {
                    self.loadedSubmissions.append(contentsOf: submissions)
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "appConnectDetail", let controller = segue.destination as? AppConnectViewDetailController {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let submission = self.loadedSubmissions[indexPath.row]
                controller.detailItem = submission
            }
        }
    }
    
    // MARK: - Table View
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
  
        print("You tapped cell number \(indexPath.row).")
        let sequeIdentifier = "appConnectDetail"
        performSegue(withIdentifier: sequeIdentifier, sender: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.loadedSubmissions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        // Register the table view cell class and its reuse id
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        let submission = self.loadedSubmissions[indexPath.row]
        
        // set the text from the data model
        cell.textLabel?.text = submission.submissionUUID
        
        return cell
    }



}
