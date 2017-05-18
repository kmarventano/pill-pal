/*
 Object to represent medication
 
 Contains all relevent fields including name, dosage, instructions, and bools
 for each time block
 Contains methods to encode/decode and save/load medication to the disk
 
 Emily Hayashi-Groves
 Kristen Marventano
 */

import UIKit

class Medication : NSObject, NSCoding{
    // Medications have a unique key, name, dosage, instructions
    var key : Int
    var medicationName : String
    var medicationDosage : String
    var instructions : String
    
    // Bools for the time it's taken, if true it's taken at that time
    var morning : Bool
    var afternoon : Bool
    var night : Bool
 
    /* Keys for encoding the fields */
    struct PropertyKey{
        static let keyKey = "key"
        static let nameKey = "name"
        static let dosageKey = "dosage"
        static let instructionKey = "instruction"
        static let pillsOnHandKey = "pillsOnHand"
        static let refillableKey = "refillable"
        static let morningKey = "morning"
        static let afternoonKey = "afternoon"
        static let nightKey = "night"
    }
    
    /* Initializer */
    init?(key : Int, medicationName : String, medicationDosage : String, instructions : String, morning : Bool, afternoon : Bool, night: Bool) {
        // Sets all fields to respective value
        self.key = key
        self.medicationName = medicationName
        self.medicationDosage = medicationDosage
        self.instructions = instructions
        self.morning = morning
        self.afternoon = afternoon
        self.night  = night
    }
  
    /* Encoder */
    func encode(with aCoder: NSCoder) {
        // Encodes each field
        aCoder.encode(key, forKey: PropertyKey.keyKey)
        aCoder.encode(medicationName, forKey: PropertyKey.nameKey)
        aCoder.encode(medicationDosage, forKey: PropertyKey.dosageKey)
        aCoder.encode(instructions, forKey: PropertyKey.instructionKey)
        aCoder.encode(morning, forKey: PropertyKey.morningKey)
        aCoder.encode(afternoon, forKey: PropertyKey.afternoonKey)
        aCoder.encode(night, forKey: PropertyKey.nightKey)
    }
    
    /* Decoder */
    required convenience init?(coder aDecoder: NSCoder){
        // Decodes all the fields
        let key = aDecoder.decodeInteger(forKey: PropertyKey.keyKey)
        let name = aDecoder.decodeObject(forKey: PropertyKey.nameKey) as? String
        let dosage = aDecoder.decodeObject(forKey: PropertyKey.dosageKey) as? String
        let instructions = aDecoder.decodeObject(forKey: PropertyKey.instructionKey) as? String
        let morning = aDecoder.decodeBool(forKey: PropertyKey.morningKey)
        let afternoon = aDecoder.decodeBool(forKey: PropertyKey.afternoonKey)
        let night = aDecoder.decodeBool(forKey: PropertyKey.nightKey)
        
        // Creates medication object from decoded data
        self.init(key: key, medicationName: name!, medicationDosage: dosage!, instructions: instructions!, morning: morning, afternoon: afternoon, night: night)
    }
    

    /* Gets the path to the data */
    private class func getFileURL() -> NSURL {
        // Construct a URL for a file named Medication in the DocumentDirectory
        let documentsDirectory = FileManager().urls(for: (.documentDirectory), in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("Medication")
        
        // Return URL
        return archiveURL as NSURL
    }
    
    /* Saves array of meds to disk */
    class func saveMedsToDisk(meds: [Medication]) {
        NSKeyedArchiver.archiveRootObject(meds, toFile: Medication.getFileURL().path!)
    }
    
    /* Loads array of meds from disk */
    class func loadMedsFromDisk() -> [Medication]? {
        // If the medication list hasn't been created return an empty list
        if (NSKeyedUnarchiver.unarchiveObject(withFile: Medication.getFileURL().path!) == nil){
            return [Medication]()
        }
        
        // If the medication list has been created, return it
        return NSKeyedUnarchiver.unarchiveObject(withFile: Medication.getFileURL().path!) as? [Medication]
    }

}
