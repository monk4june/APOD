//
//  CoreDataService.swift
//  NASA-APOD
//
//

import Foundation
import CoreData
import UIKit

class CoreDateService {
    //MARK: - Properties

    let viewContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext

    //MARK: - Functions

    @discardableResult func saveMediaItem(_ mediaItem: APODMediaItem) -> MediaItem? {
        guard let context = viewContext else { return nil }
        let cachedItem = fetchMediaItem(forDate: mediaItem.date)
        guard cachedItem == nil else { return cachedItem }
        guard let item  = mediaItem.toManagedObject(in: context) else { return nil }
        do
        {
            try context.save()
            return item
        } catch {
            print(error)
            return nil
        }
    }

    func fetchAllMediaItems() -> [MediaItem] {
        guard let context = viewContext else { return [] }
        let fetchRequest = MediaItem.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.fetchBatchSize = 10
        do {
            let items = try context.fetch(fetchRequest)
            return items
        } catch {
            print(error)
            return []
        }
    }

    func fetchMediaItem(forDate date: String) -> MediaItem? {
        guard let context = viewContext else { return nil }
        let fetchRequest = MediaItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date == %@", date)
        fetchRequest.fetchLimit = 1
        do {
            let items = try context.fetch(fetchRequest)
            return items.first
        } catch {
            print(error)
            return nil
        }
    }

    func fetchFavouriteMediaItems() -> [MediaItem] {
        guard let context = viewContext else { return [] }
        let fetchRequest = MediaItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isFavourite == %@", NSNumber(value: true))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.fetchBatchSize = 10
        do {
            let items = try context.fetch(fetchRequest)
            return items
        } catch {
            print(error)
            return []
        }
    }

    @discardableResult func toggleFavouriteMediaItem(_ mediaItem: MediaItem) -> MediaItem {
        guard let context = viewContext else { return mediaItem }
        mediaItem.isFavourite.toggle()
        do
        {
            try context.save()
            return mediaItem
        } catch {
            print(error)
            return mediaItem
        }
    }
}
