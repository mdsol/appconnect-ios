//
//  MultiPageFormViewController.swift
//  AppConnectSample
//
//  Created by Steve Roy on 2015-12-16.
//  Copyright © 2015 Medidata Solutions. All rights reserved.
//

import UIKit

class MultiPageFormViewController: UIViewController, UIPageViewControllerDelegate {

    var pageViewController: UIPageViewController?
    
    @IBOutlet var previousButton : UIButton!
    @IBOutlet var nextButton : UIButton!
    
    private var form : MDForm!
    private var stepSequencer : MDStepSequencer!
    var formID : Int64! {
        didSet {
            form = UIThreadDatastore().formWithID(formID)
            stepSequencer = MDStepSequencer(form: form)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure the page view controller and add it as a child view controller.
        self.pageViewController = UIPageViewController(transitionStyle: .PageCurl, navigationOrientation: .Horizontal, options: nil)
        self.pageViewController!.delegate = self
        
        // Setup field data in the ModelController
        self.modelController.form = form
        self.pageViewController!.dataSource = self.modelController
        
        // Start the step sequencer
        stepSequencer.start()

        let startingViewController: FieldViewController = self.modelController.viewControllerAtIndex(0, storyboard: self.storyboard!) as! FieldViewController
        let viewControllers = [startingViewController]
        self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: {done in })

        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        
        var pageViewRect = self.view.bounds
        pageViewRect = CGRectInset(pageViewRect, 0, 40.0)
        self.pageViewController!.view.frame = pageViewRect
        
        self.pageViewController!.didMoveToParentViewController(self)

        updateButtonState()
    }
    
    func doSubmit() {
        stepSequencer.finish()
        // Create a network client instance with which to send the responses
        let client = MDClientFactory.sharedInstance().clientOfType(MDClientType.Network);
        
        // Create a new datastore to use for the request
        var datastore = MDDatastoreFactory.create()
        let f = datastore.formWithID(self.formID)
        
        // The form provided to the client method must have been loaded from the datastore provided
        client.sendResponsesForForm(f, inDatastore: datastore, deviceID: "fake-device-id", completion: { (error: NSError!) -> Void in
            if error != nil {
                self.showDialog("Error", message: "There was an error submitting the form", completion: nil)
            } else {
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.showDialog("Success", message: "Your form has been submitted.") {
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                }
            }
            // Keep the datastore alive until after the request is completed
            datastore = nil
        })
    }
    
    @IBAction func doMoveToNext() {
        let field = stepSequencer.currentField
        
        guard stepSequencer.state != MDStepSequencerState.Reviewing else {
            doSubmit()
            return
        }

        if !stepSequencer.moveToNext() {
            let alert = UIAlertController(title: "Invalid Answer", message: "The answer provided for \(field.label) is not valid.", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(
                UIAlertAction(title: "Error", style: UIAlertActionStyle.Default) { (alert: UIAlertAction) in }
            )
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let index = modelController.indexOfField(field.objectID)
            let newViewController = modelController.viewControllerAtIndex(index+1, storyboard: self.storyboard!)
            
            pageViewController?.setViewControllers([newViewController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        }
        
        updateButtonState()
    }
    
    @IBAction func doMoveToPrevious() {
        if stepSequencer.moveToPreviousWithResponseRequired(false) {
            let index = modelController.indexOfField(stepSequencer.currentField.objectID)
            let newViewController = modelController.viewControllerAtIndex(index, storyboard: self.storyboard!)
            
            pageViewController?.setViewControllers([newViewController!], direction: UIPageViewControllerNavigationDirection.Reverse, animated: true) { done in
                self.updateButtonState()
            }
        }
        
        updateButtonState()
    }
    
    func updateButtonState() {
        let reviewing = (stepSequencer.state == MDStepSequencerState.Reviewing)
        let field = stepSequencer.currentField

        if (reviewing == false) {
            previousButton.enabled = (modelController.indexOfField((field?.objectID)!) != 0)
        }
        nextButton.setTitle(reviewing ? "Submit" : "Next", forState: UIControlState.Normal)
    }

    var modelController: ModelController {
        // Return the model controller object, creating it if necessary.
        // In more complex implementations, the model controller may be passed to the view controller.
        if _modelController == nil {
            _modelController = ModelController()
        }
        return _modelController!
    }

    var _modelController: ModelController? = nil

    internal func setFormID(formID: Int64) {
        self.formID = formID
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        // Handle the swiping page change to keep the StepSequencer in sync with the PageViewController
        
        if let newViewController = pageViewController.viewControllers!.first! as? FieldViewController,
            let oldViewController = previousViewControllers.first! as? FieldViewController {
                
            let newViewControllerIndex = modelController.indexOfViewController(newViewController)
            let oldViewControllerIndex = modelController.indexOfViewController(oldViewController)
            
            if (newViewControllerIndex > oldViewControllerIndex) {
                stepSequencer.moveToNext()
            } else {
                stepSequencer.moveToPreviousWithResponseRequired(false)
            }
        }
        
        updateButtonState()
    }

}

