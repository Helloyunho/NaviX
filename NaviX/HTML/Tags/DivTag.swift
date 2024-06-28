//
//  DivTag.swift
//  NaviX
//
//  Created by Helloyunho on 6/4/24.
//

import Foundation
import SwiftSoup
import SwiftUI

struct DivTag: BodyTagProtocol {
    let html: HTMLGetter
    let tagName = "div"
    let id = UUID()

    var attr: [String: String] = [:] {
        didSet {
            NotificationCenter.default.post(name: .attrUpdated, object: self, userInfo: ["oldValue": oldValue])
        }
    }

    var children: [any Content] = [] {
        didSet {
            NotificationCenter.default.post(name: .childrenUpdated, object: self, userInfo: ["oldValue": oldValue as Any])
        }
    }
    
    var style: CSSRuleSet {
        let html = self.html()
        var result = CSSRuleSet()
        for stylesheet in html.stylesheets {
            result += stylesheet.findRuleset(for: self, html: html).reduce(result, +)
        }
        if let css = attr["style"], let ruleset = try? CSSRuleSet.parse(css) {
            result += ruleset
        }

        return result
    }

    var body: some View {
        ContainerView(columnGap: style.columnGap ?? 0, rowGap: style.rowGap ?? 0, direction: style.direction ?? .column, alignItems: style.alignItems ?? .fill, wrap: style.wrap) {
            ForEach(children, id: \.id) { child in
                if let child = child as? String {
                    if style.alignItems == .fill {
                        switch (style.direction ?? .column) {
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
                    if style.alignItems == .fill {
                        switch (style.direction ?? .column) {
                        case .row:
                            AnyView(child.body)
                                .frame(maxHeight: .infinity)
                        case .column:
                            AnyView(child.body)
                                .frame(maxWidth: .infinity)
                        }
                    } else {
                        AnyView(child.body)
                    }
                }
            }
        }
        .applyCommonCSS(ruleSet: style, tag: self)
    }

    static func parse(_ div: Element, html: @escaping HTMLGetter) throws -> DivTag {
        try HTMLUtils.checkTag(div, assert: "div")
        let (attr, children) = Self.parseDefaultProps(div, html: html)

        return DivTag(html: html, attr: attr, children: children)
    }
}
