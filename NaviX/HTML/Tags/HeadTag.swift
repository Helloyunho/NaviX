//
//  HeadTag.swift
//  NaviX
//
//  Created by Helloyunho on 6/3/24.
//

import Foundation
import SwiftSoup

struct HeadTag: TagProtocol {
    let html: HTMLGetter
    let tagName = "head"
    let id = UUID()

    var attr: [String: String] = [:] {
        didSet {
            NotificationCenter.default.post(name: .attrUpdated, object: self, userInfo: ["oldValue": oldValue])
        }
    }

    var children: [any HeadTagProtocol]? = nil {
        didSet {
            NotificationCenter.default.post(name: .childrenUpdated, object: self, userInfo: ["oldValue": oldValue as Any])
        }
    }

    static func parse(_ head: Element, html: @escaping HTMLGetter) throws -> HeadTag {
        try HTMLUtils.checkTag(head, assert: "head")
        let attr = HTMLUtils.convertAttr(head.getAttributes())
        let children = HTMLUtils.parseHeadTags(head, html: html)

        return HeadTag(html: html, attr: attr, children: children)
    }
}
