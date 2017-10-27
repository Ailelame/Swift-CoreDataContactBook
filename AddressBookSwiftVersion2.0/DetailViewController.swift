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
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Apply the data to the view
        firstNameLabel.text=person?.firstName
        lasNameLabel.text=person?.lastName
        print("Begin of code")
        var originalUrl : String = ""
        if person?.avatarURL == nil  || person?.avatarURL == "" {
            originalUrl = "http://www.apple.com/euro/ios/ios8/a/generic/images/og.png"
        }else{
            originalUrl = person!.avatarURL!
        }
        if let url = URL(string: originalUrl) {
            imageView.contentMode = .scaleAspectFit
            downloadImage(url: url)
        }
        print("End of code. The image will continue downloading in the background and it will be loaded when it ends.")
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
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    // Image Loading
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
