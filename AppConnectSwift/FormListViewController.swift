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
    
    var spinner : UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            var datastore = MDDatastoreFactory.create()
            let clientFactory = MDClientFactory.sharedInstance()
            let client = clientFactory.clientOfType(MDClientType.Network);
            let user = datastore.userWithID(Int64(self.userID))

            var loadedSubjects : [MDSubject] = []
            // TODO: - load the forms sequentially (or ensure that populateForms is called only once all have loaded)
            client.loadSubjectsForUser(user, inDatastore: datastore) { (subjects: [AnyObject]!, error: NSError!) -> Void in
                guard error == nil else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.spinner.stopAnimating()
                    })
                    return
                }

                for subject in subjects as! [MDSubject]! {
                    client.loadFormsForSubject(subject, inDatastore: datastore) { (forms: [AnyObject]!, error: NSError!) -> Void in
                        loadedSubjects.append(subject)
                        if loadedSubjects.count == subjects.count {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.populateForms()
                                self.spinner.stopAnimating()
                                datastore = nil
                            }
                        }
                    }
                }
            }
        }
    }

    func populateForms() {
        var forms : [MDForm]
        let datastore = (UIApplication.sharedApplication().delegate as! AppDelegate).UIDatastore!
        if let user = datastore.userWithID(Int64(self.userID)) {
            let subjects = user.subjects as! [MDSubject]
            forms = subjects.map({ (subject : MDSubject) -> [MDForm] in
                datastore.availableFormsForSubjectWithID(subject.objectID) as! [MDForm]
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

