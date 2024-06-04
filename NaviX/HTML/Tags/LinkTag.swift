//
//  LinkTag.swift
//  NaviX
//
//  Created by Helloyunho on 6/3/24.
//

import Foundation
import SwiftSoup

struct LinkTag: HeadTagProtocol {
    let html: HTMLGetter
    let tagName = "link"
    let id = UUID()

    var attr: [String: String] = [:] {
        didSet {
            NotificationCenter.default.post(name: .attrUpdated, object: self, userInfo: ["oldValue": oldValue])
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
            NotificationCenter.default.post(name: .childrenUpdated, object: self, userInfo: ["oldValue": oldValue as Any])
        }
    }

    static func parse(_ link: Element, html: @escaping HTMLGetter) throws -> LinkTag {
        try HTMLUtils.checkTag(link, assert: "link")
        let (attr, children) = Self.parseDefaultProps(link)

        return LinkTag(html: html, attr: attr, children: children)
    }
}
