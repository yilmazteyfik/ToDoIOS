import Foundation
import RealmSwift
import ChameleonFramework

class Catagory : Object{
    @objc dynamic var name : String = ""
    @objc dynamic var color : String = ""
    let items = List<Item>()// forward relationships
    
}

