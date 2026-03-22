//
//  CardEntity+CoreDataProperties.swift
//  eitango
//
//  Created by kibe on 2026/03/22.
//
//

public import Foundation
public import CoreData


public typealias CardEntityCoreDataPropertiesSet = NSSet

extension CardEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CardEntity> {
        return NSFetchRequest<CardEntity>(entityName: "CardEntity")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var en: String?
    @NSManaged public var id: String?
    @NSManaged public var jp: String?
    @NSManaged public var listId: String?
    @NSManaged public var mistake: Bool
    @NSManaged public var order: Int16
    @NSManaged public var cardlist: ListEntity?

}
