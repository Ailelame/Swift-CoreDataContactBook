//
//  DetailViewController.swift
//  AddressBookSwift4
//
//  Created by Thomas on 25/10/2017.
//  Copyright © 2017 Thomas. All rights reserved.
//

import UIKit

protocol DetailViewControllerDelegate: AnyObject {
    func deleteContact()
}

class DetailViewController: UIViewController {

    weak var person : Person?
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lasNameLabel: UILabel!
    @IBOutlet weak var abortButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var imageView: UIImageView!
    weak var delegate: DetailViewControllerDelegate?
    var isCancelled = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        firstNameLabel.text=person?.firstName                                               // Assign FirstNAme
        lasNameLabel.text=person?.lastName                                                  // Assign lastNAme
        
        // Methods to get the image
        print("Begin of code")
        var originalUrl : String = ""
        if person?.avatarURL == nil  || person?.avatarURL == "" || person?.avatarURL == "ERROR" {  // Check if the avatarUrl of the object is usable
            originalUrl = "http://www.apple.com/euro/ios/ios8/a/generic/images/og.png"      // Default Url
        }else{
            originalUrl = person!.avatarURL!                                                //Assign correct url
        }
        if let url = URL(string: originalUrl) {
            downloadImage(url: url)                                                         // Download the picture
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func deleteAction(_ sender: Any) {
                                            // Alert before deleting
        let alertController = UIAlertController(title: "Suppression", message: "Voulez vous vraiment supprimer ce contact?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let back = UIAlertAction(title: "OK", style: .default) { ( back) in
            
            self.progressBar.alpha = 1                                                      // Show progressBar
            self.abortButton.alpha = 1                                                      // Show abort button
            self.deleteButton.alpha = 0                                                     // Hide delete button
            
            self.launchProgressBar {                                                        // closure at the end of the progress bar
                self.appDelegate().deleteUser(id: self.person!.id)                          // Remove from server
                let context = self.appDelegate().persistentContainer.viewContext            // Instantiate DB
                context.delete(self.person!)                                                // Remove person from database
                try? context.save()                                                         // Save context
                 self.delegate?.deleteContact()                                             // Follow the delegate and go back to list view
            }
        }
        alertController.addAction(cancelAction)                                             // Alert assignation
        alertController.addAction(back)                                                     // Alert assignation
        self.present(alertController, animated:true)                                        // Show alert
        
    }
    @IBAction func abortButton(_ sender: Any) {                                             // Allows the user to cancel the removal of the contact
        if(isCancelled == false){
           isCancelled=true                                                                 // Toggle the isCancelled variable to abord the progress of the progressbar
           progressBar.setProgress(0, animated: true)                                       // Reinitialize the progress bar
        }
    }
    
    // Progress bar method
    func launchProgressBar(closure:@escaping () -> ()){
        DispatchQueue.global(qos: .userInitiated).async {
            var counter : Float = 0                                                         // Initialize the counter
            while(counter<1 && !self.isCancelled){                                          // Check if the counter is not at the end or if it hasn't been cancelled
                counter = counter + 0.01
                print("compteur = \(counter)")
                DispatchQueue.main.async {
                     self.progressBar.setProgress(counter, animated: true)                   //updating the progressBar
                }
                Thread.sleep(forTimeInterval: 0.05)
            }
            DispatchQueue.main.async {                                                       // At the end of the progress, check if it has not been aborted
                if(!self.isCancelled){
                    closure()
                }
                self.progressBar.alpha = 0                                                   // Hide the progress bar, the abort button and shows the delete button
                self.abortButton.alpha = 0
                self.deleteButton.alpha = 1
                self.isCancelled=false
            }
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) { // function to get the image
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    // Method to load the image and assign it to the view
    func downloadImage(url: URL) {
        print("Download Started")
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.imageView.image = UIImage(data: data)
            }
        }
    }

   

}
