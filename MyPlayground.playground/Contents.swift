import Foundation

extension Date {
    init(year:Int, month:Int, day:Int){
        let calendar =  Calendar(identifier: .gregorian)
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.day = day
        dateComponents.month = month
        self = calendar.date(from: dateComponents) ?? Date()
    }
}

protocol InvalidateTransaction {
    func invalidateTransaction(transaction: Transaction)
}

typealias TransactionHandler = ( (_ completed: Bool, _ confirmation: Date) -> Void )

protocol Transaction {
    var value: Float { get }
    var name: String { get }
    var isValid: Bool { get set }
    var delegate: InvalidateTransaction? {get set}
    var date: Date { get }
    var handler: TransactionHandler? { get set }
    var completed: Bool { get }
    var confirmation: Date? {get}
}

extension Transaction {
    mutating func invalidateTransaction(){
        if completed {
            isValid = false
            delegate?.invalidateTransaction(transaction: self)
        }
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
    case debit(value: Float, name: String, category: DebitCategories, date: Date)
    case gain(value: Float, name: String, date: Date)
}

class Debit: TransactionDebit{
    var date: Date
    var delegate: InvalidateTransaction?
    var value : Float
    var name: String
    var category: DebitCategories
    var isValid: Bool = true
    var handler: TransactionHandler?
    var completed: Bool = false
    var confirmation: Date?
    init(value: Float, name: String, category:DebitCategories, date: Date) {
        self.category = category
        self.value = value
        self.name = name
        self.date = date
        DispatchQueue.main.asyncAfter(deadline: .now()){
            self.handler?(true, Date())
            print("Confirmed transaction", Date())
        }
    }
    
}

class Gain: Transaction{
    var date: Date
    var delegate: InvalidateTransaction?
    var value: Float
    var name: String
    var isValid : Bool = true
    var handler: TransactionHandler?
    var completed: Bool = false
    var confirmation: Date?
    init(value: Float, name: String, date: Date){
        self.value = value
        self.name = name
        self.date = date
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            self.handler?(true, Date())
            print("Confirmed transaction", Date())
        }
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
        case .debit(let value, let name, let category, let date):
            if (amount - value) < 0{
                return nil
            }
            let debit = Debit(value: value, name: name, category: category, date: date)
            debit.delegate = self
            
            debit.handler = { (completed, confirmation) in
                debit.confirmation = confirmation
                self.amount -= debit.value
                self.transactions.append(debit)
                self.debits.append(debit)
            }
            return debit
        case .gain(let value, let name, let date):
            let gain = Gain(value:value, name:name, date: date)
            gain.delegate = self
            gain.handler = { (completed, confirmation) in
                gain.confirmation = confirmation
                self.amount += gain.value
                self.transactions.append(gain)
                self.gains.append(gain)
            }

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
        category:DebitCategories.food,
        date: Date(year: 2019, month: 11, day: 10)
    )
)

me.account?.addTransaction(
    transaction: .debit(
        value: 100,
        name: "Juego PS4",
        category:.entretaining,
        date: Date(year: 2019, month: 11, day: 13)
    )
)

me.account?.addTransaction(
    transaction: .debit(
        value: 3400,
        name: "MacbookPro",
        category:.entretaining,
        date: Date(year: 2019, month: 11, day: 14)
    )
)

me.account?.addTransaction(
    transaction: .gain(
        value: 1200,
        name: "Rembolso compra",
        date: Date(year: 2019, month: 11, day: 17)
    )
)

me.account?.addTransaction(
    transaction: .gain(
        value: 1200,
        name: "Salario",
        date: Date(year: 2019, month: 11, day: 19)
    )
)

var salary = me.account?.addTransaction(
    transaction:.gain(
        value: 1200,
        name: "Salario",
        date: Date(year: 2019, month: 11, day: 21)
    )
)

DispatchQueue.main.asyncAfter(deadline: .now() + 1){
    salary?.invalidateTransaction()
    print("Invalidated")
}

print(me.account!.amount)
print(me.fullName)

DispatchQueue.main.asyncAfter(deadline: .now() + 2){
    let transactions = me.account?.transactionsFor(category: .entretaining) as? [Debit]
    for transaction in transactions ?? []{
        print(
            "Hello, ",
            transaction.name,
            transaction.value,
            transaction.category.rawValue,
            transaction.date
        )
    }
    
    for gain in me.account?.gains ?? [] {
        print(
            "Hello gain,",
            gain.name,
            gain.isValid,
            gain.value,
            gain.date
        )
    }
}


print(me.account?.amount ?? 0)
