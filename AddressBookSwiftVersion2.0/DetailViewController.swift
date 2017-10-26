//
//  DetailViewController.swift
//  AddressBookSwift4
//
//  Created by Thomas on 25/10/2017.
//  Copyright © 2017 Thomas. All rights reserved.
//

import UIKit

protocol DetailViewControllerDelegate: AnyObject {
    func deleteContact(deleteContact: Person)
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

        firstNameLabel.text=person?.firstName
        lasNameLabel.text=person?.lastName
        
        
    }

    override func viewDidAppear(_ animated: Bool) {
        
      
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        guard let contact = person else{
            return
        }
        
        let alertController = UIAlertController(title: "Suppression", message: "Voulez vous vraiment supprimer ce contact?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let back = UIAlertAction(title: "OK", style: .default) { ( back) in
            self.progressBar.alpha = 1
            self.abortButton.alpha = 1
            self.launchProgressBar {
                 self.delegate?.deleteContact(deleteContact: contact)
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(back)
        self.present(alertController, animated:true)
        
    }
    @IBAction func abortButton(_ sender: Any) {
        if(isCancelled == false){
           isCancelled=true
           progressBar.setProgress(0, animated: true)
        }
        
    }
    
    func launchProgressBar(closure:@escaping () -> ()){
        DispatchQueue.global(qos: .userInitiated).async {
            var counter : Float = 0
            while(counter<1 && !self.isCancelled){
                counter = counter + 0.01
                print("compteur = \(counter)")
                DispatchQueue.main.async {
                     self.progressBar.setProgress(counter, animated: true)
                    if(counter>45){
                        self.progressBar.progressTintColor = UIColor .yellow
                    }
                    if(counter>75){
                        self.progressBar.progressTintColor = UIColor .red
                    }
                }
               
                Thread.sleep(forTimeInterval: 0.05)
            }
            DispatchQueue.main.async {
                if(!self.isCancelled){
                    closure()
                }
                self.progressBar.alpha = 0
                self.abortButton.alpha = 0
                self.isCancelled=false
            }
        }
    }
   

}
