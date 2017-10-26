//
//  ContactsTableViewController.swift
//  AddressBookSwift4
//
//  Created by Thomas on 25/10/2017.
//  Copyright © 2017 Thomas. All rights reserved.
//

import UIKit
import CoreData

class ContactsTableViewController: UITableViewController {

    var contacts = [Person]()
    let preferenceKey : String = "isFirstLaunch"
    let preference : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadDataFromDatabase()
        
     /*             METHODE DE BOURRIN --- Voir extension pour un truc plus sexy
        if let valuePreference = UserDefaults.standard.value(forKey: preferenceKey){
            print("la value est ", valuePreference)
        }else{
            print("first launch")
            
            let alertController = UIAlertController(title: "Bienvenue !", message: "Bienvenue sur la super application contact book! \n Vous pouvez dès à présent appuyer sur le bouton plus en haut à droite pour ajouter des contacts ", preferredStyle: .alert)
     
            let back = UIAlertAction(title: "OK", style: .default)

            alertController.addAction(back)
            self.present(alertController, animated:true)
            
           UserDefaults.standard.set(preference , forKey: preferenceKey)
        }
      */
        
        if(UserDefaults.standard.isFirstLaunch()){
            let alertController = UIAlertController(title: "Bienvenue !", message: "Bienvenue sur la super application contact book! \n Vous pouvez dès à présent appuyer sur le bouton plus en haut à droite pour ajouter des contacts ", preferredStyle: .alert)
            
            let back = UIAlertAction(title: "OK", style: .default)
            
            alertController.addAction(back)
            self.present(alertController, animated:true)
        }
        UserDefaults.standard.userSawWelcomeMessage()

        /*      AJOUT D'UN USER
 
        //NS MAnaged object context initialization
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
            let context = appDelegate.persistentContainer.viewContext
            let person = Person(entity: Person.entity(), insertInto: context)
            person.firstName = "Bilbo"
            person.lastName = "SAQUET"
            do{
                try context.save()
                }catch{
                    print(error.localizedDescription)
                }
            }
        
        
        */
        
        
        self.title = "My Contact"

        print("test")
   
        //Import a new name from a file
/*        let namesPlist = Bundle.main.path(forResource: "names.plist", ofType: nil)
        if let namePath = namesPlist{
            let url = URL(fileURLWithPath: namePath)
           let dataArray = NSArray(contentsOf: url)
                print(dataArray)
            
            for dict in dataArray!{
                if let dictionnary = dict as? [String : String]{
               //     let person  = Person(firstName: dictionnary["name"]!, lastName: dictionnary["lastname"]!)
               //     contacts.append(person)
                }
            }
        }
        */
        
 
        let addContact = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addContactPress))
        self.navigationItem.rightBarButtonItem = addContact

    }

    @objc func addContactPress(){
        //Create push addViewcontroller
        //set the delegate
        let controller = AddViewController(nibName: nil, bundle: nil)
        controller.delegate = self
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return contacts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath)

        if let contactCell = cell as? ContactTableViewCell{
            contactCell.firstNameLabel.text = contacts[indexPath.row].firstName
            contactCell.lastNameLabel.text = contacts[indexPath.row].lastName
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewController = DetailViewController(nibName: nil, bundle: nil)
        detailViewController.delegate = self
        detailViewController.person = self.contacts[indexPath.row]
        self.navigationController?.pushViewController(detailViewController, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func reloadDataFromDatabase(){
        let fetchRequest = NSFetchRequest<Person>(entityName : "Person")
        let sortFirstName = NSSortDescriptor(key: "firstName", ascending: true)
        let sortLastName = NSSortDescriptor(key: "lastName", ascending: true)
        fetchRequest.sortDescriptors = [sortFirstName , sortLastName]
        
        let context = self.appDelegate().persistentContainer.viewContext
        
        print (try? context.fetch(fetchRequest))
        
        guard let personDB = try? context.fetch(fetchRequest) else{
            return
        }
        contacts = personDB
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadDataFromDatabase()
    }

}

extension ContactsTableViewController : AddViewControllerDelegate{
    
    func addNewContact() {
        self.navigationController?.popViewController(animated: true)
        self.tableView.reloadData()
    }
}

extension ContactsTableViewController : DetailViewControllerDelegate{
    func deleteContact(deleteContact: Person){
        contacts = contacts.filter({$0 != deleteContact})
        self.navigationController?.popViewController(animated: true)
        self.tableView.reloadData()
        
        
        
    }
    
}
enum DefaultPreferencesKey : String{
    case isFirstLaunch = "isFirstLaunch"
}

extension UserDefaults {
    
    func isFirstLaunch() -> Bool{
        return (UserDefaults.standard.value(forKey: DefaultPreferencesKey.isFirstLaunch.rawValue) as? Bool) ?? true
    }
    func userSawWelcomeMessage(){
        UserDefaults.standard.set(false, forKey: DefaultPreferencesKey.isFirstLaunch.rawValue)
    }
}

