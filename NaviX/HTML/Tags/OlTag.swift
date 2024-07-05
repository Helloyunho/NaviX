//
//  OlTag.swift
//  NaviX
//
//  Created by Helloyunho on 6/4/24.
//

import Foundation
import SwiftSoup
import SwiftUI

struct OlTag: BodyTagProtocol {
    let html: HTMLGetter
    let tagName = "ol"
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
            ForEach(Array(children.enumerated()), id: \.1.id) { (number, child) in
                HStack {
                    Text("\(number + 1). ")
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

    static func parse(_ elem: Element, html: @escaping HTMLGetter) throws -> OlTag {
        try HTMLUtils.checkTag(elem, assert: "ol")
        let (attr, children) = Self.parseDefaultProps(elem, html: html)
        print(children)

        return OlTag(html: html, attr: attr, children: children)
    }
}
