/*
 View for the medicine description
 
 Shows user name, dosage, instructions, and pic of medicine
 Contains button to webpage with information about the medicine (uses, side effect, ect.)
 
 Emily Hayashi-Groves
 Kristen Marventano
 */

import UIKit

class MedicineDescriptionViewController: UIViewController {
    // Labels for medicine's name, dosage, instructions
    @IBOutlet weak var medName: UILabel!
    @IBOutlet weak var medDosage: UILabel!
    @IBOutlet weak var medInstructions: UILabel!
    
    // The medication that was clicked on for more info
    var med : Medication!
    
    /* Takes user to the website of medicine for more information */
    @IBAction func goToWeb(_ sender: Any) {
        // Pages on drugs.com of the form drugs.com -med name- .html
        let url : NSURL = NSURL(string: "http://drugs.com/" + medName.text! + ".html")!
        
        // Open the webpage
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    }
    
    /* View loaded */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Display the given text
        medName.text = med.medicationName
        medDosage.text = med.medicationDosage
        medInstructions.text = med.instructions
    }

    /* Memory warning */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
