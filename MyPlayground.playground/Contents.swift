import Foundation

struct Transactions {
    var value: Float
    var name: String
}

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
    var transactions: [Transactions] = []
    
    init(amount: Float, name: String) {
        self.amount = amount
        self.name = name
    }
    
    @discardableResult
    func addTransaction( transaction: Transactions) -> Float {
        if (amount - transaction.value) < 0{
            return 0
        }
        
        amount -= transaction.value
        transactions.append(transaction)
        
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

me.account?.addTransaction(
    transaction: Transactions(value: 20, name: "Cafe con amigos"))
me.account?.addTransaction(
    transaction: Transactions(value: 100, name: "Juego PS4"))
me.account?.addTransaction(
    transaction: Transactions(value: 3400, name: "MacbookPro"))


print(me.account!.amount)
print(me.fullName)
