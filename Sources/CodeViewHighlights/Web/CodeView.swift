//
//  CodeView.swift
//  CodeView
//
//  Created by Yume on 2023/2/24.
//

import PathKit
import SwiftUI
import Workspace

/// use case
///  1. ws: o
///     code: from file path
///     file in ws
///  2. ws: o
///     code: from input
///     file not in ws
///  3. ws: x(default)
///     code: from input
public struct CodeView: View {
  private let web: CodeWebView
  public let file: AbsolutePathSourceFile
  public let show: Bool
  public init(_ file: AbsolutePathSourceFile, _ show: Bool = false) {
    self.file = file
    self.show = show
    self.web = CodeWebView(file)
  }
  
  public var body: some View {
    VStack(alignment: .center) {
      if show {
        Text("Language: \(file.lang.rawValue)")
        Text("file: \(file.path)")
      }
      web
    }
  }
}
