/*
 Scans the paper that comes with perscriptions for relevant info and saves it to phone
 
 Utilizes tesseract OCR to get all info from the perscription paper, parses for
 name, dosage, and instructions, then instructions are parsed for the time they
 should be taken
 
 User can edit all the information generated by tesseract
 
 Check boxes show when medicine should be taken based on insturction, user can
 check their preferred times to take their medication
 
 Emily Hayashi-Groves
 Kristen Marventano
 
 Sources:
 Tesseract OCR
 Ray Smith 
 https://github.com/tesseract-ocr/tesseract/blob/master/AUTHORS
 */

import UIKit

class BottleReaderViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate {

    // Image picker to get info from bottle
    var imagePicker = UIImagePickerController()
    
    // Variables to show if med should be taken morning, afternoon, or night
    var morning = false
    var afternoon = false
    var night = false
   
    
    @IBOutlet weak var animatedView: UIView!
    // Text fields for the medication
    @IBOutlet weak var medicationNameField: UITextField!
    @IBOutlet weak var medicationDosageField: UITextField!
    @IBOutlet weak var medicationInstructionField: UITextField!
    
    // Buttons for time medication should be taken
    @IBOutlet weak var morningButton: CheckBox!
    
    @IBOutlet weak var afternoonButton: CheckBox!
    @IBOutlet weak var nightButton: CheckBox!
    
    
    /* View Loaded */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set imagepicker delegate to self
        imagePicker.delegate = self
        
        // Set all the field delegates to self
        self.medicationNameField.delegate = self
        self.medicationDosageField.delegate = self
        self.medicationInstructionField.delegate = self
        
        
       
    }
    
   
    /* Segue */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    /* Memory warning */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /* Get keyboard to close */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }


    /* Scan info button */
    @IBAction func scanBottle(_ sender: Any) {
        // Bring up the camera
        self.presentCamera()
        
    }
    
    /* Button to add medication to list and go back to homepage */
    @IBAction func addMedication(_ sender: Any) {
        // If the name, dosage, or instruction is missing, disable button
        if ((medicationNameField.text?.isEmpty)! || (medicationDosageField.text?.isEmpty)! || (medicationInstructionField.text?.isEmpty)!){
            
        }
            
        // If all the fields are there
        else {
            // Load the saved medication list
            var meds = Medication.loadMedsFromDisk()!
            
            // Create the medication object
            let newMed = Medication(key: (meds.count), medicationName: medicationNameField.text!, medicationDosage: medicationDosageField.text!, instructions:
                medicationInstructionField.text!, morning: morningButton.status(), afternoon: afternoonButton.status(), night: nightButton.status())
            
            // Add medication to list
            meds.append(newMed!)
            
            // Save the medication to disk
            Medication.saveMedsToDisk(meds: meds)
            
            // Go back to homepage
            performSegue(withIdentifier: "HomePageSegue", sender: self)
        }
    }
    
    
    /* Prepares everything to go to camera */
    func presentCamera() {
        // Set image imagepicker to self and source type to camera
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        
        // Allow the user to zoom in on relevant details on bottle
        imagePicker.allowsEditing = true
        
        // Bring up the camera
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    /* If the user cancels the picture */
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    /* After photo is picked, scales it, extracts text, displays picture in viewcontroller */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // Get image
        var image = (info[UIImagePickerControllerEditedImage] as? UIImage)!
        
        // Scale it
        image = scaleImage(image: image, maxDimension: 2500)
        
        
        // Extract the text from image
        extractTextFromImage(image: image)
        
        // Go back to the view
        dismiss(animated: true, completion: nil)
    }
    
    /* Gets the text from the image */
    func extractTextFromImage(image: UIImage) {
        // Create object to scan for the text
        let tesseract = G8Tesseract()
        
        // All text will be in English
        tesseract.language = "eng"
        
        // Most accurate option
        tesseract.engineMode = .tesseractOnly
        
        // Allows for different paragraphs of text
        tesseract.pageSegmentationMode = .auto
        
        // Convert black and white image for best results
        tesseract.image = image.g8_blackAndWhite()
        
        // Extract text from image
        tesseract.recognize()
        
        // Get the name, dosage, and instructions from the extracted text
        parseForRelevantInfo(text: tesseract.recognizedText)
    }
    
    /* Scales image */
    func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        // Set desired size
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        var scaleFactor: CGFloat
        
        // If the image is wider than it is tall
        if image.size.width > image.size.height {
            // Create scaling factor
            scaleFactor = image.size.height / image.size.width
            
            // Set the width to be max demension
            scaledSize.width = maxDimension
            
            // Scale the height to match the proportions with new width
            scaledSize.height = scaledSize.width * scaleFactor
        }
            
            // If the image is taller than it is wide
        else {
            // Create scaling factor
            scaleFactor = image.size.width / image.size.height
            
            // Set height to be max demension
            scaledSize.height = maxDimension
            
            // Scale the width to match the proportions with the new height
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        // Scale the image to new proportions
        UIGraphicsBeginImageContext(scaledSize)
        image.draw(in: CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Return the scaled image
        return scaledImage!
    }
    
    /*  Parses through the extracted text for the name, dosage, and instructions, and displays to user
     
     Splits the block of extracted text by line, searches for index with the phone number
     after that line is the medication name, dosage, and instructions.
     */
    func parseForRelevantInfo(text: String) {
        // Variables for name, dosage, and instructions
        var name : String = ""
        var dosage : String = ""
        var instructions : String = ""
        
        // Split the text by new lines
        let splitTextArray = text.components(separatedBy: "\n")
        
        // Variables for count, and index of the line of text with the phone number
        var count : Int = 0
        var phoneIsHere : Int = 0
        
        // Go through every line of text
        for string in splitTextArray {
            // Check if the line is the phone number line
            if (string.hasPrefix("Ph")){
                // Save that index
                phoneIsHere = count
            }
            
            // Increment count
            count += 1
        }
        
        // Start at the line after where the phoneline is
        count = phoneIsHere + 1
        var cur : String
        
        // Loop until name, dosage and instructions are found
        while (name.isEmpty || dosage.isEmpty || instructions.isEmpty) {
            // Get the current string
            cur = splitTextArray[count]
            
            // Trim leading/trailing whitespace
            cur = cur.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            // If the line is empty, go to the next line
            if (cur.isEmpty){
                count += 1
                continue
            }
                
                // If the line has text, it's either the name/dosage line or the instructions line
            else {
                // If the name hasn't been found, its the name line
                if (name.isEmpty){
                    // Split line by spaces
                    let splitNameLine = cur.components(separatedBy: " ")
                    
                    // Find where dosage starts in the name line
                    var dosageIsHere : Int = 0
                    
                    // Loop through all strings in the name line
                    for string in splitNameLine {
                        // If the string is a number, that's where the dosage starts, break out of loop
                        if Float(string) != nil {
                            break;
                        }
                            
                            // If its a string, it's part of the name
                        else {
                            name.append(string + " ")
                            dosageIsHere += 1
                        }
                    }
                    
                    // Start where dosage is
                    var i = dosageIsHere
                    
                    // Loop until the end of the line
                    while (i < splitNameLine.count){
                        // Add the cur string to dosage
                        dosage.append(splitNameLine[i] + " ")
                        
                        // Increment counter
                        i += 1
                    }
                    
                    // Increment count
                    count += 1
                }
                    
                    // If the name has been found, skip 2 more lines to get the instructions
                else{
                    instructions = splitTextArray[count + 2]
                    break;
                }
            }
        }
        
        // Display the name, dosage, and instructions
        medicationNameField.text = name
        medicationDosageField.text = dosage
        medicationInstructionField.text = instructions
        
        // Parse for time to take meds, check off appropiate boxes
        parseForTimeToTake(instruction: instructions)
    }
    
    /* Parses instruction for the time the medication should be taken */
    func parseForTimeToTake(instruction : String) {
        // Split instruction by space
        let splitInstructions = instruction.components(separatedBy: " ")
        
        for string in splitInstructions {
            // Make string all lower case
            let string = string.lowercased()
            
            // Check if medicine should be taken in the morning/once a day
            if (string == "daily" || string == "once"){
                morningButton.changeStatus(checked: true)
            }
            
            // Check if medicine should be take twice a day
            if (string == "twice"){
                morningButton.changeStatus(checked: true)
                nightButton.changeStatus(checked: true)
            }
            
            // Check if medicine should be taken three times a day
            if (string == "thrice" ){
                morningButton.changeStatus(checked: true)
                afternoonButton.changeStatus(checked: true)
                nightButton.changeStatus(checked: true)
            }
            
            // Check if medicine should be taken at bedtime/night
            if (string == "night" || string == "bedtime"){
                nightButton.changeStatus(checked: true)
            }
            
            // Check if medicine should be taken in the afternoon
            if (string == "afternoon"){
                afternoonButton.changeStatus(checked: true)
            }
        }
        
    }
    
}
