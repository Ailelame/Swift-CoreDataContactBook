//
//  AddViewController.swift
//  AddressBookSwift4
//
//  Created by Thomas on 25/10/2017.
//  Copyright © 2017 Thomas. All rights reserved.
//

import UIKit

protocol AddViewControllerDelegate: AnyObject {
    func addNewContact()
}

class AddViewController: UIViewController {

    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    
    weak var delegate: AddViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let validateCreation = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(validateContact))
        self.navigationItem.rightBarButtonItem = validateCreation
        
    }
    
    @objc func validateContact(){
        guard let firstName : String = self.firstNameTF?.text , let lastName = self.lastNameTF?.text  else{
            return
        }
        if(lastName == "" || firstName == "" ){
            return
        }
        // Add the contact to the DB
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
            let context = appDelegate.persistentContainer.viewContext
            let person = Person(entity: Person.entity(), insertInto: context)
            person.firstName = firstName
            person.lastName = lastName
            do{
                try context.save()
            }catch{
                print(error.localizedDescription)
            }
            self.delegate?.addNewContact()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
