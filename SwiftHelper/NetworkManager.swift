//
//  NetworkManager.swift
//  apiCallerSwiftUi
//
//  Created by Aarish Khanna on 27/10/23.
//

import Foundation

/// Primary API service object to get  data
final class NetworkManager {
    /// Shared singleton instance
    static let shared = NetworkManager()

    private let cacheManager = APICacheManager()

    /// Privatized constructor
    private init() {}

    /// Error types
    enum APIServiceError: Error {
        case failedToCreateRequest
        case failedToGetData
    }

    /// Send  API Call
    /// - Parameters:
    ///   - request: Request instance
    ///   - type: The type of object we expect to get back
    ///   - completion: Callback with data or error
    public func execute<T: Codable>(
        _ request: APIRequest,
        expecting type: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        if let cachedData = cacheManager.cachedResponse(
            for: request.endpoint,
            url: request.url
        ) {
            do {
                let result = try JSONDecoder().decode(type.self, from: cachedData)
                completion(.success(result))
            }
            catch {
                completion(.failure(error))
            }
            return
        }

        guard let urlRequest = self.request(from: request) else {
            completion(.failure(APIServiceError.failedToCreateRequest))
            return
        }

        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? APIServiceError.failedToGetData))
                return
            }

            // Decode response
            do {
                let result = try JSONDecoder().decode(type.self, from: data)
                self?.cacheManager.setCache(
                    for: request.endpoint,
                    url: request.url,
                    data: data
                )
                completion(.success(result))
            }
            catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    // MARK: - Private

    private func request(from apiRequest: APIRequest) -> URLRequest? {
        guard let url = apiRequest.url else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = apiRequest.httpMethod
        return request
    }
}


/// Object that represents a singlet API call
final class APIRequest {
    /// API Constants
    private struct Constants {
        static let baseUrl = "https://exampleURL.com/api"
    }

    /// Desired endpoint
    let endpoint: APIEndpoint

    /// Path components for API, if any
    private let pathComponents: [String]

    /// Query arguments for API, if any
    private let queryParameters: [URLQueryItem]

    /// Constructed url for the api request in string format
    private var urlString: String {
        var string = Constants.baseUrl
        string += "/"
        string += endpoint.rawValue

        if !pathComponents.isEmpty {
            pathComponents.forEach({
                string += "/\($0)"
            })
        }

        if !queryParameters.isEmpty {
            string += "?"
            let argumentString = queryParameters.compactMap({
                guard let value = $0.value else { return nil }
                return "\($0.name)=\(value)"
            }).joined(separator: "&")

            string += argumentString
        }

        return string
    }

    /// Computed & constructed API url
    public var url: URL? {
        return URL(string: urlString)
    }

    /// Desired http method
    public let httpMethod = "GET"

    // MARK: - Public

    /// Construct request
    /// - Parameters:
    ///   - endpoint: Target endpoint
    ///   - pathComponents: Collection of Path components
    ///   - queryParameters: Collection of query parameters
    public init(
        endpoint: APIEndpoint,
        pathComponents: [String] = [],
        queryParameters: [URLQueryItem] = []
    ) {
        self.endpoint = endpoint
        self.pathComponents = pathComponents
        self.queryParameters = queryParameters
    }

    /// Attempt to create request
    /// - Parameter url: URL to parse
    convenience init?(url: URL) {
        let string = url.absoluteString
        if !string.contains(Constants.baseUrl) {
            return nil
        }
        let trimmed = string.replacingOccurrences(of: Constants.baseUrl+"/", with: "")
        if trimmed.contains("/") {
            let components = trimmed.components(separatedBy: "/")
            if !components.isEmpty {
                let endpointString = components[0] // Endpoint
                var pathComponents: [String] = []
                if components.count > 1 {
                    pathComponents = components
                    pathComponents.removeFirst()
                }
                if let apiEndpoint = APIEndpoint(
                    rawValue: endpointString
                ) {
                    self.init(endpoint: apiEndpoint, pathComponents: pathComponents)
                    return
                }
            }
        } else if trimmed.contains("?") {
            let components = trimmed.components(separatedBy: "?")
            if !components.isEmpty, components.count >= 2 {
                let endpointString = components[0]
                let queryItemsString = components[1]
                // value=name&value=name
                let queryItems: [URLQueryItem] = queryItemsString.components(separatedBy: "&").compactMap({
                    guard $0.contains("=") else {
                        return nil
                    }
                    let parts = $0.components(separatedBy: "=")

                    return URLQueryItem(
                        name: parts[0],
                        value: parts[1]
                    )
                })

                if let apiEndpoint = APIEndpoint(rawValue: endpointString) {
                    self.init(endpoint: apiEndpoint, queryParameters: queryItems)
                    return
                }
            }
        }

        return nil
    }
}

// MARK: - Request convenience

extension APIRequest {
    static let firstRequest = APIRequest(endpoint: .one)
    static let secondRequest = APIRequest(endpoint: .two)
    static let threeRequest = APIRequest(endpoint: .three)
}


/// Manages in memory session scoped API caches
final class APICacheManager {
    // API URL: Data

    /// Cache map
    private var cacheDictionary: [
        APIEndpoint: NSCache<NSString, NSData>
    ] = [:]

    /// Constructor
    init() {
        setUpCache()
    }

    // MARK: - Public

    /// Get cached API response
    /// - Parameters:
    ///   - endpoint: Endpoiint to cahce for
    ///   - url: Url key
    /// - Returns: Nullable data
    public func cachedResponse(for endpoint: APIEndpoint, url: URL?) -> Data? {
        guard let targetCache = cacheDictionary[endpoint], let url = url else {
            return nil
        }
        let key = url.absoluteString as NSString
        return targetCache.object(forKey: key) as? Data
    }

    /// Set API response cache
    /// - Parameters:
    ///   - endpoint: Endpoint to cache for
    ///   - url: Url string
    ///   - data: Data to set in cache
    public func setCache(for endpoint: APIEndpoint, url: URL?, data: Data) {
        guard let targetCache = cacheDictionary[endpoint], let url = url else {
            return
        }
        let key = url.absoluteString as NSString
        targetCache.setObject(data as NSData, forKey: key)
    }

    // MARK: - Private

    /// Set up dictionary
    private func setUpCache() {
        APIEndpoint.allCases.forEach({ endpoint in
            cacheDictionary[endpoint] = NSCache<NSString, NSData>()
        })
    }
}


/// Represents unique API endpoint
@frozen enum APIEndpoint: String, CaseIterable, Hashable {
    /// Endpoint to get one's info
    case one
    /// Endpoint to get two's info
    case two
    /// Endpoint to get three's info
    case three
}


/// How to use:

//  guard let request = APIRequest(url: url) else {
//
//return
//}
//
//NetworkManager.shared.execute(request, expecting: /*Replace with model.self*/) { [weak self] result in
//guard let strongSelf = self else {
//    return
//}
//switch result {
//case .success(let responseModel):
//   // success code here
//case .failure(let failure):
//    print(String(describing: failure))
//
//}
//}
