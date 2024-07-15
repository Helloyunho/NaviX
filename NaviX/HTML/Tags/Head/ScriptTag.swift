//
//  ScriptTag.swift
//  NaviX
//
//  Created by Helloyunho on 6/3/24.
//

import Foundation
import SwiftSoup

final class ScriptTag: HeadTagProtocol {
    let html: HTMLTag
    let tagName = "script"
    let id = UUID()

    @Published var attr: [String: String] = [:] {
        didSet {
            NotificationCenter.default.postMain(
                name: .attrUpdated, object: self, userInfo: ["oldValue": oldValue])
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

    @Published var children: String = "" {
        didSet {
            NotificationCenter.default.postMain(
                name: .childrenUpdated, object: self, userInfo: ["oldValue": oldValue as Any])
        }
    }

    init(html: HTMLTag, attr: [String: String], children: String) {
        self.html = html
        self.attr = attr
        self.children = children
    }

    static func parse(_ script: Element, html: HTMLTag) throws -> ScriptTag {
        try HTMLUtils.checkTag(script, assert: "script")
        let (attr, children) = Self.parseDefaultProps(script)

        return ScriptTag(html: html, attr: attr, children: children)
    }
}
