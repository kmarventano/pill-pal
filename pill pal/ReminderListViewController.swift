/*
 View with all reminders user has saved on the phone
 
 Clicking on a reminder time toggles all the medications taken at that time to be shown
 
 Emily Hayashi-Groves
 Kristen Marventano
 */

import UIKit

class ReminderListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var medArray:[Medication]!
    var morningArray = [Medication]()
    var afternoonArray = [Medication]()
    var nightArray = [Medication]()
    var markAfternoon : Int!
    var markNight : Int!
    var isRowHidden : [Bool]!
    
    
    @IBOutlet weak var medTable: UITableView!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.medTable.allowsMultipleSelectionDuringEditing = false;
        
        self.medTable.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        
        medTable.delegate = self
        medTable.dataSource = self
        
        // Load meds from the disk
        medArray = Medication.loadMedsFromDisk()!
    
        
        // Do any additional setup after loading the view.
        for med in medArray {
            if med.morning{
                morningArray.append(med) }  }
        
        for med in medArray {
            if med.afternoon{
                afternoonArray.append(med) }  }


        for med in medArray {
            if med.night{
                nightArray.append(med) }  }

        
        self.medTable.separatorColor = UIColor.clear;
        
        //mark represents where in the table the afternoon/night arrays should start to fill in
        self.markAfternoon = 1 + morningArray.count
        self.markNight = 1 + markAfternoon + afternoonArray.count
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //to decide how many rows are in the table, add the total number of meds in each array (some may appear more than once) and 3 for the labels
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let num : Int = morningArray.count + afternoonArray.count + nightArray.count + 3
        return num
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 40.0
    }
    
    //fill in the table view with labels for time of day and names of medications
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : UITableViewCell = medTable.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        if indexPath.row == 0{
            cell.textLabel?.text = "Morning"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 25.0)
        }
        if indexPath.row > 0 && indexPath.row <= morningArray.count{
            cell.textLabel?.text = morningArray[indexPath.row - 1].medicationName
        }
        
        if indexPath.row == markAfternoon{
            cell.textLabel?.text = "Afternoon"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 25.0)
        }
        if indexPath.row > markAfternoon && indexPath.row < markNight{
            cell.textLabel?.text = afternoonArray[indexPath.row - markAfternoon - 1].medicationName
        }

        if indexPath.row == markNight{
            cell.textLabel?.text = "Night"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 25.0)
        }
    
        if indexPath.row > markNight{
            cell.textLabel?.text = nightArray[indexPath.row - markNight - 1].medicationName
        }
        return cell
        
    
    
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
