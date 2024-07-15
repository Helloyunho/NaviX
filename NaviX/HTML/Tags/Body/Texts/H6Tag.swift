//
//  H6Tag.swift
//  NaviX
//
//  Created by Helloyunho on 6/4/24.
//

import Foundation
import SwiftSoup
import SwiftUI

final class H6Tag: BodyTagProtocol {
    let html: HTMLTag
    let tagName = "h6"
    let id = UUID()

    @Published var attr: [String: String] = [:] {
        didSet {
            NotificationCenter.default.postMain(
                name: .attrUpdated, object: self, userInfo: ["oldValue": oldValue])
        }
    }

    @Published var _children = [String]()

    var children: [any Content] {
        get {
            _children
        }
        set {
            let oldValue = _children
            _children = newValue.filter { $0 is String }.map { $0 as! String }
            NotificationCenter.default.postMain(
                name: .childrenUpdated, object: self, userInfo: ["oldValue": oldValue as Any])
        }
    }

    @Published var style = CSSRuleSet()

    init(html: HTMLTag, attr: [String: String], children: [any Content] = [any Content]()) {
        self.html = html
        self.attr = attr
        self.children = children
    }

    static func parse(_ elem: Element, html: HTMLTag) throws -> H6Tag {
        try HTMLUtils.checkTag(elem, assert: "h6")
        let (attr, children) = Self.parseDefaultProps(elem, html: html)

        return H6Tag(html: html, attr: attr, children: children)
    }
}

struct H6TagView: View {
    @ObservedObject var tag: H6Tag

    var body: some View {
        Text(tag._children.joined(separator: " "))
            .textSelection(.enabled)
            .modifier(
                CSSRuleSet.CSSFontModifier(
                    ruleSet: tag.style, defaultFontSize: 14, defaultFontWeight: .bold)
            )
            .modifier(CSSRuleSet.CSSColorModifier(ruleSet: tag.style))
            .applyCommonCSS(ruleSet: tag.style, tag: tag)
            .applyCommonListeners(tag: tag)
    }
}
