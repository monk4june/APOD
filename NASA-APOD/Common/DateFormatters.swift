//
//  DateFormatter.swift
//  NASA-APOD
//
//

import Foundation

enum DateFormatters {
    //MARK: - Properties

    /// DateFormatter to be used to format date for services
    static let service: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()

    /// DateFormatter to be used to format date for User interface
    static let userInterface: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter
    }()
}
