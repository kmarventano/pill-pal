/*
 Object to represent reminders
 
 Contains all the information for for reminders (list of meds to be taken and the time)
 methods to encode/decode and save/load medication to the disk
 
 Emily Hayashi-Groves
 Kristen Marventano
 */


import UIKit
import UserNotifications

class Reminder: NSObject, NSCoding {
    // Reminders have identifying key, list of meds taken at the time, and the hour/minute taken
    var key : Int
    var meds  = [Medication]()
    var hour : Int
    var minute : Int
    
    
    /* Keys for encoding the fields */
    struct PropertyKey{
        static let keyKey = "key"
        static let medsKey = "meds"
        static let hourKey = "hour"
        static let minuteKey = "minute"
    }
    
    /* Initializer */
    init?(key : Int, hour : Int, minute : Int) {
        self.key = key
        self.hour = hour
        self.minute = minute
    }
    
    /* Add medication method */
    func addMedicine (med : Medication) {
        // Append med to list
        meds.append(med)
    }
    
    /* Encoder */
    func encode(with aCoder: NSCoder) {
        // Encodes each field
        aCoder.encode(meds, forKey: PropertyKey.medsKey)
        aCoder.encode(hour, forKey: PropertyKey.hourKey)
        aCoder.encode(minute, forKey: PropertyKey.minuteKey)
    }
    
    /* Decoder */
    required convenience init?(coder aDecoder: NSCoder){
        // Decodes all the fields
        let key = aDecoder.decodeInteger(forKey: PropertyKey.keyKey)
        let meds = aDecoder.decodeObject(forKey: PropertyKey.medsKey)
        let hour = aDecoder.decodeInteger(forKey: PropertyKey.hourKey)
        let minute = aDecoder.decodeInteger(forKey: PropertyKey.minuteKey)
        
        // Creates Reminder object from decoded data
        self.init(key : key, hour : hour, minute : minute)
        
        // Set the medication array to the decoded array of medications
        self.meds = meds as! [Medication]
    }
    
    /* Gets the path to the data */
    private class func getFileURL() -> NSURL {
        // Construct a URL for a file named Reminder in the DocumentDirectory
        let documentsDirectory = FileManager().urls(for: (.documentDirectory), in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("Reminder")
        
        // Return URL
        return archiveURL as NSURL
    }
    
    /* Saves array of Reminders to disk */
    class func saveRemindersToDisk(reminders: [Reminder]) {
        NSKeyedArchiver.archiveRootObject(reminders, toFile: Reminder.getFileURL().path!)
    }
    
    /* Loads array of Reminders from disk */
    class func loadRemindersFromDisk() -> [Reminder]? {
        // If the reminder list hasn't been created, return an empty reminder list
        if (NSKeyedUnarchiver.unarchiveObject(withFile: Reminder.getFileURL().path!) == nil){
            return [Reminder]()
        }
        
        // If the reminder list has been created, return it
        return NSKeyedUnarchiver.unarchiveObject(withFile: Reminder.getFileURL().path!) as? [Reminder]
    }
}
