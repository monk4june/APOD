//
//  ImageCache.swift
//  NASA-APOD
//
//

import UIKit

class ImageCache {
    //MARK: - Properties
    private let memoryCache = NSCache<NSString, UIImage>()
    private let diskCache = DiskCache()
    private var loadingResponses = [String: [(UIImage?, Error?) -> Swift.Void]]()
    private let imageDownloadService = APODMediaImageService()
    
    //MARK: - Singleton
    private init() {
        memoryCache.countLimit = 100
    }
    static let shared = ImageCache()
    
    //MARK: - Functions
    
    /// Returns the cached image if available, otherwise asynchronously loads and caches it.
    /// - Parameters:
    ///   - media: Media object containing image urls
    ///   - quality: Media quality
    ///   - completion: Completion handler to supply retrieved UIImage or an Error
    func fetchMediaImage(media: APODMediaItem, quality: APODMediaItem.MediaQuality, completion: @escaping ImageRetrievalCompletionHandler) {
        let cacheKey = media.cacheKey(forQuality: quality)
        if let cachedImage = retrieveImage(forKey: cacheKey) {
            DispatchQueue.main.async {
                completion(cachedImage, nil)
            }
        } else {
            // In case there are more than one requestor for the image, we append their completion block.
            if loadingResponses[cacheKey] != nil {
                loadingResponses[cacheKey]?.append(completion)
                return
            } else {
                loadingResponses[cacheKey] = [completion]
            }
            imageDownloadService.downloadMediaImage(media: media, quality: quality, completion: completion)
            imageDownloadService.downloadMediaImage(media: media, quality: quality) { [weak self] image, error in
                // Check for the error, then data and try to create the image.
                guard
                    let image = image,
                    let blocks = self?.loadingResponses[cacheKey],
                    error == nil else {
                    DispatchQueue.main.async {
                        completion(image, nil)
                    }
                    return
                }
                // Cache the image
                self?.saveImage(image: image, forKey: cacheKey)
                // Iterate over each requestor for the image and pass it back.
                for block in blocks {
                    DispatchQueue.main.async {
                        block(image, nil)
                    }
                    return
                }
            }
        }
    }
    
    /// Lookup image in memory and disk cache
    /// - Parameter key: String for cache key
    /// - Returns: Cached UIImage
    func retrieveImage(forKey key: String) -> UIImage? {
        if let memoryCachedImage = memoryCache.object(forKey: key as NSString) {
            print("Image found in memory cache for \(key)")
            return memoryCachedImage
        } else if let diskCachedImage = diskCache.retrieveImage(forKey: key) {
            print("Image found in disk cache for \(key)")
            memoryCache.setObject(diskCachedImage, forKey: key as NSString)
            return diskCachedImage
        } else {
            print("No Image found in cache for \(key), needs to be downloaded")
            return nil
        }
    }
    
    /// Save image in memory and disk cache
    /// - Parameters:
    ///   - image: UIImage object to be cached
    ///   - key: String for cache key
    func saveImage(image: UIImage, forKey key: String) {
        if memoryCache.object(forKey: key as NSString) == nil {
            memoryCache.setObject(image, forKey: key as NSString, cost: image.pngData()?.count ?? 0)
        }
        if diskCache.retrieveImage(forKey: key) == nil {
            diskCache.saveImage(image: image, forKey: key)
        }
    }
}
