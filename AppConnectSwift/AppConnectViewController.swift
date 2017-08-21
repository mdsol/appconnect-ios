//
//  AppConnectViewController.swift
//  AppConnectSwift
//
//  Created by Richard Brett on 5/22/17.
//  Copyright © 2017 Medidata Solutions. All rights reserved.
//
import UIKit

class AppConnectViewController: UIViewController, UINavigationControllerDelegate {
    var subjectID: Int64!
    var loadedSubmissions : [MDSubmission] = []
    
    @IBOutlet weak var fromDateTxtField: UITextField!
    @IBOutlet weak var toDateTxtField: UITextField!
    @IBOutlet weak var submissionsTxtField: UITextField!
    @IBOutlet weak var SortTxtField: UITextField!
    @IBOutlet weak var paginationLbl: UILabel!
    
    let cellReuseIdentifier = "submissionMetadataCell"
    
    @IBOutlet weak var tableView: UITableView!
    var spinner : UIActivityIndicatorView!
    
    @IBOutlet weak var dateSearch: UIButton!
    @IBOutlet weak var submissionSearch: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fromDateTxtField.text = "2017-05-25"
        toDateTxtField.text = "2017-06-30"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    }

    @IBAction func doSearch(_ sender: Any) {
        
        let clientFactory = MDClientFactory.sharedInstance()
        let client = clientFactory.client(of: MDClientType.network)
        
        print(self.subjectID)
        self.paginationLbl.text = ""
        
        
        let datastore = (UIApplication.shared.delegate as! AppDelegate).UIDatastore!
        let subject = datastore.subject(withID: self.subjectID)
        
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
        
        client.fetchSubmissionDetails(for: subject, from: startDate, to: endDate, withParameters: parametersDictionary) { (response, error) in
            self.handleFetchMetadataResponse(appConnectResponse: response, error: error)
        }
    }

    @IBAction func doSearchSubmissions(_ sender: Any) {
        let clientFactory = MDClientFactory.sharedInstance()
        let client = clientFactory.client(of: MDClientType.network);
        
        let datastore = (UIApplication.shared.delegate as! AppDelegate).UIDatastore!
        let subject = datastore.subject(withID: self.subjectID)
        self.paginationLbl.text = ""
        
        var parametersDictionary = [String:String]();
        
        if let sortParam = SortTxtField.text, ["asc", "desc"].contains(sortParam) {
            parametersDictionary["sort_order"] = sortParam
        }
        
        guard let submissionUUID = submissionsTxtField.text else {
            return
        }
        
        let submissionsArray = [submissionUUID];
        
        client.fetchSubmissionDetails(for: subject, withSubmissionUUIDs: submissionsArray, withParameters: parametersDictionary) { (response, error) in
            self.handleFetchMetadataResponse(appConnectResponse: response, error: error)
        }
    }
    
    private func handleFetchMetadataResponse(appConnectResponse: MDSubmissionDetailsResponse?, error: Error?) -> Void {
        if let err = error as NSError? {
            print(err);
            
        } else {
            if let pagination = appConnectResponse?.pagination {
                print(pagination)
                self.paginationLbl.text = pagination
            }
            
            self.loadedSubmissions.removeAll()
            if let submissions = appConnectResponse?.submissions {
                self.loadedSubmissions.append(contentsOf: submissions)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "appConnectDetail", let controller = segue.destination as? AppConnectViewDetailController {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let submission = self.loadedSubmissions[indexPath.row]
                controller.submission = submission
                controller.subjectID = self.subjectID
            }
        }
    }
}


// MARK: - UITableViewDataSource, UITableViewDelegate

extension AppConnectViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        let submission = self.loadedSubmissions[indexPath.row]
        
        // set the text from the data model
        cell.textLabel?.text = submission.submissionUUID
        
        return cell
    }
}
