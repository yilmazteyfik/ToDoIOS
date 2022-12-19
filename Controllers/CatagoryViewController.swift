import UIKit
import RealmSwift
import ChameleonFramework


class CatagoryViewController: SwipeTableViewController{
    
    let realm = try! Realm()
    
    var categories: Results<Catagory>?

    override func viewDidLoad() {
        super.viewDidLoad()
          
        loadCatagories()
        
        tableView.separatorStyle = .none
        
        tableView.rowHeight = 80.0
        guard let navBar = navigationController?.navigationBar else{fatalError("Navigation Controller does NOT exist!")}
        
        navBar.backgroundColor = FlatWhite()
        
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(FlatWhite(), returnFlat: true)]
        
    }
    
    // MARK: - Tableview data source methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return categories?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row]{
            
            cell.textLabel?.text = category.name
            
            guard let categoryColour = UIColor(hexString: category.color) else {fatalError()}
            
            
            cell.backgroundColor = categoryColour
            
            cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
            
        }
        
        return cell
    }
    
    

    //MARK: - TableView delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCatagory = categories?[indexPath.row]
            
        }
    }
    
    //MARK: - add new catagory
    

    @IBAction func addButtonPresed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let allert = UIAlertController(title: "Add new catagory" , message: "" ,preferredStyle: .alert)
        
        let action =  UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCatagory = Catagory()
            newCatagory.name = textField.text!
            newCatagory.color = UIColor.randomFlat().hexValue()
            
            self.save(Catagory: newCatagory)
            
        }
        allert.addAction(action)

        allert.addTextField { (allertTextField) in
            allertTextField.placeholder = "Create new Catagory"
            textField = allertTextField
            
            
        }
                
        present(allert, animated: true, completion: nil)
    }
    

    
    //MARK: - data manupulation
    func save(Catagory: Catagory){
        do{
            try realm.write{
                realm.add(Catagory) 
            }
        }catch{
            print("Error fetching data from request \(error)")
        }
        tableView.reloadData()
        
    }
    func loadCatagories(){
        
        categories = realm.objects(Catagory.self)

        tableView.reloadData()
        
    }
    //MARK: - Delete Data From Swpie
   override func updateModel(at indexPath : IndexPath){
       print("item-deleted")
       if let categoryForDeletion = self.categories?[indexPath.row]{
           do{
               try self.realm.write{
                   self.realm.delete(categoryForDeletion)
               }
           }catch{
               print("Error Deleting Category,\(error)")
               
           }
       }
   }
    
}

