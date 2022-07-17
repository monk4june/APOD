//
//  APODMediaItem.swift
//  NASA-APOD
//
//

import Foundation
import CoreData

struct APODMediaItem: Codable {
    let date: String
    let explanation: String
    let hdurl: String
    let mediaType: String
    let serviceVersion: String
    let title: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case date
        case explanation
        case hdurl
        case mediaType = "media_type"
        case serviceVersion = "service_version"
        case title
        case url
    }
}

//MARK: - ManagedObjectConvertible

extension APODMediaItem: ManagedObjectConvertible {
    //MARK: - Functions

    func toManagedObject(in context: NSManagedObjectContext) -> MediaItem? {
        let item = MediaItem(context: context)
        item.date = date
        item.explanation = explanation
        item.hdurl = hdurl
        item.mediaType = mediaType
        item.serviceVersion = serviceVersion
        item.title = title
        item.url = url
        return item
    }
}

//MARK: - Convinience

extension APODMediaItem {
    enum MediaQuality: String {
        case regular
        case hd
    }

    func mediaURL(forQuality quality: MediaQuality) -> String {
        switch quality {
        case .regular:
            return url
        case .hd:
            return hdurl
        }
    }

    func cacheKey(forQuality quality: MediaQuality) -> String {
        return "\(date)_\(quality.rawValue)"
    }
}
