//
//  HrTag.swift
//  NaviX
//
//  Created by Helloyunho on 6/4/24.
//

import Foundation
import SwiftSoup
import SwiftUI

final class HrTag: BodyTagProtocol {
    let html: HTMLTag
    let tagName = "hr"
    let id = UUID()

    @Published var attr: [String: String] = [:] {
        didSet {
            NotificationCenter.default.postMain(
                name: .attrUpdated, object: self, userInfo: ["oldValue": oldValue])
        }
    }

    var _children = [String]()

    var children: [any Content] {
        get {
            _children
        }
        set {}
    }

    var style = CSSRuleSet()

    init(html: HTMLTag, attr: [String: String], children: [any Content] = [any Content]()) {
        self.html = html
        self.attr = attr
        self.children = children
    }

    static func parse(_ elem: Element, html: HTMLTag) throws -> HrTag {
        try HTMLUtils.checkTag(elem, assert: "hr")
        let (attr, children) = Self.parseDefaultProps(elem, html: html)

        return HrTag(html: html, attr: attr, children: children)
    }
}

struct HrTagView: View {
    @ObservedObject var tag: HrTag

    var body: some View {
        Divider()
            .frame(width: 0)
            .applyCommonListeners(tag: tag)
    }
}
