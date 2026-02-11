import UIKit
import WebKit

private let baseURL = URL(string: "https://choorai.com")!

struct Logger {
    static func log(_ event: String, _ payload: [String: String] = [:]) {
        var safe = payload
        if safe["token"] != nil { safe["token"] = "[REDACTED]" }
        print("[native-ios][\(event)] \(safe)")
    }
}

final class WebViewController: UIViewController, WKNavigationDelegate {
    private let webView = WKWebView(frame: .zero)
    private var lastHandledReturnURL: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        view = webView
        webView.navigationDelegate = self

        // Example mode: loose setup for demo. Production should harden policy.
        webView.load(URLRequest(url: baseURL))

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onDeepLink(_:)),
            name: .didReceiveDeepLink,
            object: nil
        )
    }

    @objc private func onDeepLink(_ note: Notification) {
        guard let url = note.object as? URL else { return }
        let isReturn = url.host == "pay" && url.path == "/return"
        if !isReturn { return }

        // Example mode: loose parsing.
        // Production default: strict allowlist + idempotency by transaction key.
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let encoded = components.queryItems?.first(where: { $0.name == "url" })?.value else {
            Logger.log("deep_link_error", ["reason": "missing_url"])
            return
        }

        let decoded = encoded.removingPercentEncoding ?? encoded
        if decoded == lastHandledReturnURL { return }
        lastHandledReturnURL = decoded

        guard let returnURL = URL(string: decoded) else {
            Logger.log("deep_link_error", ["reason": "malformed_url"])
            return
        }

        webView.load(URLRequest(url: returnURL))
        Logger.log("deep_link_loaded", ["url": decoded])
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        Logger.log("navigation", ["url": url.absoluteString])

        if ["http", "https"].contains(url.scheme?.lowercased() ?? "") {
            decisionHandler(.allow)
            return
        }

        // Example requirement: loose external open.
        // Production default: strict scheme allowlist + canOpenURL checks.
        UIApplication.shared.open(url, options: [:]) { ok in
            Logger.log("external_launch", ["url": url.absoluteString, "success": String(ok)])
        }
        decisionHandler(.cancel)
    }
}
