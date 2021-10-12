//
//  MedicationModel.swift
//  Friendication
//
//  Created by Reid Pritchard on 9/2/21.
//

import Foundation

class Medication: Codable {
    let id: Int
    var name: String
    var dose_amount: Int
    let dose_unit: String
    var dose_freq: Int?
    var times_taken_in_row = 0
    var last_taken: Date?
    var should_notify: Bool
    
    init(id: Int, name: String, dose_amount: Int, dose_unit: String, dose_freq: Int, last_taken: Date) {
        self.id = id
        self.name = name
        self.dose_amount = dose_amount
        self.dose_unit = dose_unit
        self.dose_freq = dose_freq
        self.last_taken = last_taken
        self.should_notify = false
    }
    
    init(id: Int, name: String, dose_amount: Int, dose_unit: String, dose_freq: Int?, notify: Bool) {
        self.id = id
        self.name = name
        self.dose_amount = dose_amount
        self.dose_unit = dose_unit
        self.dose_freq = dose_freq
        self.last_taken = nil
        self.should_notify = notify
    }
    
    init(id: Int, name: String, dose_amount: Int, dose_unit: String, dose_freq: Int) {
        self.id = id
        self.name = name
        self.dose_amount = dose_amount
        self.dose_unit = dose_unit
        self.dose_freq = dose_freq
        self.last_taken = nil
        self.should_notify = false
    }
    
    func update_last_taken(newDate: Date?) {
        self.last_taken = newDate ?? Date()
        
        let next_dose = self.get_next_dose()
        if next_dose != nil {
            if abs(next_dose!.hour ?? 99) <= (self.dose_freq! / 8) {
                print("streak!")
                self.times_taken_in_row += 1
            } else {
                print("streak broken :(")
                self.times_taken_in_row = 0
            }
        } else {
            print("dose is not scheduled, increasing streak")
            self.times_taken_in_row += 1
        }
    }
    
    func get_next_dose() -> DateComponents? {
        if dose_freq != nil {
            let time_interval = TimeInterval(self.dose_freq! * 60 * 60)
    //        print(time_interva l)
            let next_take = self.last_taken?.addingTimeInterval(time_interval) ?? Date()
    //        print(next_take)
            
            let diff = Calendar.current.dateComponents([.hour, .minute], from: Date(), to: next_take)
            
            return diff
        } else {
            return nil
        }
    }
}

class MedicationManager {
    var meds_data: [Medication]
    // Persistent data https://stackoverflow.com/questions/44646186/save-file-in-document-directory-in-swift-3
    let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("medication_save").appendingPathExtension("plist")
    let protectionLevel = Data.WritingOptions.completeFileProtection
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let dateFormatter = DateFormatter()
    
    init() {
//        self.meds_data = meds.count ? meds : []
        self.meds_data = []
        dateFormatter.dateFormat = "M/d hh:mm"

        load_medication()

        if self.meds_data.count == 0 {
            let t_interval = TimeInterval(-12 * 60 * 60)
            self.meds_data.append(Medication(id: self.get_next_index(), name: "Anti-Deps", dose_amount: 50, dose_unit: "mg", dose_freq: 24, last_taken: Date() + t_interval))
        }
    }
    
    func get_streak() -> Int {
        var current_streak = meds_data.first?.times_taken_in_row ?? 0
        for med in meds_data {
            if med.dose_freq != 0 && med.dose_freq != nil {
                current_streak = med.times_taken_in_row < current_streak ? med.times_taken_in_row : current_streak
            }
        }
        
        return current_streak
    }
    
    func add_med(med: Medication) {
        meds_data.append(med)
//        print("in model")
//        print(meds_data.count)
    }
    
    func remove_med(index: Int) {
        meds_data.remove(at: index)
    }
    
    func get_next_index() -> Int {
        return self.meds_data.count - 1
    }
    
    func get_index(i: Int) -> Medication {
        return self.meds_data[i]
    }
    
    func get_count() -> Int {
        return self.meds_data.count
    }
    
    func get_header(index: Int) -> String {
        let med = self.meds_data[index]
        
        return "\(med.name)"
    }
    
    func get_next_dose(index: Int) -> String {
        let diff = self.meds_data[index].get_next_dose()
        
        if diff != nil {
            return "Next in \(diff!.hour ?? 0)hrs"
        } else {
            return "Not scheduled"
        }
    }
    
    func get_description(index: Int) -> String {
        // Convert Date to String
        let med = self.meds_data[index]
        let last: Date? = med.last_taken
        
        if last != nil{
            let str_date = self.dateFormatter.string(from: last!)
            return "\(med.dose_amount)\(String(med.dose_unit))\nLast \(str_date)"
        } else {
            return "\(med.dose_amount)\(String(med.dose_unit))\nNever Taken"
        }
    }
    
    func load_medication() {
        if let found_data = try? Data(contentsOf: fileURL),
           let decoded_data = try? self.decoder.decode(Array<Medication>.self, from: found_data) {
            print(decoded_data)
            self.meds_data = decoded_data
        }
    }
    
    func took_medication(index: Int) {
        self.meds_data[index].update_last_taken(newDate: Date())
    }
    
    func save_medications() {
        print("saving")
        let encoded_meds = try? encoder.encode(self.meds_data)
//        print(encoded_meds ?? "it didn't work") // ususally like 306 bytes or something
        
        if (encoded_meds != nil) {
            do {
                // Protection level choice https://stackoverflow.com/questions/37926333/swift-encryption-of-a-file-or-plain-text
                try encoded_meds?.write(to: self.fileURL, options: [self.protectionLevel, NSData.WritingOptions.atomic])
            } catch {
                print("There was an error \(error)")
            }
        }
    }
}

