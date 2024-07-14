//
//  LinkTag.swift
//  NaviX
//
//  Created by Helloyunho on 6/3/24.
//

import Foundation
import SwiftSoup

final class LinkTag: HeadTagProtocol {
    let html: HTMLTag
    let tagName = "link"
    let id = UUID()

    @Published var attr: [String: String] = [:] {
        didSet {
            NotificationCenter.default.postMain(name: .attrUpdated, object: self, userInfo: ["oldValue": oldValue])
        }
    }

    var href: String? {
        get {
            attr["href"]
        }
        set {
            attr["href"] = newValue
        }
    }

    var children: String = "" {
        didSet {
            NotificationCenter.default.postMain(name: .childrenUpdated, object: self, userInfo: ["oldValue": oldValue as Any])
        }
    }
    
    init(html: HTMLTag, attr: [String : String], children: String) {
        self.html = html
        self.attr = attr
        self.children = children
    }

    static func parse(_ link: Element, html: HTMLTag) throws -> LinkTag {
        try HTMLUtils.checkTag(link, assert: "link")
        let (attr, children) = Self.parseDefaultProps(link)

        return LinkTag(html: html, attr: attr, children: children)
    }
}
