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
    var html: HTMLGetter {
        {
            self
        }
    }

    let tagName = "html"
    let id = UUID()

    var attr: [String: String] = [:] {
        didSet {
            NotificationCenter.default.post(name: .attrUpdated, object: self, userInfo: ["oldValue": oldValue])
        }
    }

    var stylesheets = [CSSStylesheet]()

    var head: HeadTag? {
        didSet {
            NotificationCenter.default.post(name: .childrenUpdated, object: self, userInfo: ["oldValue": oldValue as Any])
        }
    }

    var body: BodyTag? {
        didSet {
            NotificationCenter.default.post(name: .childrenUpdated, object: self, userInfo: ["oldValue": oldValue as Any])
        }
    }

    static func parse(_: Element, html _: @escaping HTMLGetter) throws -> HTMLTag {
        fatalError("HTMLTag(_:html:) shouldn't be called")
    }

    static func parse(_ html: Element) throws -> HTMLTag {
        let attr = HTMLUtils.convertAttr(html.getAttributes())

        var htmlTag = HTMLTag(attr: attr, head: nil, body: nil)

        let headElem = try html.getElementsByTag("head")[0]
        let head = try HeadTag.parse(headElem, html: htmlTag.html)
        htmlTag.head = head

        let bodyElem = try html.getElementsByTag("body")[0]
        let body = try BodyTag.parse(bodyElem, html: htmlTag.html)
        htmlTag.body = body
        return htmlTag
    }
}
