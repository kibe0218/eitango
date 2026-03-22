//
//  SettingEntity+CoreDataProperties.swift
//  eitango
//
//  Created by kibe on 2026/03/22.
//
//

public import Foundation
public import CoreData


public typealias SettingEntityCoreDataPropertiesSet = NSSet

extension SettingEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SettingEntity> {
        return NSFetchRequest<SettingEntity>(entityName: "SettingEntity")
    }

    @NSManaged public var colorTheme: Int16
    @NSManaged public var waitTime: Int16

}
