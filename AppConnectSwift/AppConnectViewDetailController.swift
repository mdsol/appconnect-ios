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
    @IBOutlet weak var dataTextLabel: UILabel!
    @IBOutlet weak var dataImageView: UIImageView!
    
    var submission: MDSubmission!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Submission Details"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        submissionUUIDLbl.text = submission.submissionUUID
        subjectUUIDLbl.text = submission.subjectUUID
        contentTypeLbl.text = submission.contentType
        fileSizeLbl.text = submission.fileSize
        collectedAtLbl.text = dateFormatter.string(from: submission.submissionCollectedAt)
        
        dataImageView.isHidden = true
        dataTextLabel.isHidden = true
    }
    
    @IBAction func fetchDataAction(_ sender: Any) {
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
        
        guard let submissionUUID = submission.submissionUUID else {
            return
        }
        
        let submissionsArray = [submissionUUID];

        client.fetchSubmissions(for: subject, withSubmissionUUIDS: submissionsArray, withParameters: parametersDictionary) { (response, error) in
            if let submissions = response {
                self.handleDataFetchResponse(submissions: submissions, error: error)
            }
        }
    }
    
    private func handleDataFetchResponse(submissions: [MDSubmission], error: Error?) -> Void {
        if let err = error as NSError? {
            print(err);
        } else {
            guard let data = submissions.first else {
                return
            }
            
            if data.contentType == "application/json",
                let text = String(data: submissions.first!.data, encoding: .utf8) {
                
                DispatchQueue.main.async {
                    self.dataTextLabel.text = text
                    self.dataTextLabel.isHidden = false
                }
            } else if data.contentType == "image/jpeg" {
                let image = UIImage(data: data.data)
                self.dataImageView.image = image
                self.dataImageView.isHidden = false
                
            }
        }
    }
}
