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
    
//    @IBOutlet weak var took_it_cell: UITableViewCell!
//    var took_it_cell_rect_view: UIView!
    
    // Static section headers
    let med_name_section_title = "Medication Name"
    let med_details_section_title = "Details"
    
    // State variables
    var editState: Bool = false
    
    // Model classes
    var medication: Medication!
    var med_manager: MedicationManager!
    
    // animation variables
    var sun_view: UIView!
    var check_shape: CAShapeLayer!
    var x_shape: CAShapeLayer!

    override func viewDidLoad() {
        // Set right nav item as edit button
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        // Connect swit to edit method to edit button
        self.navigationItem.rightBarButtonItem?.action = #selector(self.switch_to_edit)
        
        // print(medication)
        // print(med_manager)
        
        // Create gesture recognizer and connect to dismissKeyboard
         let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        // Add tap gesture to root view
        view.addGestureRecognizer(tap)
        
        // Setup UI Components
        refresh_info()
        
        // Setup animations
        print("Setup Animations")
        let smallest_size = self.view.frame.width < self.view.frame.height ? self.view.frame.width : self.view.frame.height
        let largest_side = self.view.frame.width > self.view.frame.height ? self.view.frame.width : self.view.frame.height
        sun_view = UIView(frame: CGRect(x: 0, y: 0, width: smallest_size / 3, height: smallest_size / 3))
        
        sun_view.layer.cornerRadius = sun_view.frame.width / 2
        sun_view.layer.borderWidth = smallest_size / 75
        sun_view.layer.borderColor = CGColor(red: 0.9, green: 0.33, blue: 0.23, alpha: 1)
        sun_view.backgroundColor = UIColor(cgColor: CGColor(red: 0.9, green: 0.33, blue: 0.23, alpha: 1))
        
        // Add x and check
        // inspiration https://stackoverflow.com/questions/66939021/drawing-checkmark-with-stroke-animation-in-swift
        let check = UIBezierPath()
        check.lineWidth = 5
        check.move(to: CGPoint(x: sun_view.bounds.midX - 30, y: sun_view.bounds.midY + 5))
        check.addLine(to: CGPoint(x: sun_view.bounds.midX, y: sun_view.bounds.midY + 30))
        check.addLine(to: CGPoint(x: sun_view.bounds.midX + 30, y: sun_view.bounds.midY - 20))
        
        // https://stackoverflow.com/questions/31728924/ios-draw-bezier-path-in-subview
        check_shape = CAShapeLayer()
        check_shape.path = check.cgPath
        check_shape.lineWidth = smallest_size / 75
        check_shape.strokeColor = UIColor.systemGreen.cgColor
        check_shape.fillColor = UIColor.init(white: 1, alpha: 0).cgColor
        check_shape.strokeEnd = 0

        let check_view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        check_view.layer.addSublayer(check_shape)
        
        let x = UIBezierPath()
        let x_length = CGFloat(30)
        x.lineWidth = 5
        x.move(to: CGPoint(x: sun_view.bounds.midX - x_length, y: sun_view.bounds.midY - x_length))
        x.addLine(to: CGPoint(x: sun_view.bounds.midX + x_length, y: sun_view.bounds.midY + x_length))
        x.move(to: CGPoint(x: sun_view.bounds.midX - x_length, y: sun_view.bounds.midY + x_length))
        x.addLine(to: CGPoint(x: sun_view.bounds.midX + x_length, y: sun_view.bounds.midY - x_length))
        
        x_shape = CAShapeLayer()
        x_shape.path = x.cgPath
        x_shape.lineWidth = smallest_size / 75
        x_shape.strokeColor = UIColor.systemRed.cgColor
        x_shape.fillColor = UIColor.init(white: 1, alpha: 0).cgColor
        x_shape.strokeEnd = 0
        
        let x_view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        x_view.layer.addSublayer(x_shape)

        sun_view.addSubview(check_view)
        sun_view.addSubview(x_view)
        
        sun_view.center = tableView.center
        let transform_down = CGAffineTransform(translationX: 0, y: largest_side * 0.5)
        sun_view.transform = transform_down
        print(sun_view.subviews)
        tableView.addSubview(sun_view)
        tableView.sendSubviewToBack(sun_view)
        
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
        let largest_size = self.view.frame.width > self.view.frame.height ? self.view.frame.width : self.view.frame.height
        
        let original_transform = CGAffineTransform(translationX: 0, y: largest_size * 0.5)
        let original_color = self.sun_view.backgroundColor
        let slide_in = self.sun_view.transform.translatedBy(x: 0, y: -largest_size / 2.5)
        
        // reset x and check strokes
        check_shape.strokeStart = 0
        check_shape.strokeEnd = 0
        
        x_shape.strokeStart = 0
        x_shape.strokeEnd = 0
        
        
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: [], animations: {
            self.sun_view.transform = slide_in
        })
        
        UIView.animate(withDuration: 0.35, delay: 0.15, animations: {
            self.sun_view.backgroundColor = UIColor(cgColor: CGColor(red: 0.9, green: 0.33, blue: 0.23, alpha: 0))
        }, completion: { _ in
            self.confirm_taken_med(msg: "Just want to make sure you have taken your meds.", title: "Confirm taken medication", callback: {res in
                print(res)
                    
                // Start animation
                UIView.animateKeyframes(withDuration: 1, delay: 0, options: [], animations: {
                    
                    if res {
                        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1, animations: {
                            self.sun_view.layer.borderColor = UIColor.systemGreen.cgColor
                            self.check_shape.strokeEnd = 1
                        })
                    } else {
                        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1, animations: {
                            self.sun_view.layer.borderColor = UIColor.systemRed.cgColor
                            self.x_shape.strokeEnd = 1
                        })
                    }
                   
                    UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.2, animations: { 
                        self.sun_view.transform = original_transform
                    })
                    
                }, completion: {_ in
                    
                    UIView.animate(withDuration: 0.2, animations: {
                        self.sun_view.layer.borderColor = original_color?.cgColor
                        self.sun_view.backgroundColor = original_color
                        
                        self.check_shape.strokeStart = 1
                        self.x_shape.strokeStart = 1
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
