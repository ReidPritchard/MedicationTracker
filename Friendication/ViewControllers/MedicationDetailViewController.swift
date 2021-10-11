//
//  MedicationDetailViewController.swift
//  Friendication
//
//  Created by Reid Pritchard on 9/14/21.
//

import UIKit

class MedicationDetailViewController: UITableViewController {
    // Non-Interactive UI Components
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var take_every: UILabel!
    @IBOutlet weak var time_till: UILabel!
    @IBOutlet weak var last_time: UILabel!
    @IBOutlet weak var streak: UILabel!
    @IBOutlet weak var nav_title: UINavigationItem!
        
    // Interactive UI Components
    @IBOutlet weak var edit_name: UITextField!
    @IBOutlet weak var edit_amount: UITextField!
    @IBOutlet weak var edit_interval: UITextField!
    
    @IBOutlet weak var took_it_cell: UITableViewCell!
    var took_it_cell_rect_view: UIView!
    
    // Static section headers
    let med_name_section_title = "Medication Name"
    let med_details_section_title = "Details"
    
    // State variables
    var editState: Bool = false
    
    // Model classes
    var medication: Medication!
    var med_manager: MedicationManager!

    override func viewDidLoad() {
        // Set right nav item as edit button
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        // Connect swit to edit method to edit button
        self.navigationItem.rightBarButtonItem?.action = #selector(self.switch_to_edit)
        
        // print(medication)
        // print(med_manager)
        
        // Setup animation for took_it button
        took_it_cell_rect_view = UIView(frame: CGRect(x: 0, y: 0, width: 0.1, height: 10))
//        took_it_cell.layer.borderWidth = 15
        
        took_it_cell_rect_view.backgroundColor = .systemGreen
        took_it_cell_rect_view.center = took_it_cell.subviews[0].center
        
        took_it_cell.subviews[0].addSubview(took_it_cell_rect_view)
        took_it_cell.subviews[0].sendSubviewToBack(took_it_cell_rect_view)
        
        // Create gesture recognizer and connect to dismissKeyboard
         let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        // Add tap gesture to root view
        view.addGestureRecognizer(tap)
        
        // Setup UI Components
        refresh_info()
        
        // Run super view did load
        super.viewDidLoad()
    }
    
    // Used to dismissKeyboard on gesture
    @objc func dismissKeyboard() {
        // Resign first responder of view or active text field subview
        view.endEditing(true)
    }
    
    @IBAction func name_return_tapped(_ sender: UITextField) {
        // On "return"/"done" tapped, close keyboard
        sender.resignFirstResponder()
    }
    
    func refresh_info() {
        // Try fetching last taken date
        let last: Date? = medication.last_taken ?? nil
        // Try fetching next dose date
        let next_dose = medication.get_next_dose()
        // Init string for label text
        var str_date: String
        
        // Check if date is found
        if last != nil {
            // Create date formatter
            let df = DateFormatter()
            // Set formatter's format
            df.dateFormat = "M/d hh:mm"
            // Format date to string
            str_date = df.string(from: last!)
        } else {
            // If not date found, set string to never taken
            str_date = "Never taken"
        }
        
        // Set non-interactive UI Component text
        nav_title.title = medication?.name
        amount.text = "\(medication.dose_amount) \(medication.dose_unit)"
        take_every.text = "\(medication.dose_freq ?? 0 == 0 ? "N/A" : String(medication.dose_freq!)) hrs"
        last_time.text = "\(str_date)"
        streak.text = "\(medication.times_taken_in_row)"
        time_till.text = "\(next_dose != nil ? "\(next_dose!.hour!) hrs" : "N/A")"
    }
    
    func update_edit() {
        // print("Update to edit mode: \(editState)")
        
        // Toggle non-interactive UI Component based on edit state
        self.amount.isHidden = editState
        self.take_every.isHidden = editState

        // Toggle interactive UI Component based on edit state
        self.edit_amount.isHidden = !editState
        // Fill placeholder with up to date data
        self.edit_amount.placeholder = "\(self.medication.dose_amount) \(self.medication.dose_unit)"
        
        // Toggle interactive UI Component based on edit state
        self.edit_interval.isHidden = !editState
        // Fill placeholder with up to date data
        self.edit_interval.placeholder = "\(self.medication.dose_freq ?? 0) \(self.medication.dose_freq ?? 0 == 1 ? "hr" : "hrs")"
        
        // Toggle right bar button item based on edit state
        self.navigationItem.rightBarButtonItem?.title = editState ? "Done" : "Edit"
    }
    
    @IBAction func switch_to_edit(_ sender: Any) {
        // If currently in edit state
        if editState {
            // save data
            // self.medication.name = self.edit_title.text ?? self.medication.name
            
            // Check if interactive components have been changed and update data if so
            self.medication.dose_amount = Int(self.edit_amount.text ?? "") ?? self.medication.dose_amount
            self.medication.dose_freq = Int(self.edit_interval.text ?? "") ?? self.medication.dose_freq
            
            // Fetch new name text
            let edited_name = String(self.edit_name.text ?? "")
            self.medication.name = edited_name.count == 0 ? self.medication.name : edited_name
            
            med_manager.save_medications()
            refresh_info()
        }
        
        editState = !editState
        self.tableView.reloadData()
        update_edit()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return editState ? med_name_section_title : nil
        } else {
            return med_details_section_title
        }
    }

//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if section == 0 {
//            return editState ? CGFloat(20) : CGFloat()
//        }
//        return CGFloat(20)
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return editState ? 1 : 0
        } else {
            if editState {
                return 2
            } else {
                return 6
            }
        }
    }

    
    @IBAction func took_medication(_ sender: Any) {
        let x_full_scale = CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1)).scaledBy(x: 10000, y: 1)
        let y_full_scale = CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1)).scaledBy(x: 10000, y: 50)
        let shrunk = CGAffineTransform(scaleX: CGFloat(1), y: CGFloat(1))
        
        self.took_it_cell_rect_view.backgroundColor = .systemGreen
        self.took_it_cell_rect_view.alpha = 0
        
        self.took_it_cell_rect_view.frame.size.width = 0.1
        self.took_it_cell_rect_view.frame.size.height = 10
        self.took_it_cell_rect_view.alpha = 0
        
        print(self.took_it_cell_rect_view.transform)

        UIView.animateKeyframes(withDuration: 0.7, delay: 0, animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.3, animations: {
                self.took_it_cell_rect_view.alpha = 1
                self.took_it_cell_rect_view.transform = x_full_scale
                print(self.took_it_cell_rect_view.frame.width, self.took_it_cell_rect_view.frame.height)
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.4, animations: {
                self.took_it_cell_rect_view.transform = y_full_scale
                print(self.took_it_cell_rect_view.frame.width, self.took_it_cell_rect_view.frame.height)
            })
            
        }, completion: {_ in
            
            self.confirm_taken_med(msg: "Just making sure you took your meds!", title: "Confirm", callback: { res in
                self.took_it_cell_rect_view.transform = y_full_scale
                
                UIView.animateKeyframes(withDuration: 1, delay: 0, options: [], animations: {
                    if !res {
                        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.4,  animations: {
                            self.took_it_cell_rect_view.backgroundColor = .systemRed
                        })
                    }
                    UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.3,  animations: {
                        self.took_it_cell_rect_view.transform = x_full_scale
                        print(self.took_it_cell_rect_view.frame.width, self.took_it_cell_rect_view.frame.height)

                    })
                    
                    UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.6,  animations: {
                        self.took_it_cell_rect_view.alpha = 0
                        self.took_it_cell_rect_view.transform = shrunk
                        print(self.took_it_cell_rect_view.frame.width, self.took_it_cell_rect_view.frame.height)

                    })
                })
            })
        })
    }
    
    func confirm_taken_med(msg: String, title: String, callback: @escaping (Bool) -> Void) {
        let controller = UIAlertController(title:title, message: msg, preferredStyle: .alert)
        let acceptAction = UIAlertAction(title: "Yes!", style: .default) { (handler) in
            self.medication.update_last_taken(newDate: Date())
            self.med_manager.save_medications()
            self.refresh_info()
            callback(true)
        }
        let cancelAction = UIAlertAction(title: "Nope", style: .cancel) { (handler) in
            print("Nah we didn't take it")
            callback(false)
        }
        
        controller.addAction(acceptAction)
        controller.addAction(cancelAction)
        
        self.present(controller, animated: true, completion: nil)
    }
}
