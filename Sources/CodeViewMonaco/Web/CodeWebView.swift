//
//  WebView.swift
//  CodeView
//
//  Created by Yume on 2023/3/1.
//

import PathKit
import SwiftUI
import WebKit
import Workspace

struct CodeWebView: View {
  private let inner: CodeWebViewInner
  init(_ file: AbsolutePathSourceFile?) {
    self.inner = CodeWebViewInner(file)
  }
  
  var body: some View {
    inner
  }
}

private struct CodeWebViewInner: NSViewRepresentable {
  func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
  }
  
  private static let url = Bundle.current.url(
    forResource: "index",
    withExtension: "html",
    subdirectory: "monaco-editor")!
  
  let file: AbsolutePathSourceFile?
  
  init(_ file: AbsolutePathSourceFile?) {
    self.file = file
  }
  
  func makeNSView(context: Context) -> WKWebView {
    let coor = context.coordinator
    
    let preferences = WKWebpagePreferences()
    if #available(macOS 11.0, *) {
      preferences.allowsContentJavaScript = true
    } else {
      // Fallback on earlier versions
    }
    
    let config = WKWebViewConfiguration()
    config.defaultWebpagePreferences = preferences
    config.userContentController = WKUserContentController()
    config.userContentController.add(coor, name: "onSave")
    
    let webView = WKWebView(frame: .zero, configuration: config)
    webView.navigationDelegate = coor
    
    let request = URLRequest(url: Self.url)
    webView.load(request)
    coor.web = webView
    return webView
  }
  
  func updateNSView(_ nsView: WKWebView, context: Context) {
    let web = nsView
    let code: String = file?.code ?? ""
    context.coordinator.web = web
    context.coordinator.parent = self
    context.coordinator.execute(web, code)
  }
  
  static func dismantleNSView(_ nsView: WKWebView, coordinator: Coordinator) {
    print("dismantle \(nsView)")
    nsView.configuration.userContentController.removeScriptMessageHandler(forName: "onChange")
    nsView.configuration.userContentController.removeScriptMessageHandler(forName: "onSave")
  }
}


@objc
fileprivate class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
  weak var web: WKWebView?
  var parent: CodeWebViewInner
  init(parent: CodeWebViewInner) {
    self.parent = parent
    super.init()
    
    NotificationCenter.default.addObserver(forName: .save, object: nil, queue: .main) { [weak self] _ in
      self?.web?.evaluateJavaScript("save()") { res, err in
        print("""
        [Web] Save ->
        [Web] res <- \(res.debugDescription)
        [Web] err <- \(err.debugDescription)
        """)
      }
    }
  }
  
  func userContentController(
    _ userContentController: WKUserContentController,
    didReceive message: WKScriptMessage
  ) {
    switch message.name {
    case "onSave":
      guard let code = message.body as? String else { return }
      guard let file = parent.file else {return}
      do {
        try file.write(code: code)
      } catch {
        print(error)
      }
    default:
      break
    }
  }
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    execute(webView, (parent.file?.code) ?? "")
  }
  
  func execute(_ webView: WKWebView, _ code: String) {
    let _code: String
    
    _code = code
      .replacingOccurrences(of: "\\", with: "\\\\")
      .replacingOccurrences(of: "\n", with: "\\n")
      .replacingOccurrences(of: "\"", with: "\\\"")
      .replacingOccurrences(of: "<", with: "&lt;")
      .replacingOccurrences(of: ">", with: "&gt;")
    
    
    let json = """
    {
        "code": "\(_code)"
    }
    """
    let command = "loadCode(\(json));"
    webView.evaluateJavaScript(command) { res, err in
      print("""
      [Web] Load Code ->
      [Web] res <- \(res.debugDescription)
      [Web] err <- \(err.debugDescription)
      """)
    }
  }
}
