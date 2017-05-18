//
//  ChangeTimesViewController.swift
//  pill pal
//
//  Created by Kristen Marventano on 2/18/17.
//  Copyright © 2017 Kristen Marventano. All rights reserved.
//

import UIKit
import UserNotifications

class ChangeTimesViewController: UIViewController, UNUserNotificationCenterDelegate{
    // Load reminders from the disk
    let reminders = Reminder.loadRemindersFromDisk()!
    
    /* Morning picker changed */
    @IBAction func morningPickerChanged(_ sender: Any) {
        // Only change if it's not hidden
        if (!morningTimePicker.isHidden){
            // We only care about the hour and minute
            let unitFlags = Set<Calendar.Component>([.hour, .minute])
            
            // Get the components from the picker
            let anchorComponents = morningTimePicker.calendar.dateComponents(unitFlags, from: morningTimePicker.date)
            
            // Change the notification time
            reminders[0].hour = anchorComponents.hour!
            reminders[0].minute = anchorComponents.minute!
            
            // Save changes to disk
            Reminder.saveRemindersToDisk(reminders: reminders)
            
            // Change the label
            if (anchorComponents.hour! > 12){
                morningTime.text = "\(reminders[0].hour - 12)" + ":" + "\(String(format: "%02d", reminders[0].minute))" + " PM"
                
            }
                
            else if (anchorComponents.hour == 12){
                morningTime.text = "\(reminders[0].hour)" + ":" + "\(String(format: "%02d", reminders[0].minute))" + " PM"
            }
                
            else {
                morningTime.text = "\(reminders[0].hour)" + ":" + "\(String(format: "%02d", reminders[0].minute))" + " AM"
            }
            
            // If there are morning meds
            if (reminders[0].meds.count != 0){
                // Get rid of the old reminder 
                self.removeNotification(identifier: "morning")
                
                // Schedule reminder for the morning meds
                self.scheduleReminder(medBlock: "morning", hour: reminders[0].hour, minute: reminders[0].minute)
            }
        }
    }
    
    /* Afternoon picker changed */
    @IBAction func afternoonPickerChanged(_ sender: Any) {
        // Only change if it's not hidden
        if (!afternoonTimePicker.isHidden){
            // We only care about the hour and minute
            let unitFlags = Set<Calendar.Component>([.hour, .minute])
            
            // Get the components from the picker
            let anchorComponents = afternoonTimePicker.calendar.dateComponents(unitFlags, from: afternoonTimePicker.date)
            
            // Change the notification time
            reminders[1].hour = anchorComponents.hour!
            reminders[1].minute = anchorComponents.minute!
            
            // Save changes to disk
            Reminder.saveRemindersToDisk(reminders: reminders)
            
            // Change the label
            if (anchorComponents.hour! > 12){
                afternoonTime.text = "\(reminders[1].hour - 12)" + ":" + "\(String(format: "%02d", reminders[1].minute))" + " PM"
                
            }
                
            else if (anchorComponents.hour == 12){
                afternoonTime.text = "\(reminders[1].hour)" + ":" + "\(String(format: "%02d", reminders[1].minute))" + " PM"
            }
                
            else {
                afternoonTime.text = "\(reminders[1].hour)" + ":" + "\(String(format: "%02d", reminders[1].minute))" + " AM"
            }
            
            // If there are afternoon meds
            if (reminders[1].meds.count != 0){
                // Clear old reminder
                self.removeNotification(identifier: "afternoon")
                
                // Schedule reminder for the afternoon meds
                self.scheduleReminder(medBlock: "afternoon", hour: reminders[1].hour, minute: reminders[1].minute)
            }
        }
    }
    
    /* Night picker changed */
    @IBAction func nightPickerChanged(_ sender: Any) {
        // Only change if it's not hidden
        if (!nightTimePicker.isHidden){
            // We only care about the hour and minute
            let unitFlags = Set<Calendar.Component>([.hour, .minute])
            
            // Get the components from the picker
            let anchorComponents = nightTimePicker.calendar.dateComponents(unitFlags, from: nightTimePicker.date)
            
            // Change the notification time
            reminders[2].hour = anchorComponents.hour!
            reminders[2].minute = anchorComponents.minute!
            
            // Save changes to disk
            Reminder.saveRemindersToDisk(reminders: reminders)
            
            // Change the label
            if (anchorComponents.hour! > 12){
                nightTime.text = "\(reminders[2].hour - 12)" + ":" + "\(String(format: "%02d", reminders[2].minute))" + " PM"
                
            }
                
            else if (anchorComponents.hour == 12){
                nightTime.text = "\(reminders[2].hour)" + ":" + "\(String(format: "%02d", reminders[2].minute))" + " PM"
            }
                
            else {
                nightTime.text = "\(reminders[2].hour)" + ":" + "\(String(format: "%02d", reminders[2].minute))" + " AM"
            }
            
            // If there are night meds
            if (reminders[2].meds.count != 0){
                // Clear old reminder
                self.removeNotification(identifier: "night")
                
                // Schedule reminder for the night meds
                self.scheduleReminder(medBlock: "night", hour: reminders[2].hour, minute: reminders[2].minute)
            }
        }
    }
    
    /* Times */
    @IBOutlet weak var morningTime: UILabel!
    @IBOutlet weak var afternoonTime: UILabel!
    @IBOutlet weak var nightTime: UILabel!
    
    /* Time pickers */
    @IBOutlet weak var morningTimePicker: UIDatePicker!
    @IBOutlet weak var afternoonTimePicker: UIDatePicker!
    @IBOutlet weak var nightTimePicker: UIDatePicker!
    
    /* Edit button */
    @IBOutlet weak var edit: UIButton!
    
    /* Edit button clicked */
    @IBAction func EditTimes(_ sender: Any) {
        // Change edit to done 
        if (edit.titleLabel?.text == "Edit Times"){
            edit.setTitle("Done", for: .normal)
        }
        
        // Change done to edit
        else {
            edit.setTitle("Edit Time", for: .normal)
        }
        
        // Toggle all the pickers on/off and labels off/on
        morningTimePicker.isHidden = !(morningTimePicker.isHidden)
        morningTime.isHidden = !(morningTime.isHidden)
        
        afternoonTimePicker.isHidden = !(afternoonTimePicker.isHidden)
        afternoonTime.isHidden = !(afternoonTime.isHidden)
        
        nightTimePicker.isHidden = !(nightTimePicker.isHidden)
        nightTime.isHidden = !(nightTime.isHidden)
    }

    /* Back button */
    @IBOutlet weak var backButton: UIButton!
    
    /* View did load */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set user notification center delegate to self
        UNUserNotificationCenter.current().delegate = self
        
        // Load meds from the disk
        let meds = Medication.loadMedsFromDisk()!
        
        print(reminders[0].hour)
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
        print(reminders[0].hour)
        
        // Hide the pickers 
        morningTimePicker.isHidden = true
        afternoonTimePicker.isHidden = true
        nightTimePicker.isHidden = true

        // Set the labels to the reminder times
        if (reminders[0].hour > 12){
            morningTime.text = "\(reminders[0].hour - 12)" + ":" + "\(String(format: "%02d", reminders[0].minute))" + " PM"
        }
            
        else if (reminders[0].hour == 12){
            morningTime.text = "\(reminders[0].hour)" + ":" + "\(String(format: "%02d", reminders[0].minute))" + " PM"
        }
            
        else {
            morningTime.text = "\(reminders[0].hour)" + ":" + "\(String(format: "%02d", reminders[0].minute))" + " AM"
        }
        
        if (reminders[1].hour > 12){
            afternoonTime.text = "\(reminders[1].hour - 12)" + ":" + "\(String(format: "%02d", reminders[1].minute))" + " PM"
            
        }
            
        else if (reminders[1].hour == 12){
            afternoonTime.text = "\(reminders[1].hour)" + ":" + "\(String(format: "%02d", reminders[1].minute))" + " PM"
        }
            
        else {
            afternoonTime.text = "\(reminders[1].hour)" + ":" + "\(String(format: "%02d", reminders[1].minute))" + " AM"
        }
        
        if (reminders[2].hour > 12){
            nightTime.text = "\(reminders[2].hour - 12)" + ":" + "\(String(format: "%02d", reminders[2].minute))" + " PM"
            
        }
            
        else if (reminders[2].hour == 12){
            nightTime.text = "\(reminders[2].hour)" + ":" + "\(String(format: "%02d", reminders[2].minute))" + " PM"
        }
            
        else {
            nightTime.text = "\(reminders[2].hour)" + ":" + "\(String(format: "%02d", reminders[2].minute))" + " AM"
        }
        
        
        

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


    /* Did receive memory warning */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* Remove user notificaitons with identifier */
    func removeNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    

}
