import UIKit

class MultiPageFormViewController: UIViewController, UIPageViewControllerDelegate {

    var pageViewController: UIPageViewController?
    
    @IBOutlet var previousButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    
    fileprivate var form: MDForm!
    fileprivate var stepSequencer: MDStepSequencer!
    var formID: Int64! {
        didSet {
            // Get the corresponding form from the datastore
            form = UIThreadDatastore().form(withID: formID)
            stepSequencer = MDStepSequencer(form: form)
        }
    }
    
    var modelController: ModelController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the page view controller and add it as a child view controller.
        pageViewController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
        pageViewController!.delegate = self
        
        // Setup field data in the ModelController
        modelController = ModelController()
        modelController.form = form
        pageViewController!.dataSource = self.modelController
        
        // You must use a StepSequencer to fill out the form. Calling start()
        // will clear out all the field responses and begin on the first field.
        // You could also verify whether form.canResume() returns true and call
        // resume() instead, which would preserve any previously answered field
        // and begin where the user was last.
        stepSequencer.start()

        // Setup the PageViewController with its initial ViewController
        let startingViewController: FieldViewController = self.modelController.viewControllerAtIndex(0, storyboard: self.storyboard!) as! FieldViewController
        pageViewController!.setViewControllers([startingViewController], direction: .forward, animated: false, completion: {done in })
        addChildViewController(self.pageViewController!)
        view.addSubview(self.pageViewController!.view)
        pageViewController!.view.frame = self.view.bounds.insetBy(dx: 0, dy: 40.0)
        pageViewController!.didMove(toParentViewController: self)

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
        let client = MDClientFactory.sharedInstance().client(of: MDClientType.hybrid);
        
        // Create a new datastore to use for the request
        var datastore = MDDatastoreFactory.create()
        let f = datastore?.form(withID: self.formID)
        
        // The form provided to the client method must have been loaded from the datastore provided
        client?.sendResponses(for: f, deviceID: "fake-device-id") { (error: Error?) -> Void in
            
            if error != nil {
                self.showDialog("Error", message: "There was an error submitting the form", completion: nil)
            } else {
                OperationQueue.main.addOperation {
                    self.showDialog("Success", message: "Your form has been submitted.") {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }

            // Keep the datastore alive until after the request is completed
            datastore = nil
        }
    }
    
    @IBAction func doMoveToNext() {
        
        // Submit the answers if the user was on the review step
        if stepSequencer.state == .reviewing {
            doSubmit()
            return
        }
        
        let field = stepSequencer.currentField!
        
        // If the field has a valid response and the StepSequencer can move forward, 
        // show the next available ViewController. Otherwise, show an error alert.
        if stepSequencer.moveToNext(), let field = stepSequencer.currentField {
            let index = modelController.indexOfField(field.objectID)
            let newViewController = modelController.viewControllerAtIndex(index+1, storyboard: self.storyboard!)
            
            pageViewController?.setViewControllers([newViewController!], direction: UIPageViewControllerNavigationDirection.forward, animated: true) { done in
                self.updateButtonState()
            }
        } else {
            showDialog("Invalid Answer", message: "The answer provided for \(field.label) is not valid", completion: nil)
        }
    }
    
    @IBAction func doMoveToPrevious() {
        // Move the StepSequencer to the previous step and show the appropriate ViewController
        if stepSequencer.moveToPrevious(withResponseRequired: false) {
            let index = modelController.indexOfField(stepSequencer.currentField.objectID)
            let newViewController = modelController.viewControllerAtIndex(index, storyboard: self.storyboard!)
            
            pageViewController?.setViewControllers([newViewController!], direction: UIPageViewControllerNavigationDirection.reverse, animated: true) { done in
                self.updateButtonState()
            }
        }
    }
    
    func updateButtonState() {
        let reviewing = (stepSequencer.state == MDStepSequencerState.reviewing)

        previousButton.isEnabled = modelController.indexOfViewController(pageViewController!.viewControllers!.first!) != 0
        nextButton.setTitle(reviewing ? "Submit" : "Next", for: UIControlState())
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        // Handle the swiping page change to keep the StepSequencer in sync with the PageViewController
        let newViewController = pageViewController.viewControllers!.first!
        let oldViewController = previousViewControllers.first!
                
        let newViewControllerIndex = modelController.indexOfViewController(newViewController)
        let oldViewControllerIndex = modelController.indexOfViewController(oldViewController)
        
        // Determine if moving forward or backward and update the StepSequencer accordingly
        if (newViewControllerIndex > oldViewControllerIndex) {
            stepSequencer.moveToNext()
        } else {
            stepSequencer.moveToPrevious(withResponseRequired: false)
        }

        updateButtonState()
    }

}

