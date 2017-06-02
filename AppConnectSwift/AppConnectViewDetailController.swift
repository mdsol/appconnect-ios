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
    
    var submission: MDSubmission!
    
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


        client.fetchAvailableSubjectData(bySubjectAndSubmissionUUIDs: subject, submissionUUIDS: submissionsArray, withParameters: parametersDictionary) { (response, error) in
            if let submissions = response as? [MDSubmission] {
                self.handleDataFetchResponse(submissions: submissions, error: error)
            }
        }
    }
    
    private func handleDataFetchResponse(submissions: [MDSubmission], error: Error?) -> Void {
        if let err = error as NSError? {
            print(err);
        } else {
            DispatchQueue.main.async {
                print("Data: ")
                print(String(data: submissions.first!.data, encoding: .utf8) ?? "missing")
                // TODO: Get data, put in textview or show picture
            }
        }
    }
    
    
    
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
