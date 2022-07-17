//
//  APODMediaRequest.swift
//  NASA-APOD
//
//

import Foundation

struct APODMediaRequest {
    //MARK: - Types

    enum Path {
        static let planetaryAPOD = "/planetary/apod"
    }
    enum QueryParameters {
        static let date = "date"
        static let startDate = "start_date"
        static let endDate = "end_date"
        static let count = "count"
        static let thumbs = "thumbs"
        static let apiKey = "api_key"
    }

    //MARK: - Properties

    /// Specific date to retrieve APOD media for that particular date
    let date: String?
    /// Start date of a date range to retrieve multiple APOD media, can't be used with `date`
    let startDate: String?
    /// End date of a date range, can be used only with `startDate`
    let endDate: String?
    /// If count is specified then count randomly chosen images will be returned. Cannot be used with `date` or `startDate` and `endDate`.
    let count: Int = 0
    let thumbs: Bool = true

    /// URL string except the query parameters
    private let requestURLString = "\(Configuration.baseURL)\(Path.planetaryAPOD)"

    /// URLRequest representation
    var urlRequest: URLRequest? {
        var queryItems = [URLQueryItem]()
        if let date = date {
            queryItems.append(URLQueryItem(name: QueryParameters.date, value: date))
        } else if let startDate = startDate, let endDate = endDate {
            queryItems.append(URLQueryItem(name: QueryParameters.startDate, value: startDate))
            queryItems.append(URLQueryItem(name: QueryParameters.endDate, value: endDate))
        } else if count > 0 {
            queryItems.append(URLQueryItem(name: QueryParameters.count, value: String(count)))
        }
        queryItems.append(URLQueryItem(name: QueryParameters.thumbs, value: String(thumbs)))
        queryItems.append(URLQueryItem(name: QueryParameters.apiKey, value: Configuration.apiKey))

        var urlComponents = URLComponents(string: requestURLString)
        urlComponents?.queryItems = queryItems
        guard let url = urlComponents?.url else { return nil }
        return URLRequest(url: url)
    }

    //MARK: - Initializers

    /// Convenience Initializer - supplied date will be passed in APOD api request. By default values no date will be passed in APOD api request, which will default to current date
    init(date: String? =  nil,
         startDate: String? = nil,
         endDate: String? = nil
    ) {
        self.date = date
        self.startDate = nil
        self.endDate = nil
    }
}
