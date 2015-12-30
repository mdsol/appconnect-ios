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
    
    var _modelController: ModelController? = nil
    var modelController: ModelController {
        // Return the model controller object, creating it if necessary.
        // In more complex implementations, the model controller may be passed to the view controller.
        if _modelController == nil {
            _modelController = ModelController()
        }
        return _modelController!
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

        // Setup the PageViewController with its initial ViewController
        let startingViewController: FieldViewController = self.modelController.viewControllerAtIndex(0, storyboard: self.storyboard!) as! FieldViewController
        let viewControllers = [startingViewController]
        self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: {done in })
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        var pageViewRect = self.view.bounds
        pageViewRect = CGRectInset(pageViewRect, 0, 40.0)
        self.pageViewController!.view.frame = pageViewRect
        self.pageViewController!.didMoveToParentViewController(self)

        // Set the initial state of our Previous and Next buttons
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
        
        // Submit the answers if the user was on the review step
        if stepSequencer.state == MDStepSequencerState.Reviewing {
            doSubmit()
            return
        }
        
        // If the field has a valid response and the StepSequencer can move forward, 
        // show the next available ViewController. Otherwise, show an error alert.
        if stepSequencer.moveToNext() {
            let index = modelController.indexOfField(field.objectID)
            let newViewController = modelController.viewControllerAtIndex(index+1, storyboard: self.storyboard!)
            
            pageViewController?.setViewControllers([newViewController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        } else {
            showDialog("Invalid Answer", message: "The answer provided for \(field.label) is not valid", completion: nil)
        }
        
        updateButtonState()
    }
    
    @IBAction func doMoveToPrevious() {
        // Move the StepSequencer to the previous step and show the appropriate ViewController
        if stepSequencer.moveToPreviousWithResponseRequired(false) {
            let index = modelController.indexOfField(stepSequencer.currentField.objectID)
            let newViewController = modelController.viewControllerAtIndex(index, storyboard: self.storyboard!)
            
            pageViewController?.setViewControllers([newViewController!], direction: UIPageViewControllerNavigationDirection.Reverse, animated: true, completion: nil)
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

