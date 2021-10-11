//
//  HrMinPicker.swift
//  Friendication
//
//  Created by Reid Pritchard on 10/10/21.
//

import UIKit

class HrMinPicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    let hours: [Int] = Array(0...72)
    let minutes: [Int] = Array(0...59)
        
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return hours.count
        } else if component == 2{
            return minutes.count
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(hours[row])"
        } else if component == 1 {
            return "hrs"
        } else if component == 2{
            return "\(minutes[row])"
        } else {
            return "min"
        }
    }

}
