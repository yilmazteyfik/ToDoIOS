import UIKit
import RealmSwift
import ChameleonFramework

class ViewController: SwipeTableViewController {
    var toDoItems : Results<Item>?
    
    let realm = try! Realm()
    
    var selectedCatagory : Catagory?{
        didSet{
            loadItems()
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 70.0
        
        tableView.separatorStyle = .none
        
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let hexValueOfColor = selectedCatagory?.color else {fatalError()}
            
        title = selectedCatagory?.name
        
        updateNavBar(withHexCode: hexValueOfColor)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        guard let originalColour = UIColor(hexString: FlatWhite().hexValue()) else {fatalError()}
        
        updateNavBar(withHexCode: originalColour.hexValue())
    }
    //MARK: - Nav Bar Setup
    func updateNavBar(withHexCode colourHexCode : String){
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does NOT exist!")}
            
        guard let navBarColur = UIColor(hexString: colourHexCode) else {fatalError()}
         //   let navBarColur = FlatWhite()
                
        navBar.backgroundColor = navBarColur

        navBar.tintColor = ContrastColorOf(navBarColur, returnFlat: true)
                
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColur, returnFlat: true)]
                
        searchBar.barTintColor = navBarColur

    }
    
    
    // MARK: - TableView Data Sources
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        //cell.textLabel?.text = toDoItems?[indexPath.row].title ?? "No item Added Yet!"
        
        
        if let item = toDoItems?[indexPath.row]{
            
            cell.textLabel?.text = item.title
            
            let tmpCategoryColor : UIColor = UIColor(hexString: selectedCatagory?.color ?? FlatLime().hexValue()) ?? FlatLime()
            
            if let colour = tmpCategoryColor.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(toDoItems!.count)/4){
            
                cell.backgroundColor = colour
                
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            
            }
            
            
            cell.accessoryType = item.done ? .checkmark : .none
            
        }else {
            
            cell.textLabel?.text = "No Items Added!!"
        
        }

        return cell
    }
    // MARK: - TableView Delagate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = toDoItems?[indexPath.row]{
            do{
                try realm.write{
                    item.done = !item.done
                //  realm.delete(item)
                }
            }catch{
                print("Error Saving Done Status, \(error)")
            }
                
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    // MARK: - ADDING New item
    
    
    @IBAction func addButtonPresed(_ sender: UIBarButtonItem) {
        var textField =  UITextField()
        let allert = UIAlertController(title: "Add new ToDo item", message: "!!!", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: UIAlertAction.Style.default) { (action) in
            
            if let currentCategory = self.selectedCatagory{
                do{
                    try self.realm.write{
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                }catch{
                    print("Error Saving New Objects, \(error)")
                }
            }
            self.tableView.reloadData()

        }
        
        allert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            
        }
        
        allert.addAction(action)
        
        present(allert, animated: true, completion: nil)
        
    }
    //MARK: - DATA manupulations
    
   func loadItems(){
       toDoItems = selectedCatagory?.items.sorted(byKeyPath: "title", ascending: true)
       tableView.reloadData()
        
    }
    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath : IndexPath){
        print("item-deleted")
        if let itemForDeletion = self.toDoItems?[indexPath.row]{
            do{
                try self.realm.write{
                    self.realm.delete(itemForDeletion)
                }
            }catch{
                print("Error Deleting Item,\(error)")
            }
        }
    }
    
    
    
}


//MARK: - SearcBar Methods

extension ViewController : UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath:  "dateCreated" , ascending: false)
        tableView.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0{
            
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
    

        }
    }
    
}
