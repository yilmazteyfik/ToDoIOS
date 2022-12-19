import Foundation
import RealmSwift

class Item: Object{
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var dateCreated: Date?
    var parentCatogory = LinkingObjects(fromType: Catagory.self, property : "items")// invers relationship
    
}
  
