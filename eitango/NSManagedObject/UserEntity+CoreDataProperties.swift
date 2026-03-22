//
//  UserEntity+CoreDataProperties.swift
//  eitango
//
//  Created by kibe on 2026/03/22.
//
//

public import Foundation
public import CoreData


public typealias UserEntityCoreDataPropertiesSet = NSSet

extension UserEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var id: String?
    @NSManaged public var name: String?

}
