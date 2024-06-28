//
//  ATag.swift
//  NaviX
//
//  Created by Helloyunho on 6/4/24.
//

import Foundation
import SwiftSoup
import SwiftUI

extension NSNotification.Name {
    static let changeURLRequested = NSNotification.Name("ChangeURLRequested")
}

struct ATag: BodyTagProtocol {
    let html: HTMLGetter
    let tagName = "a"
    let id = UUID()

    var attr: [String: String] = [:] {
        didSet {
            NotificationCenter.default.post(name: .attrUpdated, object: self, userInfo: ["oldValue": oldValue])
        }
    }
    
    var href: String? {
        attr["href"]
    }
    
    private var _children = [String]()

    var children: [any Content] {
        get {
            _children
        }
        set {
            let oldValue = _children
            _children = newValue.filter { $0 is String }.map { $0 as! String }
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
    
    init(html: @escaping HTMLGetter, attr: [String : String], children: [any Content] = [any Content]()) {
        self.html = html
        self.attr = attr
        self.children = children
    }

    var body: some View {
        Group {
            Text(_children.joined(separator: " "))
                .textSelection(.enabled)
                .modifier(CSSRuleSet.CSSFontModifier(ruleSet: style, defaultUnderline: .single, defaultUnderlineColor: .blue))
                .modifier(CSSRuleSet.CSSColorModifier(style.color ?? .blue))
                .modifier(CSSRuleSet.CSSPaddingModifier(ruleSet: style))
                .modifier(CSSRuleSet.CSSBackgroundColorModifier(ruleSet: style))
                .modifier(CSSRuleSet.CSSBorderModifier(ruleSet: style))
            #if os(macOS)
                .onHover { isHovered in
                    if isHovered {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
            #else
                .hoverEffect()
            #endif
                .onTapGesture {
                    if let href {
                        NotificationCenter.default.post(name: .changeURLRequested, object: self, userInfo: ["url": href])
                    }
                    NotificationCenter.default.post(name: .onClick, object: self, userInfo: nil)
                }
        }
        .modifier(CSSRuleSet.CSSMarginModifier(ruleSet: style))
        .modifier(CSSRuleSet.CSSOpacityModifier(ruleSet: style))
    }

    static func parse(_ elem: Element, html: @escaping HTMLGetter) throws -> ATag {
        try HTMLUtils.checkTag(elem, assert: "a")
        let (attr, children) = Self.parseDefaultProps(elem, html: html)

        return ATag(html: html, attr: attr, children: children)
    }
}
