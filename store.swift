import Foundation

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

    // implement the info for IsPurchasable
    var info: String {
        return "Name: \(title), Price: $\(price)"
    }

    // implement the function to print receipt
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
            print("Refund failed: Item not found in customer\'s list.")
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
    
    // searching for the item
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

//creating store
let store = Store(items: [
    Game(id: "gtasa", title: "GTA SA", price: 50.0, publisher: "Game Studios", isMultiplayer: true),
    Movie(runningTime: 120, id: "8mile", title: "8 Mile", price: 15.0)
])

//creating customer
let customer = Customer(balance: 100.0)

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
