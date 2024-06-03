//
//  HeadTag.swift
//  NaviX
//
//  Created by Helloyunho on 6/3/24.
//

import Foundation
import SwiftSoup

struct HeadTag: TagProtocol {
    var id = UUID()

    static func == (lhs: HeadTag, rhs: HeadTag) -> Bool {
        lhs.id == rhs.id
    }

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

    static func parse(_ head: Element) throws -> HeadTag {
        try HTMLUtils.checkTag(head, assert: "head")
        let attr = HTMLUtils.convertAttr(head.getAttributes())
        let children = HTMLUtils.parseHeadTags(head)

        return HeadTag(attr: attr, children: children)
    }
}
