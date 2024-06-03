//
//  LinkTag.swift
//  NaviX
//
//  Created by Helloyunho on 6/3/24.
//

import Foundation
import SwiftSoup

struct LinkTag: HeadTagProtocol {
    var id = UUID()

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

    var children: String? = nil {
        didSet {
            NotificationCenter.default.post(name: .childrenUpdated, object: self, userInfo: ["oldValue": oldValue as Any])
        }
    }

    static func parse(_ link: Element) throws -> LinkTag {
        try HTMLUtils.checkTag(link, assert: "link")
        let (attr, children) = Self.parseDefaultProps(link)

        return LinkTag(attr: attr, children: children)
    }
}
