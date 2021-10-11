//
//  MedicationViewController.swift
//  Friendication
//
//  Created by Reid Pritchard on 8/31/21.
//

import UIKit

class MeViewController: UIViewController {
    @IBOutlet weak var last_taken_label: UILabel!
    let date_formatter = DateFormatter()
    // var last_taken: Date

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func med_taken(_ sender: Any) {
        print("med taken yay!")
//        let text_date = self.last_taken_label.text?.split(separator: ": ")[0]
//
//        self.last_taken = date_formatter.date(from: text_date)
        let curr_date = Date()
        
        date_formatter.dateFormat = "YY, MMM d, hh:mm"
        print("Last Taken: " + date_formatter.string(from: curr_date))
        last_taken_label.text = "Last Taken: " + date_formatter.string(from: curr_date)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
