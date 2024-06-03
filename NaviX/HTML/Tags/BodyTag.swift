//
//  BodyTag.swift
//  NaviX
//
//  Created by Helloyunho on 6/3/24.
//

import Foundation
import SwiftSoup

struct BodyTag: TagProtocol {
    static func == (lhs: BodyTag, rhs: BodyTag) -> Bool {
        lhs.id == rhs.id
    }

    var id = UUID()

    var attr: [String: String] = [:] {
        didSet {
            NotificationCenter.default.post(name: .attrUpdated, object: self, userInfo: ["oldValue": oldValue])
        }
    }

    var children: [any Content]? = nil {
        didSet {
            NotificationCenter.default.post(name: .childrenUpdated, object: self, userInfo: ["oldValue": oldValue as Any])
        }
    }

    static func parse(_ body: Element) throws -> BodyTag {
        try HTMLUtils.checkTag(body, assert: "body")
        let attr = HTMLUtils.convertAttr(body.getAttributes())
        let children = HTMLUtils.parseBodyTags(body)
        return BodyTag(attr: attr, children: children)
    }
}
