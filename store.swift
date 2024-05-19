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

        // check if the item is already owned by the customer
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
            print("Refund failed: Item not found in customer’s list.")
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
    
    // searching for the title
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

// Example usage

print("Creating Store with game1 and movie1:")
let store = Store(items: [
    Game(id: "game1", title: "Awesome Game", price: 50.0, publisher: "Game Studios", isMultiplayer: true),
    Movie(runningTime: 120, id: "movie1", title: "Great Movie", price: 15.0)
])
print("===============")

print("Creating customer with balance 80")
let customer = Customer(balance: 80.0)
print("===============")

print("Buying game1")
store.buyItem(customer: customer, itemId: "game1")
print("===============")

print("Buying movie1")
store.buyItem(customer: customer, itemId: "movie1")
print("===============")


print("using game1 for 10 mins")
customer.useItem(id: "game1", minutesUsed: 10)
print("===============")


print("Refunding for movie1")
store.issueRefund(customer: customer, itemId: "movie1")
print("===============")

print("Finding game title Game")
store.findByTitle(keyword: "Game")
print("===============")

print("Using game1 for 100 mins")
customer.useItem(id: "game1", minutesUsed: 100)
print("===============")

print("Trying to refund game1")
store.issueRefund(customer: customer, itemId: "game1")
print("===============")


print("Byuing game1 again: ")
store.buyItem(customer: customer, itemId: "game1")
print("===============")

print("Customer Balance: ")
print(customer.balance)
print("===============")

customer.reloadAccount(amount: 50.0)
print("===============")

store.buyItem(customer: customer, itemId: "movie1")
print("===============")

print("Item list: ")
for item in customer.itemsList {
  print(item.title)
}
print("===============")
print("The End!")


