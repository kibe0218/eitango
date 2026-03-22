//
//  ListEntity+CoreDataProperties.swift
//  eitango
//
//  Created by kibe on 2026/03/22.
//
//

public import Foundation
public import CoreData


public typealias ListEntityCoreDataPropertiesSet = NSSet

extension ListEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ListEntity> {
        return NSFetchRequest<ListEntity>(entityName: "ListEntity")
    }

    @NSManaged public var cardCount: Int16
    @NSManaged public var createdAt: Date?
    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var cards: NSSet?

}

// MARK: Generated accessors for cards
extension ListEntity {

    @objc(addCardsObject:)
    @NSManaged public func addToCards(_ value: CardEntity)

    @objc(removeCardsObject:)
    @NSManaged public func removeFromCards(_ value: CardEntity)

    @objc(addCards:)
    @NSManaged public func addToCards(_ values: NSSet)

    @objc(removeCards:)
    @NSManaged public func removeFromCards(_ values: NSSet)

}
