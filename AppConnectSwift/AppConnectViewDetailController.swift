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
    
    var detailItem: MDSubmission! {
        didSet {
            // Update the view.
            //self.configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.configureView()
        
        self.navigationItem.title = "Submission Details"

    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            
            print(detail.submissionUUID)
            print(detail.subjectUUID)
            print(detail.contentType)
            print(detail.fileSize)
            print(detail.submissionCollectedAt)
            
            if let label = self.submissionUUIDLbl {
                label.text = detail.submissionUUID
            }
            if let label1 = self.subjectUUIDLbl {
                label1.text = detail.subjectUUID
            }
            if let label2 = self.contentTypeLbl {
                label2.text = detail.contentType
            }
            if let label3 = self.fileSizeLbl {
                label3.text = detail.fileSize
            }
            if let label4 = self.collectedAtLbl {
                
                let date = detail.submissionCollectedAt
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                label4.text = dateFormatter.string(from: date!)

            }
           
        }
    }

}
