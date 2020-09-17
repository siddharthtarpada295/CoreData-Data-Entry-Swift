
import UIKit
import CoreData

class ViewController: UIViewController
{

    @IBOutlet weak var tblview: UITableView!
    var people : [NSManagedObject] = []
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "Employee List";
        tblview.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tblview.tableFooterView = UIView()
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        let name = "Siddharth"
        self.save(name: name)
        
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate
        else
        {
            return
        }
        let managedcontext = appdelegate.persistentContainer.viewContext
        let fetchrequest = NSFetchRequest<NSManagedObject>(entityName: "Employee")
        
        do
        {
            people = try managedcontext.fetch(fetchrequest)
            tblview.reloadData()
        }
        catch let error as NSError
        {
            print("Data could not fatch. \(error), \(error.userInfo)")
        }
        
    }

    @IBAction func btnAdd(_ sender: Any)
    {
        let alert = UIAlertController(title: "New Employee  Entry", message: "Enter Name Here", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            
            action in
            
                guard let textField = alert.textFields?.first,
                      let nameToSave = textField.text
                else
                {
                        return
                }
            
        
        self.save(name: nameToSave)
        self.tblview.reloadData()
        });
        let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancel)
        
        present(alert,animated: true)
    }
    
    func save(name : String)
    {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate
        else
        {
            return
        }
        
        let managedcontext = appdelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Employee", in: managedcontext)!
        let persion = NSManagedObject(entity: entity, insertInto: managedcontext)
        persion.setValue(name, forKey: "name")
        
        do
        {
            try managedcontext.save()
            
            people.append(persion)
        }
        catch let error as NSError
        {
            print("Data Could Not FOund. \(error), \(error.userInfo)")
        }
        
        
    }
    
    func update(newText: String,index:Int)
    {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else
        {
            return
        }
        let managedContext = appdelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Employee", in: managedContext)!
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Employee")
        
        
        do
        {
            let text = try managedContext.fetch(fetchRequest)
            
            let obj = text[index] as! NSManagedObject
            obj.setValue(newText, forKey: "name")
            
            do
            {
                try managedContext.save()
            }
            catch
            {
                print(error)
            }
            
        }
        catch
        {
            print(error)
        }
        
    }
    
}

extension ViewController : UITableViewDataSource,UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = people[indexPath.row].value(forKey: "name") as! String
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        let cell = tableView.cellForRow(at: indexPath)
        let persion = cell?.textLabel?.text
        let alert = UIAlertController(title: "Select AnyOne", message: "Update Or Delete", preferredStyle: .alert)
        let updateAction = UIAlertAction(title: "Update", style: .default, handler: {
            
            action in
            guard let textField = alert.textFields?.first,
            let newText = textField.text
                
                else{
                return
            }
            
            self.update(newText: newText, index: indexPath.row)
            self.tblview.reloadData()
        });
        let Delete = UIAlertAction(title: "Delete", style: .default, handler: {
           action in
            
            guard let appdelegate = UIApplication.shared.delegate as? AppDelegate
                else
            {
                return
            }
            
            let managedcontext = appdelegate.persistentContainer.viewContext
            
            
            let entity = NSEntityDescription.entity(forEntityName: "Employee", in: managedcontext)!
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Employee")
            
            do
            {
                self.people = try managedcontext.fetch(fetchRequest)
                let obj = self.people[indexPath.row]
                
                
                managedcontext.delete(obj)
              
                
                
                        do
                        {
                            try managedcontext.save()

                        }
                        catch let error as NSError
                        {
                            
                            print("Could not save. \(error), \(error.userInfo)")
              }

               self.people = try managedcontext.fetch(fetchRequest)
            }
            catch let error as NSError
            {
                print("Could not save. \(error), \(error.userInfo)")
            }
            self.tblview.reloadData()
        }
            
    )
        alert.addTextField { (textField) -> Void in
           let p = self.people[indexPath.row]
            textField.text = p.value(forKey: "name") as! String
        }
        alert.addAction(updateAction)
        alert.addAction(Delete)
        
        present(alert,animated: true)
    }

    
    

}
