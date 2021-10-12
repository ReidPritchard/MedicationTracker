//
//  MedicationViewController.swift
//  Friendication
//
//  Created by Reid Pritchard on 8/31/21.
//

import UIKit

// Table Cell Class
class MedicationCell: UITableViewCell {
    @IBOutlet weak var Title: UILabel!
    @IBOutlet weak var NextDose: UILabel!
    @IBOutlet weak var Description: UILabel!
    var id: Int!
}

class MedicationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var med_manager = MedicationManager() // Data Model
    
    // UI Components
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var table_view: UITableView!
    @IBOutlet weak var streak_label: UILabel!
    
    // Animation Components
    @IBOutlet weak var background_image_view: UIImageView!
    var sun_view: UIView!
    var check_shape: CAShapeLayer!
    var x_shape: CAShapeLayer!
    
    
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        // Table view protocol setup
        table_view.delegate = self
        table_view.dataSource = self
        
        // Add Refresh Control to Table View
        refreshControl.addTarget(self, action: #selector(update_all), for: .valueChanged)
        table_view.refreshControl = refreshControl

        // Create "+" Button to top right
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(new_medication_tapped))
        
        // Create "Edit" Button to top left
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        // Setup animations
        let smallest_size = self.view.frame.width < self.view.frame.height ? self.view.frame.width : self.view.frame.height
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
        
        sun_view.center = view.center
        let transform_down = CGAffineTransform(translationX: 0, y: smallest_size / 4)
        sun_view.transform = transform_down
        print(sun_view.subviews)
        view.addSubview(sun_view)
        view.sendSubviewToBack(sun_view)
//        background_image_view.sendSubviewToBack(sun_view)
        
        // Keep streak updated on load
        update_streak()
        
        // Run super did load
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Update all to keep view fresh
        update_all()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        print("will transition")
//        print(sun_view.transform)
//        print(sun_view.center)
//        sun_view.transform = CGAffineTransform()
//
//        let smallest_size = self.view.frame.width < self.view.frame.height ? self.view.frame.width : self.view.frame.height
//        let transform_down = CGAffineTransform(translationX: 0, y: smallest_size / 4)
//
//        sun_view.center = view.center
//        sun_view.transform = transform_down
//
//        print(sun_view.transform)
//        print(sun_view.center)
//        https://stackoverflow.com/questions/38894031/swift-how-to-detect-orientation-changes
        if UIDevice.current.orientation.isLandscape {
            print("landscape")
            sun_view.center = CGPoint(x: view.center.x, y: view.center.y)
        } else {
            print("port")
            sun_view.center = CGPoint(x: view.center.y, y: view.center.x)
        }
        
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    @IBAction func update_all() {
        // Reloads table view with new data
        table_view.reloadData()
        // Check for streak updates
        self.update_streak()
        // End refresh controller "refreshing state"
        self.refreshControl.endRefreshing()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        // Start edit mode
        super.setEditing(editing, animated: true)
        self.table_view.setEditing(editing, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        print("view receive memory warning.")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // print("view will appear")
        
        // Reload table data
        table_view.reloadData()
        // Run super viewWillAppear
        super.viewWillAppear(animated)
    }
    
    func update_streak() {
        // Get updated streak through model class method
        let streak = self.med_manager.get_streak()
        
        // Set streak label based on streak
        switch streak {
        case 0:
            streak_label.text = "Start today! You got this!!"
        case 1 ... 10:
            streak_label.text = "\(streak) days down! Crushing it!"
        case 11 ... 20:
            streak_label.text = "Wow! \(streak) days straight! You're incredible!!"
        default:
            streak_label.text = "\(streak) days!!!!"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection: Int) -> Int {
        // Return number of items in model
        return self.med_manager.get_count()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get custom cell for table view
        let cell = tableView.dequeueReusableCell(withIdentifier:
           "MedicationCell", for: indexPath) as! MedicationCell
        
        // setup cell UI using model data
        cell.Title?.text = med_manager.get_header(index: indexPath.row)
        cell.NextDose?.text = med_manager.get_next_dose(index: indexPath.row)
        cell.Description?.text = med_manager.get_description(index: indexPath.row)

        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.5, delay: 0.2 * Double(indexPath.row), animations: {
            cell.alpha = 1
        })
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Set table view as editable
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // Setup edit delete action
        if (editingStyle == .delete) {
            // TODO: temporary save deleted row in case of accident
            
            // Remove medication from model
            self.med_manager.remove_med(index: indexPath.row)
            // Remove medication from table (with animation)
            self.table_view.deleteRows(at: [indexPath], with: .automatic)
            // Save updated model with row deleted
            self.med_manager.save_medications()
        }
    }
    
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // Create swipe action
        let took_med = UIContextualAction(style: .normal, title: "Took") {(action, view, completionHandler) in
            // Setup animation matrix
            let normal_matrix = self.sun_view.transform
            let big = self.sun_view.transform.scaledBy(x: 1.25, y: 1.25)
            
            // reset animation values
            self.check_shape.strokeStart = 0
            self.check_shape.strokeEnd = 0
            
            self.x_shape.strokeStart = 0
            self.x_shape.strokeEnd = 0
            
            // Start animation
            UIView.animateKeyframes(withDuration: 1, delay: 0, options: [], animations: {
                
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: {
                    self.sun_view.backgroundColor = UIColor(cgColor: CGColor(red: 0.9, green: 0.33, blue: 0.23, alpha: 0))
                })
                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
                    self.sun_view.transform = big
                })
                
            })
            
            // Run confirmation
            self.confirm_taken_med(msg: "Just making sure that was on purpose!", title: "Confirm Taken", index: indexPath.row, callback: { res in
                
                // Start animation
                UIView.animateKeyframes(withDuration: 1.5, delay: 0, options: [], animations: {
                    
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
                        self.sun_view.transform = normal_matrix
                    })
                    
                }, completion: {_ in
                    
                    UIView.animate(withDuration: 0.7, animations: {
                        self.sun_view.layer.borderColor = CGColor(red: 0.9, green: 0.33, blue: 0.23, alpha: 1)
                        self.sun_view.backgroundColor = UIColor(cgColor: CGColor(red: 0.9, green: 0.33, blue: 0.23, alpha: 1))
                        self.check_shape.strokeStart = 1
                        self.x_shape.strokeStart = 1
                    })
                    
                })
            })
            
            // Fire callback as finished
            completionHandler(true)
        }
        
        // Set swipe action background color
        took_med.backgroundColor = .systemBlue
        
        // Return all leading swipe actions (just one)
        return UISwipeActionsConfiguration(actions: [took_med])
    }
    
    @IBAction func unwindToTracker(_ unwindSegue: UIStoryboardSegue) {
        // Reload table data when unwinded to
        self.table_view.reloadData()
    }
    
    // Prepare for segues!
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If we are headed to the detail view
        if segue.identifier == "detailMedSegue" {
            // Set destination
            if let destination = segue.destination as? MedicationDetailViewController {
                    // Set detail view data
                    let indexPath = self.table_view.indexPathForSelectedRow!
                    destination.med_manager = self.med_manager
                    destination.medication = self.med_manager.get_index(i: indexPath.row)
            }
        // If we are headed to the new medication view
        } else if segue.identifier == "newMedSegue" {
            // Move through the navigation view controller
            if let navigation_controller = segue.destination as? UINavigationController {
                // Set destination and pass in needed model data
                if let destination = navigation_controller.topViewController as? NewMedicationViewController {
                    destination.med_manager = self.med_manager
                }
            }
        }
    }
    
func confirm_taken_med(msg: String, title: String, index: Int, callback: @escaping (Bool) -> Void) {
        // Create alert controller
        let controller = UIAlertController(title:title, message: msg, preferredStyle: .alert)
        
        // Create accept action
        let acceptAction = UIAlertAction(title: "Yes!", style: .default) { (handler) in
            // Update model
            self.med_manager.took_medication(index: index)
            // Save model
            self.med_manager.save_medications()
            // Reload table with new data
            self.table_view.reloadData()
            
            callback(true)
        }
        
        // Create cancel action
        let cancelAction = UIAlertAction(title: "Nope", style: .cancel) { (handler) in
            // Do nothing
            // print("Medication not taken")
            callback(false)
        }
        
        // Add both actions to the alert
        controller.addAction(acceptAction)
        controller.addAction(cancelAction)
        
        // Present the alert
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func new_medication_tapped() {
        // Programatically start segue (since we can't connect it on storyboard)
        performSegue(withIdentifier: "newMedSegue", sender: self)
    }
}
