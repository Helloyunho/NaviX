//
//  UlTag.swift
//  NaviX
//
//  Created by Helloyunho on 6/4/24.
//

import Foundation
import SwiftSoup
import SwiftUI

final class UlTag: BodyTagProtocol {
    let html: HTMLTag
    let tagName = "ul"
    let id = UUID()

    @Published var attr: [String: String] = [:] {
        didSet {
            NotificationCenter.default.postMain(
                name: .attrUpdated, object: self, userInfo: ["oldValue": oldValue])
        }
    }

    @Published var children: [any Content] = [] {
        didSet {
            NotificationCenter.default.postMain(
                name: .childrenUpdated, object: self, userInfo: ["oldValue": oldValue as Any])
        }
    }

    @Published var style = CSSRuleSet()

    init(html: HTMLTag, attr: [String: String], children: [any Content]) {
        self.html = html
        self.attr = attr
        self.children = children
    }

    static func parse(_ elem: Element, html: HTMLTag) throws -> UlTag {
        try HTMLUtils.checkTag(elem, assert: "ul")
        let (attr, children) = Self.parseDefaultProps(elem, html: html)

        return UlTag(html: html, attr: attr, children: children)
    }
}

struct UlTagView: View {
    @ObservedObject var tag: UlTag

    var body: some View {
        VStack {
            ForEach(tag.children, id: \.id) { child in
                HStack {
                    Circle()
                        .frame(width: 2, height: 2)
                    if let child = child as? String {
                        Text(child)
                            .textSelection(.enabled)
                    } else if let child = child as? (any BodyTagProtocol) {
                        HTMLUtils.getViewFromTags(child)
                    }
                }
            }
        }
        .applyCommonCSS(ruleSet: tag.style, tag: tag)
        .applyCommonListeners(tag: tag)
    }
}
