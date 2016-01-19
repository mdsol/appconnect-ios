import UIKit

class OnePageFormViewController: UIViewController {
    var dataObject: String = ""
    
    private var form : MDForm!
    var formID : Int64! {
        didSet {
            // Get the corresponding form from the datastore
            form = UIThreadDatastore().formWithID(formID)
        }
    }
    
    @IBOutlet var formTitle : UILabel!
    
    @IBOutlet var field1Label : UILabel!
    @IBOutlet var field2Label : UILabel!
    @IBOutlet var field3Label : UILabel!
    
    @IBOutlet var field1Response : UITextField!
    @IBOutlet var field2Response : UITextField!
    @IBOutlet var field3Response : UITextField!
    
    @IBOutlet var submit : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        formTitle.text = form.name
        
        // Find the fields we know exist in the form and populate the view with
        // their properties. This is hardcoded for the specific case where we
        // know in advance that TEXTFIELD1 is a TextField and the other two are
        // NumericFields. If you don't know in advance what the fields are going
        // to be, look at MultiPageFormViewController instead.
        for field in form.fields {
            switch field.fieldOID {
            case "TEXTFIELD1":
                let tf = field as! MDTextField
                field1Label.text = tf.label
                field1Response.placeholder = "Max Length: \(tf.maximumResponseLength)"
            case "NUMBERS":
                let nf = field as! MDNumericField
                field2Label.text = nf.label
                field2Response.placeholder = numericFieldFormat(nf);
            case "NUMERICVALUE":
                let nf = field as! MDNumericField
                field3Label.text = nf.label
                field3Response.placeholder = numericFieldFormat(nf);
            default:
                break
            }
        }
    }
    
    func numericFieldFormat(field : MDNumericField) -> String {
        // This shows how to inspect a NumericField to discover the format of
        // the response it expects. Each field type has specific methods to
        // discover such properties. See the documentation for more information.
        let components = [
            String(field.maximumResponseIntegerCount),
            field.responseIntegerCountRequired ? "+" : "",
            ".",
            String(field.maximumResponseDecimalCount),
            field.responseDecimalCountRequired ? "+" : ""
        ]
        
        return components.joinWithSeparator("")
    }

    @IBAction func doSubmit(sender: AnyObject) {
        guard validateResponses() else {
            return
        }
        
        // Create a network client instance with which to send the responses
        let client = MDClientFactory.sharedInstance().clientOfType(MDClientType.Network);
        
        // Babbage objects can't be shared between threads so you must pass
        // them around by ID instead and the receiving code can get its own
        // copy from its own datastore
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
    
    func validateResponses() -> Bool {
        let decimal = ".".utf16.first!
        
        // You must use a StepSequencer to fill out the form. This is
        // hardcoded for the specific case where we know in advance that
        // FIELD1 is a TextField and the other two are NumericFields. If
        // you don't know in advance what the fields are going to be,
        // look at MultiPageFormViewController.
        let sequencer = MDStepSequencer(form: self.form)
        sequencer.start()
        
        // Fill out the response for FIELD1, which we know is a NumericField
        let field1 = sequencer.currentField as! MDTextField
        field1.subjectResponse = field1Response.text
        if field1.responseProblem != MDFieldProblem.None {
            showDialog("Wrong Format", message: "The \"Text Field 1\" field is not the correct format.", completion:nil)
            return false
        }
        
        sequencer.moveToNext()
        
        // Fill out the response for FIELD2, which we know is a TextField
        let field2 = sequencer.currentField as! MDNumericField
        field2.subjectResponse = field2.responseFromString(field2Response.text, decimalSeparator: decimal)
        if field2.responseProblem != MDFieldProblem.None {
            showDialog("Wrong Format", message: "The \"Numbers\" field is not the correct format.", completion:nil)
            return false
        }
        
        sequencer.moveToNext()
        
        // Fill out the response for FIELD3, which we know is a NumericField
        let field3 = sequencer.currentField as! MDNumericField
        field3.subjectResponse = field3.responseFromString(field3Response.text, decimalSeparator: decimal)
        if field3.responseProblem != MDFieldProblem.None {
            showDialog("Wrong Format", message: "The \"Numeric Value\" field is not the correct format.", completion:nil)
            return false
        }
        
        // The sequencer must be in the reviewing state to be able to finish the form
        sequencer.moveToNext()
        
        if sequencer.state != MDStepSequencerState.Reviewing{
            showDialog("Wrong Format", message: "There are more fields to be filled out in this form", completion:nil)
            return false
        }
        
        // Once the form is completely filled out, you must call finish() to
        // stamp the form with the completion date and time. Attempting to
        // submit will fail if finish() hasn't been called. If the form requires
        // a signature, form.sign() should also be called before calling finish().
        if !sequencer.finish() {
            showDialog("No Signature", message:"The form requests a signature, which is not supported by the sample app", completion:nil)
            return false
        }
        
        return true
    }
}

