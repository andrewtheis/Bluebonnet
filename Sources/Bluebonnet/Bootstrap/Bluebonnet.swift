//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import os.log


/// This type holds all global configuration options and miscellaneous variables.
@MainActor
public struct Bluebonnet {
    
    /// The `URLSesssion` to use. See `URLSession` for more info.
    public static var urlSession = URLSession.shared
    
    static let logger = Logger(subsystem: "io.hiddenspectrum.bluebonnet", category: "Bluebonnet")
}


/// Errors specific to Bluebonnet.
public enum BluebonnetError: Error, Sendable {
    case couldNotGenerateRequestURL
    case polledRequestMaxAttemptsExceeded
    case receivedNonHTTPURLResponse
    case unexpectedlyReceivedEmptyResponseBody
    case unexpectedStatusCode(HTTPStatusCode)
}

extension BluebonnetError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .couldNotGenerateRequestURL:
            return "Could not generate request URL"
        case .polledRequestMaxAttemptsExceeded:
            return "Max attempts exceeded"
        case .receivedNonHTTPURLResponse:
            return "Received non-HTTP URL response"
        case .unexpectedlyReceivedEmptyResponseBody:
            return "Unexpectedly received empty response body"
        case .unexpectedStatusCode(let statusCode):
            return "Status code: \(statusCode.rawValue)"
        }
    }
}
