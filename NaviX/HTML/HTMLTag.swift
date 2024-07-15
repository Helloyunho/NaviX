//
//  HTMLTag.swift
//  NaviX
//
//  Created by Helloyunho on 6/3/24.
//

import Foundation
import SwiftSoup
import SwiftUI

class HTMLTag: @unchecked Sendable, Equatable, Identifiable, Hashable {
    let tagName = "html"
    let id = UUID()

    static func == (lhs: HTMLTag, rhs: HTMLTag) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(tagName)
        hasher.combine(id)
        hasher.combine(attr)
    }

    var attr: [String: String] = [:] {
        didSet {
            NotificationCenter.default.postMain(
                name: .attrUpdated, object: self, userInfo: ["oldValue": oldValue])
        }
    }

    var stylesheets = [CSSStylesheet]() {
        didSet {
            NotificationCenter.default.postMain(
                name: .stylesheetsUpdated, object: self, userInfo: ["oldValue": oldValue])
        }
    }

    var head: HeadTag? {
        didSet {
            NotificationCenter.default.postMain(
                name: .childrenUpdated, object: self, userInfo: ["oldValue": oldValue as Any])
        }
    }

    var body: BodyTag? {
        didSet {
            NotificationCenter.default.postMain(
                name: .childrenUpdated, object: self, userInfo: ["oldValue": oldValue as Any])
        }
    }

    static func parse(_: Element, html _: HTMLTag) throws -> HTMLTag {
        fatalError("HTMLTag(_:html:) shouldn't be called")
    }

    @MainActor static func parse(_ html: Element) throws -> HTMLTag {
        let attr = HTMLUtils.convertAttr(html.getAttributes())

        let htmlTag = HTMLTag()
        htmlTag.attr = attr

        let headElem = try html.getElementsByTag("head")[0]
        let head = try HeadTag.parse(headElem, html: htmlTag)
        htmlTag.head = head

        let bodyElem = try html.getElementsByTag("body")[0]
        let body = try BodyTag.parse(bodyElem, html: htmlTag)
        htmlTag.body = body
        return htmlTag
    }
}
