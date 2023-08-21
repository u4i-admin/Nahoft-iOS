//
//  Persistence.swift
//  Nahoft
//
//  Created by Sadra Sadri on 28.07.2023.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    let context: NSManagedObjectContext
    
    init() {
        container = NSPersistentContainer(name: "Nahoft")
        let storeUrl = URL.storeURL(for: "group.nahoft.app", databaseName: "Nahoft")
        let storeDescription = NSPersistentStoreDescription(url: storeUrl)
        container.persistentStoreDescriptions = [storeDescription]
        container.loadPersistentStores(completionHandler: {_, _ in })
        context = container.viewContext
        context.automaticallyMergesChangesFromParent = true
    }
    
    func saveContext(_ context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func loadFriends(searchText: String) -> [Friend] {
        let fetchRequest: NSFetchRequest<Friend> = Friend.fetchRequest()
        fetchRequest.predicate = searchText == "" ? NSPredicate(value: true) : NSPredicate(format: "name CONTAINS[cd] %@", searchText)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare))]
        do {
            let results = try context.fetch(fetchRequest)
            return results
        } catch {
            debugPrint(error)
        }
        return []
    }
    
    func reloadAllData() {
        context.stalenessInterval = 0
        context.refreshAllObjects()
        context.stalenessInterval = -1
    }
    
    func saveFriend(name: String) async throws {
        let context = container.newBackgroundContext()
        try await context.perform {
            let entity = Friend.entity()
            let friend = Friend(entity: entity, insertInto: context)
            friend.name = name
            friend.status = FriendStatus.Default.rawValue
            try context.save()
        }
    }
    
    func updateFriendStatus(friend: Friend, status: FriendStatus) throws {
        friend.status = status.rawValue
        try context.save()
    }
    
    func updateFriendPublicKey(friend: Friend, publicKey: String) throws {
        
        friend.publicKeyEncoded = publicKey
        try context.save()
    }
    
    func saveMessage(friend: Friend, messageText: String, fromMe: Bool) throws {
        let entity = Message.entity()
        let message = Message(entity: entity, insertInto: context)
        message.cipherText = messageText
        message.date = Date()
        message.fromFriend = friend
        message.fromMe = fromMe
        try context.save()
    }
    
    func loadMessages(friendId: Int) -> [Message] {
        let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            return results
        } catch {
            debugPrint(error)
        }
        return []
    }
    
    func clearAll() throws {
        // Delete all data from the store
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Message")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        let _ = try container.persistentStoreCoordinator.execute(deleteRequest, with: context)
        
        let fetchRequestFriend: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Friend")
        let deleteRequestFriend = NSBatchDeleteRequest(fetchRequest: fetchRequestFriend)
        let _ = try container.persistentStoreCoordinator.execute(deleteRequestFriend, with: context)
    }
}
