//
//  ScriptTag.swift
//  NaviX
//
//  Created by Helloyunho on 6/3/24.
//

import Foundation
import SwiftSoup

struct ScriptTag: HeadTagProtocol {
    var id = UUID()

    var attr: [String: String] = [:] {
        didSet {
            NotificationCenter.default.post(name: .attrUpdated, object: self, userInfo: ["oldValue": oldValue])
        }
    }

    var src: String? {
        get {
            attr["src"]
        }
        set {
            attr["src"] = newValue
        }
    }

    var children: String? = nil {
        didSet {
            NotificationCenter.default.post(name: .childrenUpdated, object: self, userInfo: ["oldValue": oldValue as Any])
        }
    }

    static func parse(_ script: Element) throws -> ScriptTag {
        try HTMLUtils.checkTag(script, assert: "script")
        let (attr, children) = Self.parseDefaultProps(script)

        return ScriptTag(attr: attr, children: children)
    }
}
