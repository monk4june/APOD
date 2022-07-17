//
//  MediaItem+CoreDataClass.swift
//  NASA-APOD
//
//
//

import Foundation
import CoreData

@objc(MediaItem)
public class MediaItem: NSManagedObject {
    
}

extension MediaItem: ModelConvertible {
    func toModel() -> APODMediaItem? {
        return APODMediaItem(date: date,
                             explanation: explanation,
                             hdurl: hdurl,
                             mediaType: mediaType,
                             serviceVersion: serviceVersion,
                             title: title,
                             url: url)
    }
}
