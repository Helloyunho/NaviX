//
//  HeadTag.swift
//  NaviX
//
//  Created by Helloyunho on 6/3/24.
//

import Foundation
import SwiftSoup

final class HeadTag: TagProtocol {
    let html: HTMLTag
    let tagName = "head"
    let id = UUID()

    @Published var attr: [String: String] = [:] {
        didSet {
            NotificationCenter.default.postMain(name: .attrUpdated, object: self, userInfo: ["oldValue": oldValue])
        }
    }

    @Published var children: [any HeadTagProtocol]? = nil {
        didSet {
            NotificationCenter.default.postMain(name: .childrenUpdated, object: self, userInfo: ["oldValue": oldValue as Any])
        }
    }
    
    init(html: HTMLTag, attr: [String : String], children: [any HeadTagProtocol]) {
        self.html = html
        self.attr = attr
        self.children = children
    }

    static func parse(_ head: Element, html: HTMLTag) throws -> HeadTag {
        try HTMLUtils.checkTag(head, assert: "head")
        let attr = HTMLUtils.convertAttr(head.getAttributes())
        let children = HTMLUtils.parseHeadTags(head, html: html)

        return HeadTag(html: html, attr: attr, children: children)
    }
}
