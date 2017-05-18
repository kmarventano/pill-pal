/*
 First view the user sees after launching application
 
 Shows current list of medications saved on phone
 Clicking on a particular medicine takes user to a page with more info
 
 Emily Hayashi-Groves
 Kristen Marventano
 */

import UIKit
import UserNotifications

class HomePageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UNUserNotificationCenterDelegate {
    // Buttons
    @IBOutlet weak var removeMedButton: UIButton!
    @IBOutlet weak var addMedButton: UIButton!
    @IBOutlet weak var viewRemindersButton: UIButton!

    // Table with all the med
    @IBOutlet weak var medTable: UITableView!
    
    // List of medications user is on
    var meds  = [Medication]()
    var selectedMed : Medication!
    var doneIsShowing = false
    
    // All of the reminders user has
    var reminders = [Reminder]()
   
    /* View loaded */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set delegate/data source to self
        medTable.delegate = self
        medTable.dataSource = self
        
        // Set User notification delegate to self
        UNUserNotificationCenter.current().delegate = self
        
        // Don't allow multiple selections
        self.medTable.allowsMultipleSelectionDuringEditing = false;
        
        // Create a sample cell
        self.medTable.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        // Load meds from the disk
        meds = Medication.loadMedsFromDisk()!
        
        // Load reminders from the disk
        reminders = Reminder.loadRemindersFromDisk()!
        
        // Make sure reminder meds are up to date
        // Go through all the current meds
        for med in meds {
            // If it's taken in the morning
            if (med.morning == true && !(reminders[0].meds.contains(med))){
                // Add it to morning meds
                reminders[0].meds.append(med)
            }
            
            // If it's taken in the afternoon
            if (med.afternoon == true && !(reminders[1].meds.contains(med))){
                // Add it to afternoon meds
                reminders[1].meds.append(med)
            }
            
            // If it's taken at night
            if (med.night == true && !(reminders[2].meds.contains(med))){
                // Add it to night meds
                reminders[2].meds.append(med)
            }
        }
        
        // If the reminders haven't been generated, create the blocks for morning, noon, and night
        if (reminders.count == 0){
            // Register reminder category
            self.registerCategory()
            
            // Create the reminders for morning, afternoon, and night
            let morning = Reminder.init(key: 0, hour: 5, minute : 0)
            let afternoon = Reminder.init(key : 1, hour : 12, minute : 0)
            let night = Reminder.init(key : 2, hour : 8 + 12, minute : 0)
            
        
            // Go through all the current meds
            for med in meds {
                // If it's taken in the morning
                if (med.morning == true){
                    // Add it to morning meds
                    morning?.meds.append(med)
                }
                
                // If it's taken in the afternoon
                if (med.afternoon == true){
                    // Add it to afternoon meds
                    afternoon?.meds.append(med)
                }
                
                // If it's taken at night
                if (med.night == true){
                    // Add it to night meds
                    night?.meds.append(med)
                }
            }
            
            // Add them to the reminder list
            reminders.append(morning!)
            reminders.append(afternoon!)
            reminders.append(night!)
            
            // Save them to disk
            Reminder.saveRemindersToDisk(reminders: reminders)
        }
        
        // If there are morning meds
        if (reminders[0].meds.count != 0){
            // Schedule reminder for the morning meds
            self.scheduleReminder(medBlock: "morning", hour: reminders[0].hour, minute: reminders[0].minute)
        }
        
        // If there are afternoon meds
        if (reminders[1].meds.count != 0){
            // Schedule reminder for the afternoon meds
            self.scheduleReminder(medBlock: "afternoon", hour: reminders[1].hour, minute: reminders[1].minute)
        }
        
        // If there are night meds
        if (reminders[2].meds.count != 0){
            // Schedule reminder for the afternoon meds
            self.scheduleReminder(medBlock: "night", hour: reminders[2].hour, minute: reminders[2].minute)
        }
        
        medTable.delegate = self
        medTable.dataSource = self
        NSLog("The number of night meds is \(reminders[2].meds.count)")
    }
    
    /* Recieved a notification */
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Launch the Reminder list view
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Reminder")
        self.present(vc, animated: true, completion: nil)
        
        completionHandler()
    }
    
    /* Present notification */
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Present the ReminderList viewcontroller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Reminder")
        self.present(vc, animated: true, completion: nil)
        
        
        // Complete the notification
        completionHandler([.badge, .alert, .sound])
    }
    
    /* Doing the notification */
    func registerCategory() -> Void{
        // Setup the category
        let callNow = UNNotificationAction(identifier: "call", title: "Call now", options: [])
        let clear = UNNotificationAction(identifier: "clear", title: "Clear", options: [])
        let category : UNNotificationCategory = UNNotificationCategory.init(identifier: "CALLINNOTIFICATION", actions: [callNow, clear], intentIdentifiers: [], options: [])
        let center = UNUserNotificationCenter.current()
        center.setNotificationCategories([category])
        
    }
    
    
    /* Schedules the notification for given time */
    func scheduleReminder (medBlock : String, hour: Int, minute: Int) {
        // Create the message of the notification
        let content = UNMutableNotificationContent()
        
        // Set title to pill pal, message to meds being taken, identifer callin
        content.title = "PILL PAL"
        content.body = "Time for \(medBlock) medicines"
        content.categoryIdentifier = "CALLINNOTIFICATION"
        
        
        // Create the date object for when to take medicine
        var date = DateComponents()
        date.hour = hour
        date.minute = minute
        date.second = 0
        
        // Create the trigger from specified time
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: date, repeats: true)
        
        // Let id be the med Block
        let identifier = "id_" + medBlock
        
        // Create notification request and add it
        let request = UNNotificationRequest.init(identifier: identifier, content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: { (error) in
        })
    }


    /* Delete function */
    @objc(tableView:commitEditingStyle:forRowAtIndexPath:) func tableView(_ tableView:UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == .delete) {
            meds.remove(at: indexPath.row)
            medTable.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    
    /* Set up table */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /* Rows */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meds.count
    }
    
    /* Height */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    /* Fill in table */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = medTable.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        
        cell.textLabel?.text = meds[indexPath.row].medicationName
        print(meds[indexPath.row].medicationName)
        return cell
    }
    
    /* User clicking on specific row (medicine) */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Selected medicine
        selectedMed = meds[indexPath.row]
        
        //send to description page, as long as the flag for deletion-mode isn't set
        if (!doneIsShowing){
            self.performSegue(withIdentifier: "toDescriptionSegue", sender: self)
        }
            
        //call function to delete and resave the disk
        else{
            self.tableView(medTable, commit: .delete, forRowAt: indexPath)
            Medication.saveMedsToDisk(meds: meds)
        }
    }
    
    /* Did recieve memory warning */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //edit medication list, used to limit user functionality while deleting meds
    @IBAction func editMedication(_ sender: Any) {
        
        //done is showing is used as a flag-- when the label on the button isn't 'done' (ie doneIsShowing is false), that means 'remove' is showing, and touching the button enables deletion
        if (!doneIsShowing){
            doneIsShowing = true
            removeMedButton.setTitle("Done", for: .normal)
            addMedButton.isUserInteractionEnabled = false
            addMedButton.setTitleColor(UIColor.gray, for: .normal)
            viewRemindersButton.isUserInteractionEnabled = false
            viewRemindersButton.setTitleColor(UIColor.gray, for: .normal)
            
        }
            
        //if done IS showing, when it's tapped again the label switches from done to remove
        else{
            doneIsShowing = false
            removeMedButton.setTitle("Remove", for: .normal)
            addMedButton.isUserInteractionEnabled = true
            addMedButton.setTitleColor(view.tintColor, for: .normal)
            viewRemindersButton.isUserInteractionEnabled = true
            viewRemindersButton.setTitleColor(view.tintColor, for: .normal)
        }
        
        
    }
    
    /* Button to go to reminder list */
    @IBAction func moveToSchedule(_ sender: Any) {
        self.performSegue(withIdentifier: "toReminderListSegue", sender: self)
    }
    
    /* Segues to different views */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass selected medicine to the description page
        if(segue.identifier == "toDescriptionSegue"){
            let destinationVC = (segue.destination as! MedicineDescriptionViewController)
            destinationVC.med = selectedMed
        }
        
        // Go to reminder list
        if(segue.identifier == "toReminderListSegue"){
            // Send the array
            let destinationVC = (segue.destination as! ReminderListViewController)
            destinationVC.medArray = meds
        }
        
    }

}
