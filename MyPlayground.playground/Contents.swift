import Foundation

struct Account {
    var amount: Float = 0
    var name: String = ""
    var transactions: [Float] = []
    
    init(amount: Float, name: String) {
        self.amount = amount
        self.name = name
    }
    
    @discardableResult
    mutating func addTransaction(value: Float) -> Float {
        if (amount - value) < 0{
            return 0
        }
        
        amount -= value
        transactions.append(value)
        return amount
    }
}

struct Person{
    var name: String
    var lastName: String
    var account: Account?
}

var me = Person(name: "Eduardo", lastName: "Imery", account: nil)
let account = Account(amount: 100_000, name: "X Bank")

me.account = account

print(me.account!)
