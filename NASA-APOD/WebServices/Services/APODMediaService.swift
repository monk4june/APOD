//
//  APODService.swift
//  NASA-APOD
//
//

import Foundation

class APODMediaService {
    //MARK: - Types
    enum APODServiceError: Error {
        case badRequest
        case badResponse
    }

    //MARK: - Functions

    func fetchMedia(date: String? = nil, completion: @escaping MediaCompletionHandler) {
        let mediaRequest = APODMediaRequest(date: date)
        guard let urlRequest = mediaRequest.urlRequest else { return completion(nil, APODServiceError.badRequest) }
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(nil, error)
            } else if let data = data {
                print("Response: \(String(data: data, encoding: .utf8) ?? "")")
                do {
                    let mediaItem = try JSONDecoder().decode(APODMediaItem.self, from: data)
                    completion(mediaItem, nil)
                } catch  {
                    completion(nil, APODServiceError.badResponse)
                }
            }
        }
        task.resume()
    }
}
