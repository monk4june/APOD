//
//  APODMediaImageService.swift
//  NASA-APOD
//
//

import UIKit

class APODMediaImageService {
    //MARK: - Types
    enum APODMediaImageServiceError: Error {
        case badURL
        case badResponse
    }
    
    //MARK: - Functions
    func fetchMediaImage(media: APODMediaItem, quality: APODMediaItem.MediaQuality, completion: @escaping ImageRetrievalCompletionHandler) {
        if let cachedImage = ImageCache.shared.retrieveImage(forKey: media.cacheKey(forQuality: quality)) {
            completion(cachedImage, nil)
        } else {
            downloadMediaImage(media: media, quality: quality, completion: completion)
        }
    }
    
    func downloadMediaImage(media: APODMediaItem, quality: APODMediaItem.MediaQuality, completion: @escaping ImageRetrievalCompletionHandler) {
        let urlString = media.mediaURL(forQuality: quality)
        guard let mediaURL = URL(string: urlString) else { return completion(nil, APODMediaImageServiceError.badURL) }
        
        let task = URLSession.shared.dataTask(with: mediaURL) { data, response, error in
            if let error = error {
                completion(nil, error)
            } else if let data = data, let image = UIImage(data: data) {
                ImageCache.shared.saveImage(image: image, forKey: media.cacheKey(forQuality: quality))
                completion(image, nil)
            } else {
                completion(nil, APODMediaImageServiceError.badResponse)
            }
        }
        task.resume()
    }
}
