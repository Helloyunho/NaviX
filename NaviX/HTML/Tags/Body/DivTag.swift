//
//  DivTag.swift
//  NaviX
//
//  Created by Helloyunho on 6/4/24.
//

import Foundation
import SwiftSoup
import SwiftUI

final class DivTag: BodyTagProtocol {
    let html: HTMLTag
    let tagName = "div"
    let id = UUID()

    @Published var attr: [String: String] = [:] {
        didSet {
            NotificationCenter.default.postMain(name: .attrUpdated, object: self, userInfo: ["oldValue": oldValue])
        }
    }

    @Published var children: [any Content] = [] {
        didSet {
            NotificationCenter.default.postMain(name: .childrenUpdated, object: self, userInfo: ["oldValue": oldValue as Any])
        }
    }
    
    @Published var style = CSSRuleSet()
    
    init(html: HTMLTag, attr: [String : String], children: [any Content]) {
        self.html = html
        self.attr = attr
        self.children = children
    }

    static func parse(_ elem: Element, html: HTMLTag) throws -> DivTag {
        try HTMLUtils.checkTag(elem, assert: "div")
        let (attr, children) = Self.parseDefaultProps(elem, html: html)

        return DivTag(html: html, attr: attr, children: children)
    }
}

struct DivTagView: View {
    @ObservedObject var tag: DivTag
    
    var body: some View {
        ContainerView(columnGap: tag.style.columnGap ?? 0, rowGap: tag.style.rowGap ?? 0, direction: tag.style.direction ?? .column, alignItems: tag.style.alignItems ?? .fill, wrap: tag.style.wrap) {
            ForEach(tag.children, id: \.id) { child in
                if let child = child as? String {
                    if tag.style.alignItems == .fill {
                        switch (tag.style.direction ?? .column) {
                        case .row:
                            Text(child)
                                .textSelection(.enabled)
                                .frame(maxHeight: .infinity)
                        case .column:
                            Text(child)
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity)
                        }
                    } else {
                        Text(child)
                            .textSelection(.enabled)
                    }
                } else if let child = child as? (any BodyTagProtocol) {
                    if tag.style.alignItems == .fill {
                        switch (tag.style.direction ?? .column) {
                        case .row:
                            HTMLUtils.getViewFromTags(child)
                                .frame(maxHeight: .infinity)
                        case .column:
                            HTMLUtils.getViewFromTags(child)
                                .frame(maxWidth: .infinity)
                        }
                    } else {
                        HTMLUtils.getViewFromTags(child)
                    }
                }
            }
        }
        .applyCommonCSS(ruleSet: tag.style, tag: tag)
        .applyCommonListeners(tag: tag)
    }
}
