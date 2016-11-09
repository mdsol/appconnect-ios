import UIKit

class ReviewViewController: UIViewController {

    @IBOutlet var field1Label : UILabel!
    @IBOutlet var field1Answer : UILabel!
    @IBOutlet var field2Label : UILabel!
    @IBOutlet var field2Answer : UILabel!
    @IBOutlet var field3Label : UILabel!
    @IBOutlet var field3Answer : UILabel!
    
    var form: MDForm!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let fields = form.fields
        
        // In this example app, we know exactly what fields we are expecting
        // and can cast them appropriately
        let dictionaryField = fields?[0] as! MDDictionaryField
        let dateField = fields?[1] as! MDDateTimeField
        let scaleField = fields?[2] as! MDScaleField
    
        field1Label.text = dictionaryField.label
        field1Answer.text = dictionaryField.subjectResponse.userValue
        
        field2Label.text = dateField.label
        field2Answer.text = MDRaveDateFormatter(string: dateField.dateTimeFormat).string(from: dateField.subjectResponse)
        
        field3Label.text = scaleField.label
        field3Answer.text = scaleField.subjectResponse.stringValue
    }

}
