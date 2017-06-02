//
//  AppConnectViewDetailController.swift
//  AppConnectSwift
//
//  Created by Richard Brett on 5/22/17.
//  Copyright © 2017 Medidata Solutions. All rights reserved.
//

import UIKit

class AppConnectViewDetailController: UIViewController, UINavigationControllerDelegate {
    
    var subjectID: Int64!
    
    @IBOutlet weak var submissionUUIDLbl: UILabel!
    @IBOutlet weak var subjectUUIDLbl: UILabel!
    @IBOutlet weak var contentTypeLbl: UILabel!
    @IBOutlet weak var fileSizeLbl: UILabel!
    @IBOutlet weak var collectedAtLbl: UILabel!
    
    @IBOutlet weak var fetchDataBtn: UIButton!
    @IBOutlet weak var fetchDataTxtView: UITextView!
    
    @IBOutlet weak var fetchDataImageView: UIImageView!
    
    @IBAction func fetchDataAction(_ sender: Any) {
        
        // the following data is sample fetch only
        // used to illustrate how the appconnect 2.0 calls are supposed to work.
        let clientFactory = MDClientFactory.sharedInstance()
        let client = clientFactory.client(of: MDClientType.network);
        
        let datastore = (UIApplication.shared.delegate as! AppDelegate).UIDatastore!
        let subject = datastore.subject(withID: self.subjectID)

        var parametersDictionary = [String:String]();
        parametersDictionary["sort_order"] = "desc"
        
        // make the call to fetch all available records in this given time interval
        // the results will be passed back as an NSDictionary
        // in this stubbed method it will be ["SubjectUUID", "TestSubjectUUID"];
        // when connected to a live server it will be something like
        let submissionsArray = [submission.submissionUUID];


        
        client.fetchAvailableSubjectData(bySubjectAndSubmissionUUIDs: subject, submissionUUIDS: submissionsArray, withParameters: parametersDictionary) {
            (response, error) in
            self.handleFetchMetadataResponse(appConnectResponse: response, error: error)
        }
        
    }
    
    private func handleFetchMetadataResponse(appConnectResponse: MDAppConnectResponse?, error: Error?) -> Void {
        if let err = error as NSError? {
            print(err);
            // var alertMessage = "Unable to fetch metadata"
            // let the user know that there is no metadata or server has returned no information....
            // we will return various error codes along with the error cause...
            
        } else {
            if let submissions = appConnectResponse?.submissions as? [MDSubmission] {
                //self.loadedSubmissions.append(contentsOf: submissions)
            }
            
            DispatchQueue.main.async {
            }
        }
    }
    
    
    var submission: MDSubmission!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.configureView()
        
        self.navigationItem.title = "Submission Details"
    }
    
    func configureView() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        submissionUUIDLbl.text = submission.submissionUUID
        subjectUUIDLbl.text = submission.subjectUUID
        contentTypeLbl.text = submission.contentType
        fileSizeLbl.text = submission.fileSize
        collectedAtLbl.text = dateFormatter.string(from: submission.submissionCollectedAt)
    }
}
