//
//  TableViewController.swift
//  Friendication
//
//  Created by Reid Pritchard on 9/16/21.
//

import UIKit


class NewMedicationViewController: UITableViewController {
    var med_manager: MedicationManager!
    @IBOutlet var table_view: UITableView!
    
    @IBOutlet weak var medication_name: UITextField!
    @IBOutlet weak var dose_stepper: UIStepper!
    @IBOutlet weak var dose_amount: UILabel!
    @IBOutlet weak var scheduled_switch: UISwitch!
    @IBOutlet weak var dose_freq: UILabel!
    @IBOutlet weak var notification_switch: UISwitch!
    
    // For picker subView
    @IBOutlet weak var freq_text_field: UITextField!
    var freq_picker: UIPickerView!
    // Picker Stored Values
    let hours: [Int] = Array(0...72)
    let minutes: [Int] = Array(0...59)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set navigation items
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBarButtonTapped))
        navigationItem.rightBarButtonItem?.isEnabled = false

        //  Setup picker view
        freq_picker = UIPickerView()
                
        freq_picker.delegate = self
        freq_picker.dataSource = self

        freq_text_field.inputView = freq_picker
        
        
        // set default values
        dose_amount.text = "\(Int(dose_stepper.value))mg"
        freq_text_field.text = "\(Int(freq_picker.selectedRow(inComponent: 0)))hr \(Int(freq_picker.selectedRow(inComponent: 2)))min"
        
        // setup hide keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("newMed prepare")
        if segue.identifier == "unwindToTracker" {
            if let destination = segue.destination as? MedicationViewController {
                destination.med_manager = self.med_manager
            }
        }
    }
    
    @IBAction func med_name_done(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func medication_name_edited(_ sender: Any) {
        navigationItem.rightBarButtonItem?.isEnabled = self.medication_name.text?.count ?? 0 > 0
    }
    
    @IBAction func dose_stepper_tapped(_ sender: UIStepper) {
//        print("dose stepper tapped")
        let new_val = Int(sender.value)
        self.dose_amount.text = "\(new_val)mg"
    }
    
    @IBAction func toggled_scheduled(_ sender: Any) {
        self.table_view.reloadData()
    }
    
    @IBAction func cancelButtonTapped() {
        performSegue(withIdentifier: "unwindToTracker", sender: self)
    }
    
    @IBAction func doneBarButtonTapped() {
        print("Done tapped")
        let d_freq_math = Int(freq_picker.selectedRow(inComponent: 0)) + (Int(freq_picker.selectedRow(inComponent: 2)) / 60)
        
        let med_name = self.medication_name.text ?? "unknown"
        let dose_amt = Int(self.dose_stepper.value)
        let isScheduled = self.scheduled_switch.isOn
        let d_freq = isScheduled ? d_freq_math : nil
        let isNotified = isScheduled ? self.notification_switch.isOn : false
        
        med_manager.add_med(med:
            Medication(id: self.med_manager.get_next_index(),
                       name: med_name,
                       dose_amount: dose_amt,
                       dose_unit: "mg",
                       dose_freq: d_freq,
                       notify: isNotified
            )
        )
        
        med_manager.save_medications()
        
        performSegue(withIdentifier: "unwindToTracker", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            if !scheduled_switch.isOn {
                return 2
            } else {
                return 4
            }
        } else {
            return 1
        }
    }

}

extension NewMedicationViewController: UIPickerViewDelegate,UIPickerViewDataSource {
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
    
    func  pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        freq_text_field.text = "\(Int(freq_picker.selectedRow(inComponent: 0)))hr \(Int(freq_picker.selectedRow(inComponent: 2)))min"
    }
}
