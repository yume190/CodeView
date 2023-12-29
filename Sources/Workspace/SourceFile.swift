//
//  SourceFile.swift
//  DemoList
//
//  Created by Tangram Yume on 2023/12/6.
//

import Foundation
import PathKit

public typealias SourceFile = RelativePathSourceFile
public class RelativePathSourceFile {
  public let lang: CodeLang
  public let code: String
  /// relatvie path to `Workspace`
  public let path: String
  
  public init(_ lang: CodeLang, _ code: String, _ path: String) {
    self.lang = lang
    self.code = code
    self.path = path
  }
}

public class AbsolutePathSourceFile: SourceFile {
  public let workspace: Workspace
  //  private let watcher: FileWatcher
  
  /// origin: origin source absolute path
  public init(_ lang: CodeLang, _ workspace: Workspace, _ path: String) {
    self.workspace = workspace
    let targetFile = workspace.path + path
    let code = (try? targetFile.read()) ?? ""
    
    super.init(lang, code, path)
  }
  
  public var abolutePath: Path {
    return workspace.path + path
  }
  
  public func read() throws -> String {
    return try abolutePath.read()
  }
  
  public func write(code: String) throws  {
    try abolutePath.write(code, encoding: .utf8)
  }  
}


//class StringViewModel: ObservableObject {
//    @Published var value: String = ""
//
//    // Simulate a string stream
//    private var timer: Timer?
//    let _pipe = Pipe()
//
//    init() {
//      dup2(_pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
//      startStringStream()
//    }
//
//    private func startStringStream() {
//      _pipe.fileHandleForReading.readabilityHandler = { [weak self] stdErrFileHandle in
//        let data = stdErrFileHandle.availableData
//        self?.value = String(data: data, encoding: .utf8) ?? "Nil"
//      }
//    }
//
//    deinit {
//      dup2(STDOUT_FILENO, _pipe.fileHandleForWriting.fileDescriptor)
//    }
//}

