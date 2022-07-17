//
//  MediaItem+CoreDataProperties.swift
//  NASA-APOD
//
//
//

import Foundation
import CoreData

extension MediaItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MediaItem> {
        return NSFetchRequest<MediaItem>(entityName: "MediaItem")
    }

    @NSManaged public var date: String
    @NSManaged public var explanation: String
    @NSManaged public var url: String
    @NSManaged public var title: String
    @NSManaged public var mediaType: String
    @NSManaged public var hdurl: String
    @NSManaged public var serviceVersion: String
    @NSManaged public var isFavourite: Bool

}

extension MediaItem : Identifiable {

}
