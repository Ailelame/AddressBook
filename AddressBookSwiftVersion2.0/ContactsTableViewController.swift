//
//  ContactsTableViewController.swift
//  AddressBookSwift4
//
//  Created by Thomas on 25/10/2017.
//  Copyright © 2017 Thomas. All rights reserved.
//

import UIKit
import CoreData

/*
         Entry point of the app
 
         Samples of code available at the end (* In french *)
 */


class ContactsTableViewController: UITableViewController {

    var contacts = [Person]()
    let preferenceKey : String = "isFirstLaunch"
    let preference : Bool = false
    
    var resultController : NSFetchedResultsController<Person>!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check out the data from the server
        appDelegate().updateDataFromServer()
        let fetchRequest = NSFetchRequest<Person>(entityName : "Person")
        let sortFirstName = NSSortDescriptor(key: "firstName", ascending: true)
        let sortLastName = NSSortDescriptor(key: "lastName", ascending: true)
        fetchRequest.sortDescriptors = [sortFirstName , sortLastName]
        resultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.appDelegate().persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        resultController.delegate = self
        
        try? resultController.performFetch()
        self.tableView.reloadData()
        
        // check if it's the first time the user launch the app
        if(UserDefaults.standard.isFirstLaunch()){
            // Alert to welcome him
            let alertController = UIAlertController(title: "Bienvenue !", message: "Bienvenue sur la super application contact book! \n Vous pouvez dès à présent appuyer sur le bouton plus en haut à droite pour ajouter des contacts ", preferredStyle: .alert)
            let back = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(back)
            self.present(alertController, animated:true)
        }
        
        /// Line ensuring that the user will not see the message anymore
        UserDefaults.standard.userSawWelcomeMessage()
        
        // Setting up the title
        self.title = "My Contact"
 
        // Adding an add button with navigation
        let addContact = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addContactPress))
        self.navigationItem.rightBarButtonItem = addContact

    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Make sure that the table is up to date when the view is called
        //   reloadDataFromDatabase()
    }

    @objc func addContactPress(){
        // Setting up the delegate
        let controller = AddViewController(nibName: nil, bundle: nil)
        controller.delegate = self
    
        self.navigationController?.pushViewController(controller, animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if let frc = self.resultController {
            return frc.sections!.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard let sections = self.resultController?.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }

        // Adapt the cells of the table to the array of persons
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath)
        
        if let contactCell = cell as? ContactTableViewCell {
            
            let person = resultController.object(at: indexPath)
            contactCell.firstNameLabel.text = person.firstName
            contactCell.lastNameLabel.text = person.lastName
            contactCell.avatarUrl = person.avatarURL
            
          
            
        }
        return cell
    }
    
    // Onclick on each cells
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let contact = self.resultController?.object(at: indexPath) else{
            return
        }
        
        let detailViewController = DetailViewController(nibName: nil, bundle: nil)
        detailViewController.delegate = self
        detailViewController.person = contact
        self.navigationController?.pushViewController(detailViewController, animated: true)
        
    }
    
    // Control of the height of each cells
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // Method in charge of loading the data from the DB
/*    func reloadDataFromDatabase(){
        // Gonna fetch the Persons in the DB
        let fetchRequest = NSFetchRequest<Person>(entityName : "Person")
        let sortFirstName = NSSortDescriptor(key: "firstName", ascending: true)
        let sortLastName = NSSortDescriptor(key: "lastName", ascending: true)
        fetchRequest.sortDescriptors = [sortFirstName , sortLastName]
        
        resultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: NSManagedObjectContext, sectionNameKeyPath: self.appDelegate().persistentContainer.viewContext, cacheName: nil)
        resultController.delegate = self
        
        let context = self.appDelegate().persistentContainer.viewContext
        print (try? context.fetch(fetchRequest))
        
        guard let personDB = try? context.fetch(fetchRequest) else{
            return
        }
        // Filling the array of persons
        contacts = personDB
        self.tableView.reloadData()
    }
    */

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 


}

extension ContactsTableViewController : AddViewControllerDelegate{
    
    func addNewContact() {
        self.navigationController?.popViewController(animated: true)
       // self.tableView.reloadData()
    }
}

extension ContactsTableViewController : DetailViewControllerDelegate{
    func deleteContact(){
        self.navigationController?.popViewController(animated: true)
     //   self.tableView.reloadData()
    }
    
}
// Allow the use of a variable in the extension
enum DefaultPreferencesKey : String{
    case isFirstLaunch = "isFirstLaunch"
}

extension UserDefaults {
    // Ease the use of the UserDefaults
    func isFirstLaunch() -> Bool{
        return (UserDefaults.standard.value(forKey: DefaultPreferencesKey.isFirstLaunch.rawValue) as? Bool) ?? true
    }
    func userSawWelcomeMessage(){
        UserDefaults.standard.set(false, forKey: DefaultPreferencesKey.isFirstLaunch.rawValue)
    }
}

extension ContactsTableViewController : NSFetchedResultsControllerDelegate{
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.reloadData()
    }
    
}

   









/*
 
                             *********** COMMENT SECTION *************
 
 

         CONTACTER LA BASE DE DONNEES        METHODE DE BOURRIN --- Voir extension pour un truc plus sexy
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
 
 
 
         AJOUT D'UN USER A LA BDD
 
         NS MAnaged object context initialization
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
 
 
 
         CHARGER DES DONN2ES DEPUIS UN FICHIER EN DUR
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
 
 */
