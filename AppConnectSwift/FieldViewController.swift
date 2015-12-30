//
//  FieldViewController.swift
//  AppConnectSwift
//
//  Created by Nolan Carroll on 12/22/15.
//  Copyright © 2015 Medidata Solutions. All rights reserved.
//

import UIKit

class FieldViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var fieldHeader : UILabel!
    @IBOutlet var dictionaryField : UIPickerView!
    @IBOutlet var dateField : UIDatePicker!
    @IBOutlet var sliderField : UISlider!
    
    var dictionaryResponses : [String] = []
    var field : MDField!
    
    // MARK: - UIViewController overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        fieldHeader.text = field.label
        
        dictionaryField.hidden = true
        dateField.hidden = true
        sliderField.hidden = true
        
        // In this example app, we handle multiple fields in a single UIViewController. In a larger
        // application, it would make more sense to have a separate UIViewController for each field type.
        switch field {
        case is MDDictionaryField:
            let df = field as! MDDictionaryField
            dictionaryField.delegate = self
            dictionaryField.hidden = false
            dictionaryResponses = df.possibleResponses.map { return $0.userValue }

            var index = 0
            if let response = df.subjectResponse {
                index = dictionaryResponses.indexOf(response.userValue)!
            }
            
            // Set the initial value in the picker
            dictionaryField.selectRow(index, inComponent: 0, animated: true)
            self.pickerView(self.dictionaryField, didSelectRow: index, inComponent: 0)
        case is MDDateTimeField:
            let df = field as! MDDateTimeField
            dateField.hidden = false
            
            var date = NSDate()
            if let response = df.subjectResponse {
                date = response
            }
            
            df.subjectResponse = date
            dateField.date = date
        case is MDScaleField:
            let sf = field as! MDScaleField
            
            var value = sliderField.minimumValue
            if let response = sf.subjectResponse {
                value = response.floatValue
            }
            
            sf.subjectResponse = value
            sliderField.value = value
            
            sliderField.hidden = false
            sliderField.minimumValue = Float(sf.minimumResponse)
            sliderField.maximumValue = Float(sf.maximumResponse)
        default:
            break
        }
    }
    
    // MARK: - UISlider handling
    
    @IBAction func sliderValueDidChange(sender: UISlider) {
        let sf = field as! MDScaleField
        sf.subjectResponse = sender.value
    }
    
    
    // MARK: - UIDatePicker handling
    
    @IBAction func dateDidChange(sender: UIDatePicker) {
        let df = field as! MDDateTimeField
        df.subjectResponse = sender.date
    }

    
    // MARK: - UIPickerView Delegate Methods
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dictionaryResponses.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dictionaryResponses[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let df = field as! MDDictionaryField
        df.subjectResponse = df.possibleResponses[row] as! MDDictionaryResponse
    }
}
