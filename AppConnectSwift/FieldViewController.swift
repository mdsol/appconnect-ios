//
//  FieldViewController.swift
//  AppConnectSwift
//
//  Created by Nolan Carroll on 12/22/15.
//  Copyright © 2015 Medidata Solutions. All rights reserved.
//

import UIKit

class FieldViewController: UIViewController {

    @IBOutlet var fieldHeader : UILabel!
        
    var field : MDField!
    var fieldID : Int64! {
        didSet {
            let datastore = (UIApplication.sharedApplication().delegate as! AppDelegate).UIDatastore!
            field = datastore.fieldWithID(fieldID)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fieldHeader.text = field.header
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
