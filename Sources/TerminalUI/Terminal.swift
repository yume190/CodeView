//
//  Terminal.swift
//  CodeView
//
//  Created by Yume on 2023/3/1.
//

import Foundation
import PathKit
import SwiftTerm
import SwiftUI
import Workspace

public extension NSNotification.Name {
  static var clearTerm: NSNotification.Name = .init("clearTerm")
}

private struct TerminalViewInner: NSViewRepresentable {
  fileprivate let from: Workspace?
  fileprivate let to: Workspace
  init(_ from: Workspace?, _ to: Workspace) {
    self.from = from
    self.to = to
  }
  
  fileprivate let origin: LocalProcessTerminalView = .init(frame: .zero)
  func makeNSView(context: Context) -> LocalProcessTerminalView {
    origin.font = NSFont.monospacedSystemFont(ofSize: 24, weight: .regular)
    
    return origin
  }
  
  func updateNSView(_ nsView: LocalProcessTerminalView, context: Context) {}
}

public struct TerminalView: View {
  private let inner: TerminalViewInner
  public init(_ from: Workspace?, _ to: Workspace) {
    inner = TerminalViewInner(from, to)
  }
  
  let pub = NotificationCenter.default
    .publisher(for: .clearTerm)
  public var body: some View {
    inner.onReceive(pub) { _ in
      clear()
    }
  }
}

extension TerminalView {
  private func getShell() -> String {
    let bufsize = sysconf(_SC_GETPW_R_SIZE_MAX)
    guard bufsize != -1 else {
      return "/bin/bash"
    }
    let buffer = UnsafeMutablePointer<Int8>.allocate(capacity: bufsize)
    defer {
      buffer.deallocate()
    }
    var pwd = passwd()
    var result: UnsafeMutablePointer<passwd>? = UnsafeMutablePointer<passwd>.allocate(capacity: 1)
    
    if getpwuid_r(getuid(), &pwd, buffer, bufsize, &result) != 0 {
      return "/bin/bash"
    }
    return String(cString: pwd.pw_shell)
  }
  
  func start(relative: String) {
    start("""
    \(FileManager.default.homeDirectoryForCurrentUser.path)/\(relative)
    """)
  }
  
  func start(_ cwd: String = FileManager.default.homeDirectoryForCurrentUser.path) {
    let shell = getShell()
    let shellIdiom = "-" + NSString(string: shell).lastPathComponent
    
    FileManager.default.changeCurrentDirectoryPath(cwd)
    
    inner.origin.startProcess(executable: shell, execName: shellIdiom)
  }
  
  public func send(txt: String) {
    inner.origin.send(txt: "\(txt)\r")
  }
  
  public func send(_ cmd: String) {
    inner.origin.send(txt: "clear\r\(cmd)\r")
  }
  
  private func sync() {
    guard let from = inner.from else { return }
    send(txt: "rsync -azvhPr \(from.path) \(inner.to.path)")
  }
  
  private func dir() {
    send(txt: "mkdir -p \(inner.to.path)")
  }
  
  private func toWorkspace() {
    send(txt: "cd \(inner.to.path)")
  }
  
  func clear() {
    send(txt: "clear")
  }
  
  private func initial() {
    if self.inner.from != nil {
      sync()
    } else {
      dir()
    }
    toWorkspace()
    clear()
  }
}

public extension TerminalView {
  func initialize(_ files: SourceFile...) -> TerminalView {
    let ws = inner.to.path
    try? ws.delete()
    
    defer {
      /// self.start(relative: inner.workspace.from ?? "")
      self.start(inner.to.path.string)
      self.initial()
    }
    
    inner.to.initialize(files)
    
    return self
  }
}
