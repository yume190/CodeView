//
//  SourceFile.swift
//  CodeView
//
//  Created by Yume on 2023/3/2.
//

import Foundation
import PathKit

public struct SourceFile {
    public let lang: CodeLang
    public let code: String
    /// relatvie path to `Workspace`
    public let path: String?
    
    public init(_ lang: CodeLang, _ code: String, _ path: String? = nil) {
        self.lang = lang
        self.code = code
        self.path = path
    }
    
    /// origin: origin source absolute path
    public init(_ lang: CodeLang, origin: Workspace, _ path: String? = nil) {
        let code: String
        if let from = origin.from, let path = path {
            let sourceFile = PathKit.Path(from) + path
            code = (try? sourceFile.read(.utf8)) ?? "Can't Read file"
        } else {
            code = "Can't Read file"
        }
        
        self.init(lang, code, path)
    }
    
    public static func swiftMain(_ code: String) -> SourceFile {
        return .init(.swift, code, "Sources/SPM/main.swift")
    }
    
    public static func md(_ code: String) -> SourceFile {
        return .init(.markdown, code, nil)
    }
}
