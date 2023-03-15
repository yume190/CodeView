//
//  Workspace.swift
//  CodeView
//
//  Created by Yume on 2023/2/28.
//

import Foundation
import SwiftTerm

/// NSTemporaryDirectory()/path
///
/// to: temp/path
///
/// rsync -az from to
public class Workspace {
    public static let `default`: Workspace = .init(path: "CodeViewTemp")
    
    public init(from: String? = nil, path: String) {
        self.path = path
        self.from = from
    }

    /// /Path/To/Folder/
    public let from: String?
    public let path: String
    
    private static let temp = NSTemporaryDirectory()
    public var to: String {
        "\(Workspace.temp)\(path)"
    }
}
