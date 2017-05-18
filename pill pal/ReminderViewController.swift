/*
 Screen user is taken to after a reminder has been acknowledged
 
 Shows user the medications to be taken at the time, and the instructions for each medication
 Rewards user with animation for taking their medicine
 
 Emily Hayashi-Groves
 Kristen Marventano
 */

import UIKit
import SpriteKit

class ReminderViewController: UIViewController{
    var meds  = [Medication]()
    var box : UIImageView?
    var animator:UIDynamicAnimator? = nil;
    let gravity = UIGravityBehavior()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBox(location: CGRect(origin: CGPoint(x: 0,y :100), size: CGSize(width: 250, height: 250)))
    }
    
    
    func createAnimatorStuff() {
        animator = UIDynamicAnimator(referenceView:self.view);
       
        
        gravity.addItem(box!);
        gravity.gravityDirection = CGVectorFromString("0.0, 0.8")
        animator?.addBehavior(gravity);
        
    }
    func addBox(location: CGRect){
        let newBox = UIImageView(frame: location)
        newBox.image = #imageLiteral(resourceName: "final-actually.png")
        view.insertSubview(newBox, at: 0)
        box = newBox
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
