//
//  BodyTag.swift
//  NaviX
//
//  Created by Helloyunho on 6/3/24.
//

import Foundation
import SwiftSoup
import SwiftUI

final class BodyTag: TagProtocol {
    let html: HTMLTag
    let tagName = "body"
    let id = UUID()

    @Published var attr: [String: String] = [:] {
        didSet {
            NotificationCenter.default.postMain(
                name: .attrUpdated, object: self, userInfo: ["oldValue": oldValue])
        }
    }

    @Published var style = CSSRuleSet()

    @Published var children: [any Content] = [] {
        didSet {
            NotificationCenter.default.postMain(
                name: .childrenUpdated, object: self, userInfo: ["oldValue": oldValue as Any])
        }
    }

    init(html: HTMLTag, attr: [String: String], children: [any Content]) {
        self.html = html
        self.attr = attr
        self.children = children
    }

    func getStyle() async -> CSSRuleSet {
        let html = self.html
        var result = CSSRuleSet()
        for stylesheet in html.stylesheets {
            result += await stylesheet.findRuleset(for: self, html: html).reduce(result, +)
        }
        if let css = attr["style"], let ruleset = try? CSSRuleSet.parse(css) {
            result += ruleset
        }

        return result
    }

    static func parse(_ body: Element, html: HTMLTag) throws -> BodyTag {
        try HTMLUtils.checkTag(body, assert: "body")
        let attr = HTMLUtils.convertAttr(body.getAttributes())
        let children = HTMLUtils.parseBodyTags(body, html: html)
        return BodyTag(html: html, attr: attr, children: children)
    }
}

struct BodyTagView: View {
    @ObservedObject var tag: BodyTag

    var body: some View {
        Group {
            VStack(spacing: 10) {
                ForEach(tag.children, id: \.id) { child in
                    if let child = child as? String {
                        Text(child)
                            .textSelection(.enabled)
                    } else if let child = child as? (any BodyTagProtocol) {
                        HTMLUtils.getViewFromTags(child)
                    }
                }
            }
            .frame(alignment: .topLeading)
            .modifier(CSSRuleSet.CSSPaddingModifier(ruleSet: tag.style))
            .modifier(CSSRuleSet.CSSBackgroundColorModifier(ruleSet: tag.style))
            .modifier(CSSRuleSet.CSSBorderModifier(ruleSet: tag.style))
            .modifier(CSSRuleSet.CSSMarginModifier(ruleSet: tag.style))
            .modifier(CSSRuleSet.CSSOpacityModifier(ruleSet: tag.style))
        }
        .task {
            tag.style = await tag.getStyle()
        }
        .onChange(of: tag.attr) {
            Task {
                tag.style = await tag.getStyle()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .stylesheetsUpdated)) { _ in
            Task {
                tag.style = await tag.getStyle()
            }
        }
    }
}
