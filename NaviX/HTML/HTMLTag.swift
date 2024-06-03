//
//  HTMLTag.swift
//  NaviX
//
//  Created by Helloyunho on 6/3/24.
//

import Foundation
import SwiftSoup
import SwiftUI

struct HTMLTag: TagProtocol {
    let id = UUID()

    var attr: [String: String] = [:] {
        didSet {
            NotificationCenter.default.post(name: .attrUpdated, object: self, userInfo: ["oldValue": oldValue])
        }
    }

    var head: HeadTag {
        didSet {
            NotificationCenter.default.post(name: .childrenUpdated, object: self, userInfo: ["oldValue": oldValue])
        }
    }

    var body: BodyTag {
        didSet {
            NotificationCenter.default.post(name: .childrenUpdated, object: self, userInfo: ["oldValue": oldValue])
        }
    }

    static func parse(_ html: Element) throws -> HTMLTag {
        let attr = HTMLUtils.convertAttr(html.getAttributes())

        let headElem = try html.getElementsByTag("head")[0]
        let head = try HeadTag.parse(headElem)

        let bodyElem = try html.getElementsByTag("body")[0]
        let body = try BodyTag.parse(bodyElem)
        return HTMLTag(attr: attr, head: head, body: body)
    }
}
