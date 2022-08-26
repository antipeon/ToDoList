//
//  DefaultNetworkService.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 17.08.2022.
//

import Foundation
import CocoaLumberjack

final class DefaultNetworkService: NetworkService {

    // MARK: - Private vars
    private let session: URLSession = {
        let session = URLSession(configuration: .default)
        session.configuration.timeoutIntervalForRequest = Constants.sessionTimeout
        return session
    }()

    private static var revision: Int32 = 0

    var yandexOauthToken: String?

    private var token: String {
        if let yaToken = yandexOauthToken {
            return yaToken
        }

        guard let token = ProcessInfo.processInfo.environment["yandex-api-token"] else {
            fatalError("invalid token")
        }
        return token
    }

    private var oauthType: String {
        if yandexOauthToken != nil {
            return "OAuth"
        }
        return "Bearer"
    }

    private let syncQueue = DispatchQueue(label: "queriesSyncQ", attributes: .concurrent)

    // MARK: - API
    func getAllToDoItems(completion: @escaping (Result<[ToDoItemModel], Error>) -> Void) {
        syncQueue.async { [weak self] in
            guard let self = self else {
                return
            }

            guard let url = self.getUrl(handle: Constants.listHandle) else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.invalidUrl))
                }
                return
            }

            let request = self.makeRequestToUrl(url, of: Constants.HttpMethods.get)

            let task = self.session.dataTask(with: request) { [weak self] data, response, error  in
                guard let self = self else {
                    return
                }

                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.dataIsNil))
                    }
                    return
                }

                let shouldCallbackReturn = self.preprocessResponse(data: data, response: response, error: error, completion: completion)
                if shouldCallbackReturn {
                    return
                }

                guard let model = try? JSONDecoder().decode(GetListResponseModel.self, from: data) else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.jsonDecode))
                    }
                    return
                }

                let items = model.list.map { ToDoItemModel(from: $0) }

                DefaultNetworkService.revision = model.revision

                DispatchQueue.main.async {
                    completion(.success(items))
                }
            }

            task.resume()
        }
    }

    func editToDoItem(_ item: ToDoItemModel, completion: @escaping (Result<ToDoItemModel, Error>) -> Void) {
        syncQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else {
                return
            }

            let model = PostItemRequestModel(from: item)

            guard let url = self.getUrl(handle: Constants.listHandle)?.appendingPathComponent(item.id) else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.invalidUrl))
                }
                return
            }

            var request = self.makeRequestToUrlWithRevision(url, of: Constants.HttpMethods.put)
            request.httpBody = try? JSONEncoder().encode(model)

            let task = self.session.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else {
                    return
                }

                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.dataIsNil))
                    }
                    return
                }

                let shouldCallbackReturn = self.preprocessResponse(data: data, response: response, error: error, completion: completion)
                if shouldCallbackReturn {
                    return
                }

                guard let model = try? JSONDecoder().decode(PostItemResponseModel.self, from: data) else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.jsonDecode))
                    }
                    return
                }

                let item = ToDoItemModel(from: model.element)

                DefaultNetworkService.revision = model.revision

                DispatchQueue.main.async {
                    completion(.success(item))
                }
            }

            task.resume()
        }

    }

    func deleteToDoItem(at id: String, completion: @escaping (Result<ToDoItemModel, Error>) -> Void) {
        syncQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else {
                return
            }

            guard let url = self.getUrl(handle: Constants.listHandle)?.appendingPathComponent(id) else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.invalidUrl))
                }
                return
            }

            let request = self.makeRequestToUrlWithRevision(url, of: Constants.HttpMethods.delete)

            let task = self.session.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else {
                    return
                }

                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.dataIsNil))
                    }
                    return
                }

                let shouldCallbackReturn = self.preprocessResponse(data: data, response: response, error: error, completion: completion)
                if shouldCallbackReturn {
                    return
                }

                guard let model = try? JSONDecoder().decode(PostItemResponseModel.self, from: data) else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.jsonDecode))
                    }
                    return
                }

                let item = ToDoItemModel(from: model.element)

                DefaultNetworkService.revision = model.revision

                DispatchQueue.main.async {
                    completion(.success(item))
                }
            }

            task.resume()
        }
    }

    func updateToDoItems(withItems items: [ToDoItemModel], completion: @escaping (Result<[ToDoItemModel], Error>) -> Void) {
        syncQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else {
                return
            }

            let model = PatchItemsRequestModel(with: items)

            guard let url = self.getUrl(handle: Constants.listHandle) else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.invalidUrl))
                }
                return
            }

            var request = self.makeRequestToUrlWithRevision(url, of: Constants.HttpMethods.patch)
            request.httpBody = try? JSONEncoder().encode(model)

            let task = self.session.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else {
                    return
                }

                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.dataIsNil))
                    }
                    return
                }

                let shouldCallbackReturn = self.preprocessResponse(data: data, response: response, error: error, completion: completion)
                if shouldCallbackReturn {
                    return
                }

                guard let model = try? JSONDecoder().decode(GetListResponseModel.self, from: data) else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.jsonDecode))
                    }
                    return
                }

                let items = model.list.map { ToDoItemModel(from: $0) }

                DefaultNetworkService.revision = model.revision

                DispatchQueue.main.async {
                    completion(.success(items))
                }
            }

            task.resume()
        }

    }

    func addToDoItem(item: ToDoItemModel, completion: @escaping (Result<ToDoItemModel, Error>) -> Void) {
        syncQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else {
                return
            }

            let model = PostItemRequestModel(from: item)

            guard let url = self.getUrl(handle: Constants.listHandle) else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.invalidUrl))
                }
                return
            }

            var request = self.makeRequestToUrlWithRevision(url, of: Constants.HttpMethods.post)
            request.httpBody = try? JSONEncoder().encode(model)

            let task = self.session.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else {
                    return
                }

                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.dataIsNil))
                    }
                    return
                }

                let shouldCallbackReturn = self.preprocessResponse(data: data, response: response, error: error, completion: completion)
                if shouldCallbackReturn {
                    return
                }

                guard let model = try? JSONDecoder().decode(PostItemResponseModel.self, from: data) else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.jsonDecode))
                    }
                    return
                }

                let item = ToDoItemModel(from: model.element)

                DefaultNetworkService.revision = model.revision

                DispatchQueue.main.async {
                    completion(.success(item))
                }
            }

            task.resume()
        }

    }

    // MARK: - Private funcs
    private func getUrl(handle: String) -> URL? {
        Constants.baseURL?.appendingPathComponent(handle)
    }

    private func makeRequestToUrl(_ url: URL, of httpMethodType: Constants.HttpMethods) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethodType.rawValue
        request.allHTTPHeaderFields = [
            "Authorization": "\(oauthType) \(token)"
        ]
        return request
    }

    private func makeRequestToUrlWithRevision(_ url: URL, of httpMethodType: Constants.HttpMethods) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethodType.rawValue
        request.allHTTPHeaderFields = [
            "Authorization": "\(oauthType) \(token)",
            "X-Last-Known-Revision": "\(DefaultNetworkService.revision)"
        ]
        return request
    }

    /// - Parameters:
    ///   - data: data from callback
    ///   - response: response from callback
    ///   - error: error from callback
    ///   - completion: completion
    /// - Returns: should callback return
    private func preprocessResponse<T>(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> Bool {

        if let error = error {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return true
        }

        guard let response = response as? HTTPURLResponse else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.notHttp))
            }
            return true
        }

        guard response.statusCode == Constants.StatusCodes.okStatusCode  else {
            DispatchQueue.main.async { [self] in
                completion(.failure(self.getServerErrorWithCode(response.statusCode)))
            }
            return true
        }

        DDLogVerbose("\(#function) request is finished with code: \(response.statusCode)")

        return false
    }

    private func getServerErrorWithCode(_ code: Int) -> ServerError {
        switch code {
        case Constants.StatusCodes.invalidRequest:
            return ServerError.invalidRequest(code: code)
        case Constants.StatusCodes.authorizationError:
            return ServerError.authorizationError(code: code)
        case Constants.StatusCodes.elementNotFound:
            return ServerError.elementNotFound(code: code)
        case Constants.StatusCodes.someError:
            return ServerError.someError(code: code)
        default:
            return ServerError.unknownError(code: code)
        }
    }

    // MARK: - Constants
    private enum Constants {
        static let sessionTimeout: TimeInterval = 30
        static let baseURL = URL(string: "https://beta.mrdekk.ru/todobackend")

        enum StatusCodes {
            static let okStatusCode = 200
            static let invalidRequest = 400
            static let authorizationError = 401
            static let elementNotFound = 404
            static let someError = 500
        }

        static let listHandle = "list"

        enum HttpMethods: String {
            case post = "POST"
            case put = "PUT"
            case delete = "DELETE"
            case get = "GET"
            case patch = "PATCH"
        }
    }

    enum NetworkError: String, Error {
        case jsonDecode = "failed to decode json"
        case notHttp = "response is not http"
        case dataIsNil = "data is nil"
        case networkingModel = "error converting networking model"
        case invalidUrl = "invalid url"

        case invalidRequest = "invalid request"
        case authorizationError = "authorization error"
        case elementNotFound = "element not found on the server"
    }

    enum ServerError: Error {
        case invalidRequest(code: Int)
        case authorizationError(code: Int)
        case elementNotFound(code: Int)
        case someError(code: Int)
        case unknownError(code: Int)
    }
}
