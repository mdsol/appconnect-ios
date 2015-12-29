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

        let startingViewController: FieldViewController = self.modelController.viewControllerAtIndex(0, storyboard: self.storyboard!)!
        let viewControllers = [startingViewController]
        self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: {done in })

        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        
        var pageViewRect = self.view.bounds
        pageViewRect = CGRectInset(pageViewRect, 40.0, 40.0)
        self.pageViewController!.view.frame = pageViewRect
        
        self.pageViewController!.didMoveToParentViewController(self)

        // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
        self.view.gestureRecognizers = self.pageViewController!.gestureRecognizers
        

        
        updateButtonState()
    }
    
    @IBAction func doMoveToNext() {
        let field = stepSequencer.currentField

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
            
            pageViewController?.setViewControllers([newViewController!], direction: UIPageViewControllerNavigationDirection.Reverse, animated: true, completion: nil)
        }
    }
    
    func updateButtonState() {
        let reviewing = (stepSequencer.state == MDStepSequencerState.Reviewing)
        let field = stepSequencer.currentField

        previousButton.enabled = (modelController.indexOfField(field.objectID) != 0)
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
        
        // TODO: handle going back as well
        stepSequencer.moveToNext()
        updateButtonState()
    }

}

