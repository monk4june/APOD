//
//  DiskCache.swift
//  NASA-APOD
//
//

import UIKit

class DiskCache {
    //MARK: - Properties
    
    let fileManager = FileManager.default
    let cacheDirectoryURL: URL?
    
    //MARK: - Initializer
    
    init() {
        cacheDirectoryURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
    }
    
    //MARK: - Functions
    
    /// Lookup image in disk cache directory
    /// - Parameter key: String for cache key
    /// - Returns: Cached UIImage
    func retrieveImage(forKey key: String) -> UIImage? {
        guard let fileURL = cacheDirectoryURL?.appendingPathComponent(key) else {
            print("malformed file URL")
            return nil
        }
        
        let filePath = fileURL.path
        if fileManager.fileExists(atPath: filePath) {
            print("File \(filePath) exists, return image")
            if let imageData =  try? Data(contentsOf: fileURL) {
                return UIImage(data: imageData)
            } else {
                return nil
            }
        } else {
            print("File \(filePath) does not exist on disk")
            return nil
        }
    }
    
    /// Save image in disk cache directory
    /// - Parameters:
    ///   - image: UIImage object to be cached
    ///   - key: String for cache key
    func saveImage(image: UIImage, forKey key: String) {
        guard let fileURL = cacheDirectoryURL?.appendingPathComponent(key) else {
            print("malformed file URL")
            return
        }
        
        let filePath = fileURL.path
        if !fileManager.fileExists(atPath: filePath) {
            let contents = image.pngData()
            fileManager.createFile(atPath: filePath, contents: contents)
            print("File \(filePath) created")
        } else {
            print("File \(filePath) already exists")
        }
    }
}
