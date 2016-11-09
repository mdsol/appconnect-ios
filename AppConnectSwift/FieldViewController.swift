import UIKit

class FieldViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private static let responseProblems = [
        MDFieldProblem.fatalResponseMissing             : "FatalResponseMissing",
        MDFieldProblem.fatalResponseOutOfRange          : "FatalResponseOutOfRange",
        MDFieldProblem.fatalResponseUnrecognized        : "FatalResponseUnrecognized",
        MDFieldProblem.fatalResponseError               : "FatalResponseError",
        MDFieldProblem.none                             : "None",
        MDFieldProblem.concernDateResponseInDistantPast : "ConcernDateResponseInDistantPast",
        MDFieldProblem.concernDateResponseInFuture      : "ConcernDateResponseInFuture"
    ]

    @IBOutlet var fieldHeader : UILabel!
    @IBOutlet var fieldDescription : UILabel!
    @IBOutlet var dictionaryField : UIPickerView!
    @IBOutlet var dateField : UIDatePicker!
    @IBOutlet var sliderField : UISlider!
    
    var dictionaryResponses : [String] = []
    var field : MDField!
    
    // MARK: - UIViewController overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        fieldHeader.text = field.label
        
        dictionaryField.isHidden = true
        dateField.isHidden = true
        sliderField.isHidden = true

        // In this example app, we handle multiple fields in a single UIViewController. In a larger
        // application, it would make more sense to have a separate UIViewController for each field type.
        switch field {
        case is MDDictionaryField:
            dictionaryField.delegate = self
            dictionaryField.isHidden = false
        case is MDDateTimeField:
            let df = field as! MDDateTimeField
            
            var date = Date()
            if let response = df.subjectResponse {
                date = response
            }
            
            df.subjectResponse = date

            dateField.datePickerMode = UIDatePickerMode.date
            dateField.date = date
            dateField.isHidden = false
        case is MDScaleField:
            let sf = field as! MDScaleField
            
            var value = sliderField.minimumValue
            if let response = sf.subjectResponse {
                value = response.floatValue
            }
            
            sf.subjectResponse = value as NSNumber!
            
            sliderField.isHidden = false
            sliderField.minimumValue = Float(sf.minimumResponse)
            sliderField.maximumValue = Float(sf.maximumResponse)
            sliderField.value = value
        default:
            break
        }
        
        updateFieldInformation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // The UIPicker is not fully loaded in viewDidLoad, so we must
        // set its value in viewWillAppear
        if let df = field as? MDDictionaryField {
            dictionaryResponses = df.possibleResponses.map { return ($0 as AnyObject).userValue }
            
            var index = 0
            if let response = df.subjectResponse {
                index = dictionaryResponses.index(of: response.userValue)!
            }
            
            self.pickerView(self.dictionaryField, didSelectRow: index, inComponent: 0)
            dictionaryField.selectRow(index, inComponent: 0, animated: false)
        }
    }
    
    func updateFieldInformation() {
        var fieldFormat : String = ""
        
        switch field {
        case is MDDictionaryField:
            let df = field as! MDDictionaryField
            fieldFormat = df.possibleResponses.enumerated().map { (index, value) -> String in
                return "Choice \(index): \((value as AnyObject).userValue)"
            }.joined(separator: ", ")
        case is MDDateTimeField:
            let df = field as! MDDateTimeField
            fieldFormat = df.dateTimeFormat
        case is MDScaleField:
            let sf = field as! MDScaleField
            fieldFormat = "Range from \(sf.minimumResponse)-\(sf.maximumResponse)"
        default:
            break
        }
        
        let fieldInfo = [
            "FieldOID: \(field.fieldOID)",
            "Type: \(field.fieldType)",
            "Number: \(field.fieldNumber)",
            "Label: \(field.label)",
            "Format: \(fieldFormat)",
            "Problem: \(stringFromResponseProblem(field.responseProblem))"
        ]
        
        fieldDescription.text = fieldInfo.joined(separator: "\n")
    }
    

    func stringFromResponseProblem(_ problem : MDFieldProblem) -> String {
        return FieldViewController.responseProblems[problem]!
    }

    // MARK: - UISlider handling
    
    @IBAction func sliderValueDidChange(_ sender: UISlider) {
        let sf = field as! MDScaleField
        sf.subjectResponse = sender.value as NSNumber!
        updateFieldInformation()
    }
    
    
    // MARK: - UIDatePicker handling
    
    @IBAction func dateDidChange(_ sender: UIDatePicker) {
        let df = field as! MDDateTimeField
        df.subjectResponse = sender.date
        updateFieldInformation()
    }

    
    // MARK: - UIPickerView Delegate Methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dictionaryResponses.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dictionaryResponses[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let df = field as! MDDictionaryField
        df.subjectResponse = df.possibleResponses[row] as! MDDictionaryResponse
        updateFieldInformation()
    }
}
