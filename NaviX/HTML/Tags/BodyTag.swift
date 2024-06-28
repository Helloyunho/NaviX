//
//  BodyTag.swift
//  NaviX
//
//  Created by Helloyunho on 6/3/24.
//

import Foundation
import SwiftSoup
import SwiftUI

struct BodyTag: TagProtocol, View {
    let html: HTMLGetter
    let tagName = "body"
    let id = UUID()

    var attr: [String: String] = [:] {
        didSet {
            NotificationCenter.default.post(name: .attrUpdated, object: self, userInfo: ["oldValue": oldValue])
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

    var children: [any Content] = [] {
        didSet {
            NotificationCenter.default.post(name: .childrenUpdated, object: self, userInfo: ["oldValue": oldValue as Any])
        }
    }
    
    @State private var reRender = false

    @ViewBuilder @MainActor @preconcurrency var body: some View {
        Group {
            VStack(spacing: 10) {
                ForEach(children, id: \.id) { child in
                    if let child = child as? String {
                        Text(child)
                            .textSelection(.enabled)
                    } else if let child = child as? (any BodyTagProtocol) {
                        AnyView(child.body)
                    }
                }
            }
            .frame(alignment: .topLeading)
            .modifier(CSSRuleSet.CSSPaddingModifier(ruleSet: style))
            .modifier(CSSRuleSet.CSSBackgroundColorModifier(ruleSet: style))
            .modifier(CSSRuleSet.CSSBorderModifier(ruleSet: style))
            .modifier(CSSRuleSet.CSSMarginModifier(ruleSet: style))
            .modifier(CSSRuleSet.CSSOpacityModifier(ruleSet: style))
        }
        .id(reRender)
        .onReceive(NotificationCenter.default.publisher(for: .stylesheetsUpdated)) { _ in
            // TODO: re-render only if the stylesheet is related to this tag
            DispatchQueue.main.async {
                reRender.toggle()
            }
        }
    }

    nonisolated static func parse(_ body: Element, html: @escaping HTMLGetter) throws -> BodyTag {
        try HTMLUtils.checkTag(body, assert: "body")
        let attr = HTMLUtils.convertAttr(body.getAttributes())
        let children = HTMLUtils.parseBodyTags(body, html: html)
        return BodyTag(html: html, attr: attr, children: children)
    }
}
