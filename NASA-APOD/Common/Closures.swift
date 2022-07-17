//
//  Closures.swift
//  NASA-APOD
//
//

import UIKit

//MARK: - Types
typealias ExecutionHandler = () -> ()
typealias MediaCompletionHandler = (APODMediaItem?, Error?) -> ()
typealias ImageRetrievalCompletionHandler = (UIImage?, Error?) -> ()
