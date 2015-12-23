//
//  FormListViewController.swift
//  AppConnectSwift
//
//  Created by Nolan Carroll on 12/18/15.
//  Copyright © 2015 Medidata Solutions. All rights reserved.
//

import UIKit

class FormListViewController: UITableViewController {

    var objects = [AnyObject]()
    var userID : Int64!
    var datastore : MDDatastore!
    
    var spinner : UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.datastore = MDDatastoreFactory.create()

        spinner = UIActivityIndicatorView.init(activityIndicatorStyle: .Gray)
        spinner.center = CGPointMake(160, 240);
        spinner.hidesWhenStopped = true;
        self.view.addSubview(spinner)
        spinner.startAnimating()
        
        let backButton = UIBarButtonItem(title: "Log Out", style: UIBarButtonItemStyle.Plain, target: self, action: "doLogout")
        self.navigationItem.setLeftBarButtonItem(backButton, animated: true)

        loadForms()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        populateForms()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    internal func setUserID(userID: Int64) {
        self.userID = userID
    }
    
    func loadForms() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            let datastore = MDDatastoreFactory.create()
            let clientFactory = MDClientFactory.sharedInstance()
            let client = clientFactory.clientOfType(MDClientType.Network);
            let user = datastore.userWithID(Int64(self.userID))

            // TODO: - load the forms sequentially (or ensure that populateForms is called only once all have loaded)
            client.loadSubjectsForUser(user, inDatastore: datastore) { (subjects: [AnyObject]!, error: NSError!) -> Void in
                if let error = error {
                    print("error: \(error.localizedFailureReason), \(error.localizedDescription), \(error.code)")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.spinner.stopAnimating()
                    })
                    return
                }
                for subject in subjects as! [MDSubject]! {
                    client.loadFormsForSubject(subject, inDatastore: datastore) { (forms: [AnyObject]!, error: NSError!) -> Void in
                        if subject.isEqualToSubject(subjects.last as! MDSubject) {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.populateForms()
                                self.spinner.stopAnimating()
                            }
                        }
                    }
                }
            }
        }
    }

    func populateForms() {
        var forms : [MDForm]
        
        if let user = self.datastore.userWithID(Int64(self.userID)) {
            let subjects = user.subjects as! [MDSubject]
            forms = subjects.map({ (subject : MDSubject) -> [MDForm] in
                self.datastore.availableFormsForSubjectWithID(subject.objectID) as! [MDForm]
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
                controller.setFormID(form.objectID)
            } else if form.formOID == "FORM2" {
                let controller = segue.destinationViewController as! OnePageFormViewController
                controller.setFormID(form.objectID)
            }
        }
    }

    // MARK: - Table View
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let form = objects[indexPath.row] as! MDForm
        let sequeIdentifier = ["FORM1" : "ShowOnePageForm", "FORM2" : "ShowOnePageForm"][form.formOID]
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

