//
//  APIService.swift
//

import UIKit
import Combine
import SwiftUI
import Resolver


enum APIError: Error, Equatable, Identifiable, Hashable {
    var id: Int {
        hashValue
    }
    
    case badURL,
         invalidDataRecieved,
         userNotLoggedIn,
         badRequest(error: MessageWithCodeResponse?),
         genericError,
         serverError,
         notFound(error: MessageWithCodeResponse?),
         invalidPayload(error: MessageWithCodeResponse?),
         requestTimeout,
         noNetwork
    
    init(errorCode: Int, message: MessageWithCodeResponse? = nil) {
        switch errorCode {
        case 400:
            self = .badRequest(error: message)
        case 401:
            self = .userNotLoggedIn
        case 404:
            self = .notFound(error: message)
        case 408:
            self = .requestTimeout
        case 422:
            self = .invalidPayload(error: message)
        case (500...599):
            self = .serverError
        default:
            self = .genericError
        }
    }
    
    func errorForResponseCode(_ code: Int) -> APIError {
        return APIError(errorCode: code)
    }
    
    func alertDescription() -> String {
        switch self {
        
        case .badURL:
            return "Bad URL"
        case .invalidDataRecieved:
            return "Invalid Data Received"
        case .userNotLoggedIn:
            return "User Not Logged In (401)"
        case .badRequest:
            return "Bad Request (400)"
        case .genericError:
            return "Generic Error"
        case .requestTimeout:
            return "The request timed out."
        case .invalidPayload:
            return "Invalid Payload"
        case .serverError:
            return "Server Error (5xx)"
        case .notFound:
            return "Not Found (404)"
        case .noNetwork:
            return "You are not connected to internet"
        }
    }
    
    func errorDescription() -> String {
        switch self {
        case .invalidPayload(let error), .badRequest(error: let error), .notFound(error: let error):
            return error?.message ?? ""
        default:
            return ""
        }
    }
    
}

class APIService {
    private var subscribers: Set<AnyCancellable> = []
    private var identityTokens: IdentityTokens?
    @Injected var analytics: AnalyticsType
    @Injected var networkStatus: NetworkStatusService

    var token: String?
    let baseURL = EnvironmentConfiguration.rootURL
    let urlSessionConfiguration = URLSessionConfiguration.default
    
    func logTokens() {
        if let tokens = self.identityTokens {
            Log(.info, message: "\n****\n****\nTokens\n****\n****\n")
            Log(.info, message: "*** idToken ***\n\(tokens.idToken)\n")
            Log(.info, message: "*** Access Token ***\n\(tokens.accessToken)\n")
            Log(.info, message: "*** Refresh Token***\n\(tokens.refreshToken)\n\n")
            
        } else {
            Log(.info, message: "No Tokens found")
        }
        
    }
    
    func getUserDetailsFromIdToken() -> [String: Any]? {
        if let idToken = identityTokens?.idToken {
            let data = try? decodeJwtToken(jwt: idToken)
            return data
        }
        return nil
    }
}

// MARK: Base
extension APIService {
    func unauthenticatedGet<T: Decodable>(path: String, type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        get(path: path, parameters: nil, includeAuth: false, type: type, extractionKey: nil, completion: completion)
    }
    
    func unauthenticatedGet<T: Decodable>(path: String, parameters: [String: String]?, extractionKey: String?, type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        get(path: path, parameters: parameters, includeAuth: false, type: type, extractionKey: extractionKey, completion: completion)
    }

    
    func get<T: Decodable>(path: String, parameters: [String: String]?, type: T.Type, extractionKey: String?, completion: @escaping (Result<T, Error>) -> Void) {
        get(path: path, parameters: parameters, includeAuth: true, type: type, extractionKey: extractionKey, completion: completion)
    }
    
    func get<T: Decodable>(path: String, type: T.Type, extractionKey: String?, completion: @escaping (Result<T, Error>) -> Void) {
        get(path: path, parameters: nil, includeAuth: true, type: type, extractionKey: extractionKey, completion: completion)
    }
    
    // swiftlint:disable:next function_parameter_count
    func get<T: Decodable>(path: String, parameters: [String: String]?, includeAuth: Bool, type: T.Type, extractionKey: String?, completion: @escaping (Result<T, Error>) -> Void) {
        // If user isn't connected we don't want to fire a request but fail with a specific APIError that is then handled in Alert()
        guard networkStatus.connected else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                completion(.failure(APIError.noNetwork))
            }
            return
        }
        
        let urlSession = URLSession(configuration: urlSessionConfiguration)
        
        guard var components = URLComponents(string: "\(baseURL)\(path)") else {
            completion(.failure(APIError.badURL))
            return
        }
        if let parameters = parameters {
            components.queryItems = parameters.map { (key, value) in
                URLQueryItem(name: key, value: value)
            }
        }

        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        guard let url = components.url else {
            return completion(.failure(APIError.badURL))
        }

        var request = URLRequest(url: url)

        if let reqURL = request.url {
            Log(.info, message: "\nrequest url -> GET:\(reqURL.absoluteString)\n")
        }
        
        request = addContentTypeAndUserAgentHeader(request: request)
        request.httpMethod = "GET"
        
        if includeAuth {
            addAuth(to: request) { (result) in
                switch result {
                case .failure:
                    debugPrint("Failed to fetch Auth Tokens")
                case .success(let authdRequest):
                    let task = urlSession.dataTask(with: authdRequest) { (data, response, error) in
                        self.processResponse(data: data, response: response, error: error, responseType: T.self, extractionKey: extractionKey, completion: completion)
                    }
                    task.resume()
                }
            }
        } else {
            let task = urlSession.dataTask(with: request) { (data, response, error) in
                self.processResponse(data: data, response: response, error: error, responseType: T.self, extractionKey: extractionKey, completion: completion)
            }
            
            task.resume()
        }
    }

    func post<T: Decodable, U: Encodable>(path: String, body: U?, type: T.Type, extractionKey: String?, completion: @escaping (Result<T, Error>) -> Void) {
        reqWithBody(path: path,
                    method: "POST",
                    body: body,
                    includeAuth: true,
                    type: type,
                    extractionKey: extractionKey,
                    completion: completion)
    }
    
    func delete<T: Decodable, U: Encodable>(path: String, body: U?, type: T.Type, extractionKey: String?, completion: @escaping (Result<T, Error>) -> Void) {
        reqWithBody(path: path,
                    method: "DELETE",
                    body: body,
                    includeAuth: true,
                    type: type,
                    extractionKey: extractionKey,
                    completion: completion)
    }

    func unauthenticatedPatch<T: Decodable, U: Encodable>(path: String, body: U?, type: T.Type, extractionKey: String?, completion: @escaping (Result<T, Error>) -> Void) {
        reqWithBody(path: path,
                    method: "PATCH",
                    body: body,
                    includeAuth: false,
                    type: type,
                    extractionKey: extractionKey,
                    completion: completion)
    }

    func unauthenticatedPost<T: Decodable, U: Encodable>(path: String, body: U?, type: T.Type, extractionKey: String?, completion: @escaping (Result<T, Error>) -> Void) {
        reqWithBody(path: path,
                    method: "POST",
                    body: body,
                    includeAuth: false,
                    type: type,
                    extractionKey: extractionKey,
                    completion: completion)
    }

    func patch<T: Decodable, U: Encodable>(path: String, body: U?, type: T.Type, extractionKey: String?, completion: @escaping (Result<T, Error>) -> Void) {
        reqWithBody(path: path,
                    method: "PATCH",
                    body: body,
                    includeAuth: true,
                    type: type,
                    extractionKey: extractionKey,
                    completion: completion)
    }
    
    func put<T: Decodable, U: Encodable>(path: String, body: U?, type: T.Type, extractionKey: String?, completion: @escaping (Result<T, Error>) -> Void) {
        reqWithBody(path: path,
                    method: "PUT",
                    body: body,
                    includeAuth: true,
                    type: type,
                    extractionKey: extractionKey,
                    completion: completion)
    }

    // swiftlint:disable:next function_parameter_count
    private func reqWithBody<T: Decodable, U: Encodable>(path: String,
                                                         method: String,
                                                         body: U?,
                                                         includeAuth: Bool,
                                                         type: T.Type,
                                                         extractionKey: String?,
                                                         completion: @escaping (Result<T, Error>) -> Void) {
        // If user isn't connected we don't want to fire a request but fail with a specific APIError that is then handled in Alert()
        guard networkStatus.connected else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                completion(.failure(APIError.noNetwork))
            }
            return
        }
        
        let urlSession = URLSession(configuration: urlSessionConfiguration)
        debugPrint("base URL \(baseURL)")
        guard let url = URL(string: "\(baseURL)\(path)") else {
            completion(.failure(APIError.badURL))
            return
        }
        
        if body != nil {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            do {
                let json = try encoder.encode(body)
                let jsonStr = String(data: json, encoding: .utf8)
                Log(.info, message: "\nrequest url -> \(method):\(url.absoluteString) \n json -> \n\(jsonStr ?? "empty json")\n")
            } catch {
                Log(.error, message: "\nerror encoding request for \(method):\(path) -> \(error.localizedDescription)")
            }
        }
        
        var request = URLRequest(url: url)
        request = addContentTypeAndUserAgentHeader(request: request)
        request.httpMethod = method
        if let httpBody = try? JSONEncoder().encode(body) {
            request.httpBody = httpBody
        }
        
        if includeAuth {
            addAuth(to: request) { (result) in
                switch result {
                case .failure:
                    debugPrint("Failed to fetch Auth Tokens")
                case .success(let authdUrlRequest):
                    let task = urlSession.dataTask(with: authdUrlRequest) { (data, response, error) in
                        self.processResponse(data: data, response: response, error: error, responseType: T.self, extractionKey: extractionKey, completion: completion)
                    }
                    task.resume()
                }
            }
        } else {
            let task = urlSession.dataTask(with: request) { (data, response, error) in
                self.processResponse(data: data, response: response, error: error, responseType: T.self, extractionKey: extractionKey, completion: completion)
            }
            task.resume()
        }
    }
    
    // swiftlint:disable:next function_parameter_count
    private func processResponse<T: Decodable>(data: Data?, response: URLResponse?, error: Error?, responseType: T.Type, extractionKey: String?, completion: @escaping (Result<T, Error>) -> Void) {
        guard let httpResponse = response as? HTTPURLResponse else {
            if let err = error as? URLError {
                switch err.code {
                case .notConnectedToInternet, .networkConnectionLost, .cannotConnectToHost:
                    completion(.failure(APIError.noNetwork))
                default:
                    completion(.failure(APIError.genericError))
                }
            }
            return
        }
        if let error = error {
            completion(.failure(error))
            return
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            setUpError(data: data, httpResponse: httpResponse)
            return
        }
        
        guard let mimeType = httpResponse.mimeType, mimeType == "application/json", let data = data else {
            completion(.failure(APIError.invalidDataRecieved))
            return
        }
        let unwrapped = unwrap(data)
        guard var strData = String(data: unwrapped, encoding: .utf8) else { return }
        if let extractionKey = extractionKey {
            strData = extract(json: strData, key: extractionKey)
        }
        guard let decoded = decode(json: strData, type: responseType) else { return }
        DispatchQueue.main.async {
            completion(.success(decoded))
            return
        }
    }
    
    private func unwrap(_ jsonData: Data) -> Data {
        do {
            var jsonObj = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
            
            if let jsonDict = jsonObj as? [String: Any], let body = jsonDict["body"] {
                jsonObj = body
                debugPrint(body)
            }
            if let jsonDict = jsonObj as? [String: AnyObject], let data = jsonDict["data"] {
                jsonObj = data
                debugPrint(data)
            }
            let unwrappedData = try JSONSerialization.data(withJSONObject: jsonObj, options: .fragmentsAllowed)
            return unwrappedData
        } catch {
            Log(.error, message: "Error while unwrapping jsonData: data \(jsonData), error: \(error.localizedDescription)")
            return jsonData
        }
    }
}

struct IdentityTokens {
    let idTokenKey = "idToken"
    let accessTokenKey = "Authorization"
    let refreshTokenKey = "refreshToken"
    let idToken, accessToken, refreshToken: String
    
    func headerDict() -> [String: String] {
        return [idTokenKey: idToken, accessTokenKey: accessToken]
    }
}

extension APIService {
    func addAuth(to urlRequest: URLRequest, result: @escaping (Result<URLRequest, Error>) -> Void) {
        let identityTokens = IdentityTokens(idToken: "", accessToken: "", refreshToken: "")
        result(.success(self.authdRequest(identityTokens: identityTokens, request: urlRequest)))
    }
    
    private func authdRequest(identityTokens: IdentityTokens, request: URLRequest) -> URLRequest {
        var request = request
        request.setValue(identityTokens.idToken, forHTTPHeaderField: identityTokens.idTokenKey)
        request.setValue(identityTokens.accessToken, forHTTPHeaderField: identityTokens.accessTokenKey)
        return request
    }
    
    private func addContentTypeAndUserAgentHeader(request: URLRequest) -> URLRequest {
        var request = request
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("ios/\(Bundle.main.shortVersion)", forHTTPHeaderField: "User-Agent")
        return request
    }
    
    private func setUpError(data: Data?, httpResponse: HTTPURLResponse) {
        var message = ""
        var codename = ""
        if let data = data, let strData = String(data: unwrap(data), encoding: .utf8), let decoded = decode(json: strData, type: ErrorResponse.self) {
            message = decoded.error.message
            codename = decoded.error.code ?? ""
            debugPrint("Error codename: \(codename)")
            debugPrint("Error message: \(message)")
        }
        let apiError = APIError(errorCode: httpResponse.statusCode, message: MessageWithCodeResponse(message: message, code: codename))
        debugPrint(apiError)
        if apiError == .userNotLoggedIn {
            return
        } else if apiError == .serverError {
            let userInfo = [
                NSLocalizedDescriptionKey: NSLocalizedString(apiError.errorDescription(), comment: ""),
                NSLocalizedFailureReasonErrorKey: NSLocalizedString("\nError from url: \(httpResponse.url?.absoluteString ?? "unknown url")", comment: "")
            ]
            let error = NSError(domain: NSCocoaErrorDomain,
                                code: -1001,
                                userInfo: userInfo)
            self.analytics.logErrorToCrashlytics(error: error)
        }
        Log(.info, message: "\nError from url: \(httpResponse.url?.absoluteString ?? "unknown url") code:\(httpResponse.statusCode)")
    }
    
}

// MARK: JSON tools
extension APIService {
    
    func extract(json: String, key: String) -> String {
        guard let jsonData = json.data(using: .utf8) else {
            return json
        }
        do {
            let jsonObj = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
            if let jsonDict = jsonObj as? [String: AnyObject], let jsonObject = jsonDict[key] {
                let extractedData = try JSONSerialization.data(withJSONObject: jsonObject, options: .fragmentsAllowed)
                return String(data: extractedData, encoding: .utf8) ?? json
            }
        } catch {
            Log(.error, message: "Error while unwrapping jsonData: data \(jsonData), error: \(error.localizedDescription)")
            return json
        }
        return json
    }
    
    func wrappedInData(json: String) -> Bool {
        guard let jsonData = json.data(using: .utf8) else {
            return false
        }
        do {
            let jsonObj = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
            if let jsonDict = jsonObj as? [String: AnyObject],
                jsonDict["data"] != nil {
                return true
            }
            
        } catch {
            return false
        }
        return false
    }
    
    func unwrapWith(_ data: Data, with unWrapper: @escaping (Data) -> Data) {
        return
    }
    
    func decode<T: Decodable>(json: String, type: T.Type) -> T? {
        guard let jsonData = json.data(using: .utf8) else {
            return nil
        }
        let decoder = JSONDecoder()
        
        do {
            let decoded = try decoder.decode(T.self, from: jsonData)
            debugPrint(decoded)
            return decoded
        } catch {
            let error = error
            debugPrint(error)
            return nil
        }
    }
}
