//
//  AppConnectViewDetailController.swift
//  AppConnectSwift
//
//  Created by Richard Brett on 5/22/17.
//  Copyright © 2017 Medidata Solutions. All rights reserved.
//

import UIKit

class AppConnectViewDetailController: UIViewController, UINavigationControllerDelegate {
    @IBOutlet weak var submissionUUIDLbl: UILabel!
    @IBOutlet weak var subjectUUIDLbl: UILabel!
    @IBOutlet weak var contentTypeLbl: UILabel!
    @IBOutlet weak var fileSizeLbl: UILabel!
    @IBOutlet weak var collectedAtLbl: UILabel!
    
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
