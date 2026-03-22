//
//  PlayEntity+CoreDataProperties.swift
//  eitango
//
//  Created by kibe on 2026/03/22.
//
//

public import Foundation
public import CoreData


public typealias PlayEntityCoreDataPropertiesSet = NSSet

extension PlayEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlayEntity> {
        return NSFetchRequest<PlayEntity>(entityName: "PlayEntity")
    }

    @NSManaged public var looping: Bool
    @NSManaged public var mode: Int16
    @NSManaged public var reverse: Bool
    @NSManaged public var selectedListId: String?
    @NSManaged public var shownCount: Int16

}
