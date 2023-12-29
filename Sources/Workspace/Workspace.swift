import Foundation
import PathKit

extension Workspace: Equatable {
  public static func == (lhs: Workspace, rhs: Workspace) -> Bool {
    lhs._path == rhs._path
  }
}

extension Workspace: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(_path)
  }
}

extension Workspace: Identifiable {
  public var id: String {
    _path
  }
}



public struct Workspace {
  
  public static let `default`: Workspace = .init(path: "CodeViewTemp")
  
  public init(path: String) {
    self._path = path
  }
  
  public let _path: String
  public var path: Path {
    Path(_path)
  }
  
  public func load(_ file: SourceFile) -> AbsolutePathSourceFile {
    return AbsolutePathSourceFile(file.lang, self, file.path)
  }
  
  public func initialize(_ files: SourceFile...) {
    initialize(files)
  }
  
  public func initialize(_ files: [SourceFile]) {
    files.forEach { file in
      let fullPath = self.path + file.path
      
      let parentPath = fullPath.parent()
      do {
        try parentPath.mkpath()
        try fullPath.write(file.code, encoding: .utf8)
      } catch {
        print(error)
      }
    }
  }
  

  
  public func executeCommand() throws -> String? {
    let process = Process()
    process.launchPath = "/usr/bin/swift"
    process.arguments = ["build"]
    
    let pipe = Pipe()
    process.standardOutput = pipe
    process.currentDirectoryURL = path.url
    process.launch()
    
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)
    process.waitUntilExit()
    let exitCode = process.terminationStatus
    
    guard exitCode == 0 else {
      //      throw
      return nil
    }
    
    return output
  }
}
