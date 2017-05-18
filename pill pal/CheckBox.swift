/*
 Custom botton for checkboxes 
 
 Can either be checked or unchecked
 
 Emily Hayashi-Groves
 Kristen Marventano
 */

import UIKit

class CheckBox: UIButton {
    // Pictures of the checked box and unchecked box
    let checkedBox = UIImage(named: "checkmark.png")! as UIImage
    let uncheckedBox = UIImage(named: "checkbox.png")! as UIImage
    
    // Button keeps track of if it's checked or not
    var isChecked: Bool = false {
        // Check state
        didSet{
            // If checked, show the checked box
            if isChecked == true {
                self.setImage(checkedBox, for: .normal)
            }
            
            // If it's not checked, show the unchecked box
            else {
                self.setImage(uncheckedBox, for: .normal)
            }
        }
    }
    
    /* When view is loaded */
    override func awakeFromNib() {
        // Create the button
        self.addTarget(self, action: #selector(CheckBox.buttonClicked(_:)), for: UIControlEvents.touchUpInside)
        
        // Start unchecked
        self.isChecked = false
    }
    
    /* When the button is clicked, flip state of isChecked (uncheck and check) */
    func buttonClicked(_ sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }

    /* Returns if button is checked or unchecked */
    func status() -> Bool {
        return isChecked
    }
    
    /* Changes status of button based on input */
    func changeStatus(checked : Bool){
        isChecked = checked
    }
}
