import Foundation

class Account {
    var amount: Float = 0{
        willSet{
            print("Vamos a cambiar el valor", amount, newValue)
        }
        didSet{
            print("Tenemos nuevo valor",amount)
        }
    }
    var name: String = ""
    var transactions: [Float] = []
    
    init(amount: Float, name: String) {
        self.amount = amount
        self.name = name
    }
    
    @discardableResult
    func addTransaction(value: Float) -> Float {
        if (amount - value) < 0{
            return 0
        }
        
        amount -= value
        transactions.append(value)
        return amount
    }
}

class Person{
    var name: String
    var lastName: String
    var account: Account?
    
    var fullName: String {
        get{
            return "\(name) \(lastName)"
        }
        set{
            name = String(newValue.split(separator: " ").first ?? "")
            lastName = "\(newValue.split(separator: " ").last ?? "" )"
        }
    }
    
    init(name: String, lastName: String) {
        self.name = name
        self.lastName = lastName
    }
}

var me = Person(name: "Eduardo", lastName: "Imery")
var account = Account(amount: 100_000, name: "X Bank")

me.account = account

print(me.account!)

account.addTransaction(value: 20)
me.account?.addTransaction(value: 20)

print(me.account!.amount)
print(me.fullName)

me.fullName = "Imery Edward"
print(me.fullName)
print(me.name)
