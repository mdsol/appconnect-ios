import UIKit

class MultiPageFormViewController: UIViewController, UIPageViewControllerDelegate {

    var pageViewController: UIPageViewController?
    
    @IBOutlet var previousButton : UIButton!
    @IBOutlet var nextButton : UIButton!
    
    private var form : MDForm!
    private var stepSequencer : MDStepSequencer!
    var formID : Int64! {
        didSet {
            // Get the corresponding form from the datastore
            form = UIThreadDatastore().formWithID(formID)
            stepSequencer = MDStepSequencer(form: form)
        }
    }
    
    var modelController: ModelController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the page view controller and add it as a child view controller.
        self.pageViewController = UIPageViewController(transitionStyle: .PageCurl, navigationOrientation: .Horizontal, options: nil)
        self.pageViewController!.delegate = self
        
        // Setup field data in the ModelController
        self.modelController = ModelController()
        self.modelController.form = form
        self.pageViewController!.dataSource = self.modelController
        
        // You must use a StepSequencer to fill out the form. Calling start()
        // will clear out all the field responses and begin on the first field.
        // You could also verify whether form.canResume() returns true and call
        // resume() instead, which would preserve any previously answered field
        // and begin where the user was last.
        stepSequencer.start()

        // Setup the PageViewController with its initial ViewController
        let startingViewController: FieldViewController = self.modelController.viewControllerAtIndex(0, storyboard: self.storyboard!) as! FieldViewController
        self.pageViewController!.setViewControllers([startingViewController], direction: .Forward, animated: false, completion: {done in })
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        self.pageViewController!.view.frame = CGRectInset(self.view.bounds, 0, 40.0)
        self.pageViewController!.didMoveToParentViewController(self)

        // Set the initial state of our Previous and Next buttons
        updateButtonState()
    }
    
    func doSubmit() {
        // Once the form is completely filled out, you must call finish() to
        // stamp the form with the completion date and time. Attempting to
        // submit will fail if finish() hasn't been called. If the form requires
        // a signature, form.sign() should also be called before calling finish().
        stepSequencer.finish()
        
        // Create a hybrid client instance with which to send the responses
        let client = MDClientFactory.sharedInstance().clientOfType(MDClientType.Hybrid);
        
        // Create a new datastore to use for the request
        var datastore = MDDatastoreFactory.create()
        let f = datastore.formWithID(self.formID)
        
        // The form provided to the client method must have been loaded from the datastore provided
        client.sendResponsesForForm(f, deviceID: "fake-device-id", completion: { (error: NSError!) -> Void in
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
            
            pageViewController?.setViewControllers([newViewController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true) { done in
                self.updateButtonState()
            }
        } else {
            showDialog("Invalid Answer", message: "The answer provided for \(field.label) is not valid", completion: nil)
        }
    }
    
    @IBAction func doMoveToPrevious() {
        // Move the StepSequencer to the previous step and show the appropriate ViewController
        if stepSequencer.moveToPreviousWithResponseRequired(false) {
            let index = modelController.indexOfField(stepSequencer.currentField.objectID)
            let newViewController = modelController.viewControllerAtIndex(index, storyboard: self.storyboard!)
            
            pageViewController?.setViewControllers([newViewController!], direction: UIPageViewControllerNavigationDirection.Reverse, animated: true) { done in
                self.updateButtonState()
            }
        }
    }
    
    func updateButtonState() {
        let reviewing = (stepSequencer.state == MDStepSequencerState.Reviewing)

        previousButton.enabled = modelController.indexOfViewController(pageViewController!.viewControllers!.first!) != 0
        nextButton.setTitle(reviewing ? "Submit" : "Next", forState: UIControlState.Normal)
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        // Handle the swiping page change to keep the StepSequencer in sync with the PageViewController
        let newViewController = pageViewController.viewControllers!.first!
        let oldViewController = previousViewControllers.first!
                
        let newViewControllerIndex = modelController.indexOfViewController(newViewController)
        let oldViewControllerIndex = modelController.indexOfViewController(oldViewController)
        
        // Determine if moving forward or backward and update the StepSequencer accordingly
        if (newViewControllerIndex > oldViewControllerIndex) {
            stepSequencer.moveToNext()
        } else {
            stepSequencer.moveToPreviousWithResponseRequired(false)
        }

        updateButtonState()
    }

}

