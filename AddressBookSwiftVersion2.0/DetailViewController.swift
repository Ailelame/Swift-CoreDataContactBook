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
    @IBOutlet weak var progressBar: UIProgressView!
    weak var delegate: DetailViewControllerDelegate?
    var isCancelled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Apply the data to the view
        firstNameLabel.text=person?.firstName
        lasNameLabel.text=person?.lastName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        guard let contact = person else{
            return
        }
        // Alert before deleting
        let alertController = UIAlertController(title: "Suppression", message: "Voulez vous vraiment supprimer ce contact?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let back = UIAlertAction(title: "OK", style: .default) { ( back) in
            //  Show the progress bar and the abort button
            self.progressBar.alpha = 1
            self.abortButton.alpha = 1
            // closure at the end of the progress bar
            self.launchProgressBar {
                //remove the person from the database
                 let context = self.appDelegate().persistentContainer.viewContext
                context.delete(self.person!)
                try? context.save()
                 self.delegate?.deleteContact()
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(back)
        self.present(alertController, animated:true)
        
    }
    @IBAction func abortButton(_ sender: Any) {
        // Allows the user to cancel the removal of the contact
        if(isCancelled == false){
           isCancelled=true
           progressBar.setProgress(0, animated: true)
        }
    }
    
    // Progress bar method
    func launchProgressBar(closure:@escaping () -> ()){
        DispatchQueue.global(qos: .userInitiated).async {
            var counter : Float = 0
            // Counter
            while(counter<1 && !self.isCancelled){
                counter = counter + 0.01
                print("compteur = \(counter)")
                DispatchQueue.main.async {
                    //updating the progressBar
                     self.progressBar.setProgress(counter, animated: true)
                }
               
                Thread.sleep(forTimeInterval: 0.05)
            }
            DispatchQueue.main.async {
                // At the end of the progress, check if it has not been aborted
                if(!self.isCancelled){
                    closure()
                }
                //Hide the progress bar and the abort button
                self.progressBar.alpha = 0
                self.abortButton.alpha = 0
                self.isCancelled=false
            }
        }
    }
   

}
