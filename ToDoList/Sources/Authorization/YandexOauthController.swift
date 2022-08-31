//
//  YandexOauthController.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 21.08.2022.
//

import Foundation
import WebKit

final class YandexOauthController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    private var webView: WKWebView!

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        var components = URLComponents()

        components.scheme = "https"
        components.host = "oauth.yandex.ru"
        components.path = "/authorize"
        components.queryItems = [
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "client_id", value: "0d0970774e284fa8ba9ff70b6b06479a")
        ]

        guard let url = components.url else {
            postNotification(with: nil)
            return
        }

        let myRequest = URLRequest(url: url)
        webView.load(myRequest)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)

        if let url = webView.url, url.absoluteString.starts(with: "https://oauth.yandex.ru/verification_code") {
            guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                postNotification(with: nil)
                return
            }

            urlComponents.query = urlComponents.fragment

            guard let queryItems = urlComponents.queryItems else {
                postNotification(with: nil)
                return
            }

            guard let itemWithAccessToken = queryItems.first(where: { queryItem in
                return queryItem.name == "access_token"
            }) else {
                postNotification(with: nil)
                return
            }

            guard let value = itemWithAccessToken.value else {
                postNotification(with: nil)
                return
            }

            postNotification(with: value)
        }
    }

    // MARK: - Private funcs
    private func postNotification(with oauthToken: String?) {
        var dict = [String: String]()
        if let oauthToken = oauthToken {
            dict[Constants.tokenKey] = oauthToken
        }

        NotificationCenter.default.post(
            name: NSNotification.Name(YandexOauthController.Constants.useOauthNotificationName),
            object: nil,
            userInfo: dict)
    }

    // MARK: - Constants
    enum Constants {
        static let useOauthNotificationName = "useOauth"
        static let tokenKey = "token"
    }
}
