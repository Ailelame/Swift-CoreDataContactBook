//
//  AppDelegate.swift
//  AddressBookSwift4
//
//  Created by Thomas on 25/10/2017.
//  Copyright © 2017 Thomas. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func updateDataFromServer(){
        let url = URL(string: "http://localhost:3000/persons")
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            
            guard let data = data else{
                return
            }
            let dictionary = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            
            guard let jsonDict = dictionary as? [[String : Any]] else{
                return
            }
            print(jsonDict)
            
            // fetch tableau
            
            self.updateDataFromJsonData(json: jsonDict)
            
            /*   let context = self.persistentContainer.viewContext
             for personDict in jsonDict{
             let person = Person(entity: Person.entity(), insertInto: context)
             person.firstName = personDict ["surname"] as? String ?? "DefaultName"
             person.lastName = personDict ["lastname"] as? String ?? "DefaultLastName"
             person.id = personDict ["id"] as? Int32 ?? -1
             }
             try? context.save()
             */
        }
        task.resume()
    }
    
    
    func updateDataFromJsonData(json: [[String : Any]]){
        let sort = NSSortDescriptor(key: "id", ascending: true)
        let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
        fetchRequest.sortDescriptors = [sort]
        
        let context = self.persistentContainer.viewContext
        let persons : [Person] = try! context.fetch(fetchRequest)
        let personIds = persons.map({ (p) -> Int32 in
            return p.id
        })
        
        let serversId = json.map { (dict) -> Int in
            return dict["id"] as? Int ?? 0
        }
        
        //Delete data that is not in the server
        for person in persons {
            if !serversId.contains(Int(person.id)){
                context.delete(person)
            }
        }
        
        // Update or create
        for jsonPerson in json{
            let id = jsonPerson["id"] as? Int ?? 0
            if let index = personIds.index(of: Int32 (id)){
                persons[index].lastName = jsonPerson["lastname"] as? String ?? "ERROR"
                persons[index].firstName = jsonPerson["surname"] as? String ?? "ERROR"
                persons[index].avatarURL = jsonPerson["pictureUrl"] as? String ?? "ERROR"
            }else{
                let person = Person(context: context)
                person.lastName = jsonPerson["lastname"] as? String
                person.firstName = jsonPerson["surname"] as? String
                person.avatarURL = jsonPerson["pictureUrl"] as? String
                person.id = Int32 (id)
            }
            
            do{
                if context.hasChanges{
                    try context.save()
                }
            }catch{
                print(error)
            }
            
            
        }
    }
    
    func addContact(firstName : String, lastName : String){
        let url = URL(string: "http://localhost:3000/persons")
        let newContact : [String: Any] = ["lastname" : lastName, "surname" : firstName, "pictureUrl" : "http://lageekerie.com/11912/figurine-pop-batman-arkham-knight.jpg"]
        print(newContact)
        
        var  request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: newContact, options: .prettyPrinted)
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        // Add other verbs here
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            /*              CORRECTION 
             if let data = data {
             let jsonDic = try? JSONSeialization.jsonObject(with : data, options : JSONSerialization.ReadingOptions.mutableContainers) as? [String : Any]
             
             guard let dict = jsonDict as? [String : Any] else{
                 return
             }
            
             let perosnne = Person(entity: Person.entity(), insertInto: sef.persistantContainer.viewContext)
                  person.lastName = dict["lastName"] as? String
                  person.firstName = dict["surname"] as? String
                  person.pictureURL = dict["pictureURL"] as? String
                  person.id = Int32(dict["id"] as? Int ?? 0
             SAVE CONTEXT
            */
            do {
                    guard let data = data, error == nil else {
                        print(error?.localizedDescription ?? "No data")
                        return
                    }
                    let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                    if let responseJSON = responseJSON as? [String: Any] {
                        print(responseJSON)
                    }
            
            } catch let error as NSError {
                print("json error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    //DELETE from server
    func deleteUser(id : Int32){
        let builtUrl = "http://localhost:3000/persons/\(id)"
      //  print(builtUrl)
        let url = URL(string: builtUrl )
        var  request = URLRequest(url: url!)
        request.httpMethod = "DELETE"
       // let newContact : [String: Any] = ["lastname" : person.lastName, "surname" : person.firstName, "pictureUrl" : person.avatarURL , "id" : person.id]
        //request.httpBody = try! JSONSerialization.data(withJSONObject: newContact, options: .prettyPrinted)
       // request.setValue("application/json", forHTTPHeaderField: "Content-type")
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            do {
           /*     guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    print(responseJSON)
                }
                */
            } catch let error as NSError {
                print("json error: \(error.localizedDescription)")
            }
        }
        task.resume()
        
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "AddressBookSwift4")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    
}

// Creation of an extension to ease the use of AppDelegate
// Allow to user AppDelegate from anywhere in the app
extension UIViewController{
    func appDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
}

