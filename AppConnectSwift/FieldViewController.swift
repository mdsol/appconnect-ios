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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fieldHeader.text = field.label
        
        dictionaryField.hidden = true
        dateField.hidden = true
        sliderField.hidden = true
        
        switch field {
        case is MDDictionaryField:
            let df = field as! MDDictionaryField
            dictionaryField.hidden = false
            dictionaryResponses = df.possibleResponses.map { (resp) -> String in
                return resp.userValue
            }
            dictionaryField.delegate = self
    
            print("field: \(field.label), \(field.objectID)")
            // Set the response to the first possible response
            //df.subjectResponse = df.possibleResponses.first! as! MDDictionaryResponse
            print("response 2 \(df.subjectResponse?.userValue)")
        case is MDDateTimeField:
            let df = field as! MDDateTimeField
        case is MDScaleField:
            let sf = field as! MDScaleField
            sliderField.hidden = false
            sliderField.minimumValue = Float(sf.minimumResponse)
            sliderField.maximumValue = Float(sf.maximumResponse)
        default:
            break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
