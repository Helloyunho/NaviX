//
//  UlTag.swift
//  NaviX
//
//  Created by Helloyunho on 6/4/24.
//

import Foundation
import SwiftSoup
import SwiftUI

struct UlTag: BodyTagProtocol {
    let html: HTMLGetter
    let tagName = "ul"
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
        VStack {
            ForEach(children, id: \.id) { child in
                HStack {
                    Circle()
                        .frame(width: 2, height: 2)
                    if let child = child as? String {
                        Text(child)
                            .textSelection(.enabled)
                    } else if let child = child as? (any BodyTagProtocol) {
                        AnyView(child.body)
                    }
                }
            }
        }
        .applyCommonCSS(ruleSet: style, tag: self)
    }

    static func parse(_ elem: Element, html: @escaping HTMLGetter) throws -> UlTag {
        try HTMLUtils.checkTag(elem, assert: "ul")
        let (attr, children) = Self.parseDefaultProps(elem, html: html)

        return UlTag(html: html, attr: attr, children: children)
    }
}
