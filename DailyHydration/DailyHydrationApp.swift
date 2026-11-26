import Foundation
import SwiftUI
import UIKit
import WebKit

@main
struct DailyHydrationApp: App {
    var body: some Scene {
        WindowGroup {
            HydrationView()
                .background(Color(red: 11 / 255, green: 14 / 255, blue: 20 / 255).ignoresSafeArea())
                .preferredColorScheme(.dark)
        }
    }
}

struct HydrationView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let content = configuration.userContentController
        content.addScriptMessageHandler(context.coordinator, contentWorld: .page, name: "hydration")

        let saved: Data?
        do {
            saved = try context.coordinator.store.load()
        } catch {
            saved = Data("Unable to read saved hydration data.".utf8)
        }
        if let saved {
            let source = "window.hydrationInitialBase64 = '" + saved.base64EncodedString() + "';"
            content.addUserScript(WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: true))
        }

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.underPageBackgroundColor = UIColor(red: 11 / 255, green: 14 / 255, blue: 20 / 255, alpha: 1)
        if let page = Bundle.main.url(forResource: "index", withExtension: "html") {
            webView.loadFileURL(page, allowingReadAccessTo: page)
        } else {
            webView.loadHTMLString("<p>无法打开每日饮水。请重新安装应用。</p>", baseURL: nil)
        }
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "hydration", contentWorld: .page)
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandlerWithReply {
        let store = HydrationStore()

        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage,
            replyHandler: @escaping (Any?, String?) -> Void
        ) {
            guard message.name == "hydration", message.frameInfo.isMainFrame,
                  let contents = message.body as? String else {
                replyHandler(nil, "Invalid save request.")
                return
            }
            do {
                try store.save(contents)
                replyHandler(true, nil)
            } catch {
                replyHandler(nil, "Unable to save hydration data.")
            }
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            let url = navigationAction.request.url
            if let url, navigationAction.navigationType == .linkActivated, url.scheme == "https" {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
            let allowed = url?.isFileURL == true || url?.absoluteString == "about:blank"
            decisionHandler(allowed ? .allow : .cancel)
        }
    }
}

struct HydrationStore {
    private func fileURL(createDirectory: Bool) throws -> URL {
        try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: createDirectory
        ).appendingPathComponent("daily-hydration.json", isDirectory: false)
    }

    func load() throws -> Data? {
        do {
            return try Data(contentsOf: fileURL(createDirectory: true))
        } catch let error as NSError where error.domain == NSCocoaErrorDomain && error.code == NSFileReadNoSuchFileError {
            return nil
        }
    }

    func save(_ contents: String) throws {
        let data = Data(contents.utf8)
        guard let snapshot = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let goal = snapshot["goal"] as? Int, (1...10_000).contains(goal),
              snapshot["entries"] is [Any] else {
            throw CocoaError(.fileWriteInapplicableStringEncoding)
        }
        try data.write(to: fileURL(createDirectory: true), options: .atomic)
    }
}
