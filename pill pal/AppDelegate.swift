/*
 App Delegate
 
 Emily Hayashi-Groves
 Kristen Marventano
 */

import UIKit
import AVFoundation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate{
    
    // Declare global window/audio player
    var window: UIWindow?
    var player: AVAudioPlayer?

    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {

            }
        }
        
        // Get path for the pill pop sound
        let url = Bundle.main.url(forResource: "pillPop", withExtension: "wav")!
        
        // Try and play the sound
        do {
            // Load the sound into the player
            player = try AVAudioPlayer(contentsOf: url)
            
            // If it fails, return true (end app delegate)
            guard let player = player
                else {
                    return true
            }
            
            // Prep and play the sound
            player.prepareToPlay()
            player.play()
        }
            
            // Catch the error
        catch let error {
            // Print the error message
            print(error.localizedDescription)
        }
        

        
        return true
    }
    
    func registerCategory() -> Void{
        
        let callNow = UNNotificationAction(identifier: "call", title: "Call now", options: [])
        let clear = UNNotificationAction(identifier: "clear", title: "Clear", options: [])
        let category : UNNotificationCategory = UNNotificationCategory.init(identifier: "CALLINNOTIFICATION", actions: [callNow, clear], intentIdentifiers: [], options: [])
        
        let center = UNUserNotificationCenter.current()
        center.setNotificationCategories([category])
        
    }
    
    func scheduleNotification (event : String, interval: TimeInterval) {
        let content = UNMutableNotificationContent()
        
        content.title = event
        content.body = "body"
        content.categoryIdentifier = "CALLINNOTIFICATION"
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: interval, repeats: false)
        let identifier = "id_"+event
        let request = UNNotificationRequest.init(identifier: identifier, content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: { (error) in
        })
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("didReceive")
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("willPresent")
        completionHandler([.badge, .alert, .sound])
    }
    
}
