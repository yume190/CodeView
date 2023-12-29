//
//  File.swift
//
//
//  Created by Yume on 2023/3/6.
//

import Foundation

private final class _Bundle {
    static let bundle: Bundle = {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: _Bundle.self)
        #endif
    }()
}

extension Bundle {
    static let current: Bundle = _Bundle.bundle
}
