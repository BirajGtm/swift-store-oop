import Foundation
//store project g13

// isPurchasable protocol
protocol IsPurchasable {
    var info: String { get }
    func printReceipt(isRefund: Bool, amount: Double)
}

class Item: IsPurchasable {
    var id: String
    var title: String
    var price: Double

    init(id: String, title: String, price: Double) {
        self.id = id
        self.title = title
        self.price = price
    }

    // implement the info
    var info: String {
        return "Name: \(title), Price: $\(price)"
    }

    //print receipt func
    func printReceipt(isRefund: Bool, amount: Double) {
        print("""
        -------------------------
        YOUR RECEIPT
        -------------------------
        \(isRefund ? "We are refunding the purchase of \(title)\nRefund amount: $\(amount)" : "Thank you for purchasing \(title)\nPurchase amount: $\(amount)")
        """)
    }
}


class OwnedItem: Item {
    var minutesUsed: Int

    init(id: String, title: String, price: Double, minutesUsed: Int = 0) {
        self.minutesUsed = minutesUsed
        super.init(id: id, title: title, price: price)
    }

    override var info: String {
        return "\(title), $\(price) \n Minutes Used: \(minutesUsed)"
    }

    override func printReceipt(isRefund: Bool, amount: Double) {
        super.printReceipt(isRefund: isRefund, amount: amount)
    }
}


//game class
class Game: Item {
    let publisher: String
    let isMultiplayer: Bool
    
    init(id: String, title: String, price: Double, publisher: String, isMultiplayer: Bool) {
        self.publisher = publisher
        self.isMultiplayer = isMultiplayer
        super.init(id: id, title: title, price: price)
    }
    
    override var info: String {
        return "\(title), $\(price)\n Publisher: \(publisher)\n Is Multiplayer: \(isMultiplayer ? "true" : "false")"
    }
}

//movie class
class Movie: Item {
    let runningTime: Int
    
    init(runningTime: Int, id: String, title: String, price: Double) {
        self.runningTime = runningTime
        super.init(id: id, title: title, price: price)
    }

    override var info: String {
        return "\(title), $\(price) \n Running Time: \(runningTime)"
    }
}

class Customer {
    var itemsList: [OwnedItem]
    var balance: Double
    
    init(balance: Double = 10) {
        self.itemsList = []
        self.balance = balance
    }
    
    // reloading customer's account
    func reloadAccount(amount: Double) {
        balance += amount
        print("Account reloaded. New balance: \(balance)")
    }
    
    // using the item by customer
    func useItem(id: String, minutesUsed: Int) {
        for item in itemsList {
            if item.id == id {
                item.minutesUsed += minutesUsed
                print("Used \(item.title) for \(minutesUsed) minutes.")
                return
            }
        }
        print("Item with ID \(id) not found.")
    }
}

class Store {
    var items: [Item]
    
    init(items: [Item]) {
        self.items = items
    }
    
    // buying an item from the store
    func buyItem(customer: Customer, itemId: String) {
        // look for item in store
        guard let item = items.first(where: { $0.id == itemId }) else {
            print("Item not found.")
            return
        }

        // check if the item is already owned by customer
        guard !customer.itemsList.contains(where: { $0.id == itemId }) else {
            print("Purchase failed: Customer already owns this item.")
            return
        }

        // check if customer has enough balance to make the purchase
        guard customer.balance >= item.price else {
            print("Purchase failed: Insufficient funds.")
            return
        }

        // deduct the customer's balance
        customer.balance -= item.price

        // add the item to customer's owned item list
        let ownedItem = OwnedItem(id: item.id, title: item.title, price: item.price)
        customer.itemsList.append(ownedItem)

        // print purchase success message and receipt
        print("Purchase success!")
        item.printReceipt(isRefund: false, amount: item.price)
    }

    // issuing a refund
    func issueRefund(customer: Customer, itemId: String) {
        guard let index = customer.itemsList.firstIndex(where: { $0.id == itemId }) else {
            print("Refund failed: Item not found in customer's list.")
            return
        }

        let ownedItem = customer.itemsList[index]
        if ownedItem.minutesUsed >= 30 {
            print("Refund failed: Item used for more than 30 minutes.")
            return
        }

        customer.balance += ownedItem.price
        customer.itemsList.remove(at: index)
        print("Refund success!")
        ownedItem.printReceipt(isRefund: true, amount: ownedItem.price)
    }
    
    // searching for the item in store
    func findByTitle(keyword: String) {
        let results = items.filter { $0.title.lowercased().contains(keyword.lowercased()) }
        
        if results.isEmpty {
            print("Sorry, no matching items found.")
            return
        }
        
        for item in results {
            if item is Game {
                print("[GAME] \(item.info)")
            } else if item is Movie {
                print("[MOVIE] \(item.info)")
            }
        }
    }
}

//create store 
func createStore() -> Store {
    var items = [Item]()
    print("Creating store and adding items.")

    while true {
        print("Enter item type (game/movie) or 'exit' to finish:")
        guard let itemType = readLine()?.lowercased() else { continue }

        if itemType == "exit" { break }

        print("Enter item ID:")
        guard let id = readLine() else { continue }

        print("Enter item title:")
        guard let title = readLine() else { continue }

        print("Enter item price:")
        guard let priceInput = readLine(), let price = Double(priceInput) else { continue }

        if itemType == "game" {
            print("Enter publisher:")
            guard let publisher = readLine() else { continue }

            print("Is it multiplayer (true/false)?")
            guard let isMultiplayerInput = readLine(), let isMultiplayer = Bool(isMultiplayerInput) else { continue }

            let game = Game(id: id, title: title, price: price, publisher: publisher, isMultiplayer: isMultiplayer)
            items.append(game)
        } else if itemType == "movie" {
            print("Enter running time in minutes:")
            guard let runningTimeInput = readLine(), let runningTime = Int(runningTimeInput) else { continue }

            let movie = Movie(runningTime: runningTime, id: id, title: title, price: price)
            items.append(movie)
        }
    }

    return Store(items: items)
}

//creating customer func
func createCustomer() -> Customer {
    print("Enter initial balance for the new customer:")
    if let balanceInput = readLine(), let balance = Double(balanceInput) {
        let customer = Customer(balance: balance)
        print("Customer created with balance: \(balance)")
        return customer
    } else {
        print("Invalid input. Creating customer with default balance of 10.")
        return Customer()
    }
}

//main func, starts when program starts
func main() {
    let store = createStore()
    let customer = createCustomer()

    func showMenu() {
        print("""
        1. Buy Item
        2. Use Item
        3. Issue Refund
        4. Find Item by Title
        5. Reload Account
        6. Exit
        """)
    }

    while true {
        showMenu()
        if let choice = readLine(), let option = Int(choice) {
            switch option {
            case 1:
                print("Enter item ID to buy:")
                if let itemId = readLine() {
                    store.buyItem(customer: customer, itemId: itemId)
                }
            case 2:
                print("Enter item ID to use:")
                if let itemId = readLine() {
                    print("Enter minutes to use:")
                    if let minutes = readLine(), let minutesUsed = Int(minutes) {
                        customer.useItem(id: itemId, minutesUsed: minutesUsed)
                    }
                }
            case 3:
                print("Enter item ID to refund:")
                if let itemId = readLine() {
                    store.issueRefund(customer: customer, itemId: itemId)
                }
            case 4:
                print("Enter keyword to search by title:")
                if let keyword = readLine() {
                    store.findByTitle(keyword: keyword)
                }
            case 5:
                print("Enter amount to reload:")
                if let amount = readLine(), let reloadAmount = Double(amount) {
                    customer.reloadAccount(amount: reloadAmount)
                }
            case 6:
                print("Exiting...")
                exit(0)
            default:
                print("Invalid option. Please try again.")
            }
        }
    }
}

main()
