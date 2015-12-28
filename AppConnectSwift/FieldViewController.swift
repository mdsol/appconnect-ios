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
        
    private var field : MDField!
    var fieldID : Int64! {
        didSet {
            field = UIThreadDatastore().fieldWithID(fieldID)
        }
    }
    
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
                print("response: \(resp.userValue)")
                return resp.userValue
            }
            dictionaryField.delegate = self
        case is MDDateTimeField:
            dateField.hidden = false
        case is MDScaleField:
            sliderField.hidden = false
        default:
            break
        }
        // Do any additional setup after loading the view.
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
}
