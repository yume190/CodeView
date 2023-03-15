//
//  WebView.swift
//  CodeView
//
//  Created by Yume on 2023/3/1.
//

import PathKit
import SwiftUI
import WebKit

@objc
class Message: NSObject, WKScriptMessageHandler {
    let file: SourceFile
    let ws: Workspace?
    init(_ file: SourceFile, _ ws: Workspace?) {
        self.file = file
        self.ws = ws
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "onSave":
            guard let code = message.body as? String else { return }
            guard let folder = ws?.to else { return }
            guard let path = file.path else { return }
            let to = PathKit.Path(folder) + path
            do {
                try to.write(code, encoding: .utf8)
            } catch {
                print(error)
            }
        default:
            break
        }
    }
}

@objc
class CodeWebViewNavigation: NSObject, WKNavigationDelegate {
    private var isReady = false
    private var cache: [(lang: CodeLang, code: String)] = []
    let file: SourceFile
    init(_ file: SourceFile) {
        self.file = file
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        execute(webView, file.lang, file.code)
        isReady = true
        cache.forEach { lang, code in
            execute(webView, lang, code)
        }
        cache = []
    }

    func execute(_ webView: WKWebView, _ lang: CodeLang, _ code: String) {
        if isReady {
            let _code: String
            if lang == .markdown {
                _code = code
                    .replacingOccurrences(of: "\n", with: "\\n")
                    .replacingOccurrences(of: "\"", with: "\\\"")
            } else {
                _code = code
                    .replacingOccurrences(of: "\n", with: "\\n")
                    .replacingOccurrences(of: "\"", with: "\\\"")
                    .replacingOccurrences(of: "<", with: "&lt;")
                    .replacingOccurrences(of: ">", with: "&gt;")
            }

            let json = """
            {
                "lang": "\(lang.rawValue)",
                "code": "\(_code)"
            }
            """
            let command = "load(\(json));"
            webView.evaluateJavaScript(command) { _, _ in
//                print(a, err)
            }
        } else {
            cache.append((lang, code))
        }
    }
}

private struct CodeWebViewInner: NSViewRepresentable {
    private static let url = Bundle.current.url(forResource: "index", withExtension: "html", subdirectory: "highlights")!

    let webView: WKWebView
    let navigation: CodeWebViewNavigation
    let message: Message
    let file: SourceFile

    init(_ file: SourceFile, _ ws: Workspace?) {
        self.file = file
        self.navigation = .init(file)
        self.message = .init(file, ws)

        let preferences = WKWebpagePreferences()
        if #available(macOS 11.0, *) {
            preferences.allowsContentJavaScript = true
        } else {
            // Fallback on earlier versions
        }

        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = preferences
        config.userContentController = WKUserContentController()
        config.userContentController.add(message, name: "onSave")

        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = navigation
    }

    func makeNSView(context: Context) -> WKWebView {
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        let request = URLRequest(url: Self.url)
        webView.load(request)
    }

    static func dismantleNSView(_ nsView: WKWebView, coordinator: Coordinator) {
        print("dismantle \(nsView)")
        nsView.configuration.userContentController.removeScriptMessageHandler(forName: "onChange")
        nsView.configuration.userContentController.removeScriptMessageHandler(forName: "onSave")
    }
}

struct CodeWebView: View {
    private let inner: CodeWebViewInner
    init(_ file: SourceFile, _ ws: Workspace? = nil) {
        self.inner = CodeWebViewInner(file, ws)
    }

    let pub = NotificationCenter.default
        .publisher(for: .save)
    var body: some View {
        inner.onReceive(pub) { _ in
            self.inner.webView.evaluateJavaScript("save()") { _, _ in
//                print(a, err)
            }
            print("web noti")
        }
    }
}
