import Foundation

open class Person {
    private var firstName: String
    private var lastName: String
    
    public init(firstName: String, lastName: String){
        self.firstName = firstName
        self.lastName = lastName
    }
    
    open func changeName(firstName: String, lastName: String){
        sleep(1)
        self.firstName = firstName
        sleep(1)
        self.lastName = lastName
    }
    
    open var name: String {
        return "\(firstName) \(lastName)"
    }
}
 
