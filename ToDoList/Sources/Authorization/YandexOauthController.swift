//
//  YandexOauthController.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 21.08.2022.
//

import Foundation
import WebKit

protocol TokenChangerDelegate: AnyObject {
    func didReceiveYandexOauthToken(token: String?)
}

final class YandexOauthController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    private var webView: WKWebView!

    weak var delegate: TokenChangerDelegate?

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

        let urlString = "https://oauth.yandex.ru/authorize?response_type=token&client_id=0d0970774e284fa8ba9ff70b6b06479a"

        let myURL = URL(string: urlString)!
        let myRequest = URLRequest(url: myURL)
        webView.load(myRequest)

    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)

        if let url = webView.url, url.absoluteString.starts(with: "https://oauth.yandex.ru/verification_code") {
            guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                delegate?.didReceiveYandexOauthToken(token: nil)
                return
            }

            urlComponents.query = urlComponents.fragment

            guard let queryItems = urlComponents.queryItems else {
                delegate?.didReceiveYandexOauthToken(token: nil)
                return
            }

            guard let itemWithAccessToken = queryItems.first(where: { queryItem in
                return queryItem.name == "access_token"
            }) else {
                delegate?.didReceiveYandexOauthToken(token: nil)
                return
            }

            guard let value = itemWithAccessToken.value else {
                delegate?.didReceiveYandexOauthToken(token: nil)
                return
            }

            delegate?.didReceiveYandexOauthToken(token: value)
        }
    }
}
