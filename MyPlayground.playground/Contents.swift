import Foundation

protocol InvalidateTransaction {
    func invalidateTransaction(transaction: Transaction)
}

protocol Transaction {
    var value: Float { get }
    var name: String { get }
    var isValid: Bool { get set }
    var delegate: InvalidateTransaction? {get set}
}

extension Transaction {
    mutating func invalidateTransaction(){
        isValid = false

        delegate?.invalidateTransaction(transaction: self)
    }

}
protocol TransactionDebit: Transaction {
    var category: DebitCategories { get }
}

enum DebitCategories: Int{
    case healt
    case food, rent, tax
    case transportation, entretaining = 10
}

enum TransactionType {
    case debit(value: Float, name: String, category: DebitCategories)
    case gain(value: Float, name: String)
}

class Debit: TransactionDebit{
    var delegate: InvalidateTransaction?
    var value : Float
    var name: String
    var category: DebitCategories
    var isValid: Bool = true
    init(value: Float, name: String, category:DebitCategories) {
        self.category = category
        self.value = value
        self.name = name
    }
    
}

class Gain: Transaction{
    var delegate: InvalidateTransaction?
    var value: Float
    var name: String
    var isValid : Bool = true
    
    init(value: Float, name: String){
        self.value = value
        self.name = name
    }
    
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
    var transactions: [Transaction] = []
    var debits: [Debit] = []
    var gains: [Gain] = []
    init(amount: Float, name: String) {
        self.amount = amount
        self.name = name
    }
    
    @discardableResult
    func addTransaction( transaction: TransactionType) -> Transaction? {
        switch transaction {
        case .debit(let value, let name, let category):
            if (amount - value) < 0{
                return nil
            }
            let debit = Debit(value: value, name: name, category: category)
            debit.delegate = self
            amount -= debit.value
            transactions.append(debit)
            debits.append(debit)
            return debit
        case .gain(let value, let name):
            let gain = Gain(value:value, name:name)
            gain.delegate = self
            amount += gain.value
            transactions.append(gain)
            gains.append(gain)
            return gain
        }
        
    }
    /*
    func debits() -> [Transactions]{
        return transactions.filter({$0 is Debit})
    }
    func gains() -> [Transactions]{
        return transactions.filter({$0 is Gain})
    }
    */
    func transactionsFor(category: DebitCategories) -> [Transaction] {
        return transactions.filter({ (transaction) -> Bool in
            guard let transaction = transaction as? Debit else{
                return false
            }
            return transaction.category == category
        })
    }
}

extension Account: InvalidateTransaction {
    func invalidateTransaction(transaction: Transaction) {
        if transaction is Debit{
            amount += transaction.value
        }
        if transaction is Gain{
            amount -= transaction.value
        }
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
    transaction: .debit(
        value: 20,
        name: "Cafe con amigos",
        category:DebitCategories.food
    )
)

me.account?.addTransaction(
    transaction: .debit(
        value: 100,
        name: "Juego PS4",
        category:.entretaining
    )
)

me.account?.addTransaction(
    transaction: .debit(
        value: 3400,
        name: "MacbookPro",
        category:.entretaining
    )
)

me.account?.addTransaction(
    transaction: .gain(
        value: 1200,
        name: "Rembolso compra"
    )
)

me.account?.addTransaction(
    transaction: .gain(
        value: 1200,
        name: "Salario"
    )
)

var salary = me.account?.addTransaction(
    transaction:.gain(
        value: 1200,
        name: "Salario"
    )
)

salary?.invalidateTransaction()

print(me.account!.amount)
print(me.fullName)
let transactions = me.account?.transactionsFor(category: .entretaining) as? [Debit]
for transaction in transactions ?? []{
     print(
        transaction.name,
        transaction.value,
        transaction.category.rawValue
    )
}

for gain in me.account?.gains ?? [] {
    print(gain.name, gain.isValid, gain.value)
}

print(me.account?.amount ?? 0)
