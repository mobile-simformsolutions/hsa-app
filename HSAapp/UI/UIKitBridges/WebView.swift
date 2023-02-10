//
//  WebView.swift
//

import WebKit
import SwiftUI
import Combine

@dynamicMemberLookup
class WebViewStore: NSObject, ObservableObject {
    typealias Status = Int

    @Published var webView: WKWebView {
        didSet {
            setupObservers()
        }
    }

    var receivedWKMessage = PassthroughSubject<(Status, URL), Error>()

    private let observeWKMessages: Bool

    init(observeWKMessages: Bool = false) {
        self.observeWKMessages = observeWKMessages
        let webConfiguration = WKWebViewConfiguration()

        if observeWKMessages {
            let userScript = WKUserScript(source: Self.getScript(), injectionTime: .atDocumentStart, forMainFrameOnly: false)
            webConfiguration.userContentController.addUserScript(userScript)
        }
        webConfiguration.allowsInlineMediaPlayback = true

        self.webView = WKWebView(frame: .zero, configuration: webConfiguration)

        super.init()

        if observeWKMessages {
            webView.configuration.userContentController.add(self, name: Constants.handlerName)
        }

        setupObservers()
    }

    private static func getScript() -> String {
        if let filepath = Bundle.main.path(forResource: "ajaxObserverScript", ofType: "js") {
            do {
                return try String(contentsOfFile: filepath)
            } catch {
                debugPrint(error)
            }
        } else {
            debugPrint("ajaxObserverScript.js not found!")
        }
        return ""
    }

    private func setupObservers() {
        func subscriber<Value>(for keyPath: KeyPath<WKWebView, Value>) -> NSKeyValueObservation {
            return webView.observe(keyPath, options: [.prior]) { _, change in
                if change.isPrior {
                    self.objectWillChange.send()
                }
            }
        }
        // Setup observers for all KVO compliant properties
        observers = [
            subscriber(for: \.title),
            subscriber(for: \.url),
            subscriber(for: \.isLoading),
            subscriber(for: \.estimatedProgress),
            subscriber(for: \.hasOnlySecureContent),
            subscriber(for: \.serverTrust),
            subscriber(for: \.canGoBack),
            subscriber(for: \.canGoForward)
        ]
    }
    
    private var observers: [NSKeyValueObservation] = []

    subscript<T>(dynamicMember keyPath: KeyPath<WKWebView, T>) -> T {
        webView[keyPath: keyPath]
    }
}

extension WebViewStore: WKScriptMessageHandler {
    /// Run when we receive a message from the script.js
    ///
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard
            observeWKMessages,
            let dict = message.body as? [String: AnyObject],
            let status = dict[Constants.statusKey] as? Status,
            let responseString = dict[Constants.responseUrlKey] as? String,
            let responseUrl = URL(string: responseString)
        else {
            receivedWKMessage.send(completion: .failure(GenericError()))
            return
        }

        receivedWKMessage.send((status, responseUrl))
    }
}

/// A container for using a WKWebView in SwiftUI
///
struct WebView: View, UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    let webView: WKWebView
    var loadNewURL: ((Error?) -> Void)?
    
    init(webView: WKWebView, loadNewURL: ((Error?) -> Void)? = nil) {
        self.webView = webView
        self.loadNewURL = loadNewURL
    }

    func makeUIView(context: UIViewRepresentableContext<WebView>) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<WebView>) {}
    
    func onStatusChanged(error: Error?) {
        if let error = error {
            loadNewURL?(error)
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        let parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
            super.init()
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation) {
            parent.onStatusChanged(error: nil)
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) {
            debugPrint("didStartProvisionalNavigation")
            debugPrint(webView.url?.absoluteString ?? "")
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
            debugPrint("didFinish")
            debugPrint(webView.url?.absoluteString ?? "")
        }
        
        func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation) {
            debugPrint("didReceiveServerRedirectForProvisionalNavigation")
            debugPrint(webView.url?.absoluteString ?? "")
        }
    
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation, withError error: Error) {
            debugPrint(error)
            parent.onStatusChanged(error: error)
        }
        
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if let frame = navigationAction.targetFrame, frame.isMainFrame {
                return nil
            }
            webView.load(navigationAction.request)
            return nil
        }
    }
}
