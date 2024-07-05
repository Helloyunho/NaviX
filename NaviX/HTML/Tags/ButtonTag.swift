//
//  ButtonTag.swift
//  NaviX
//
//  Created by Helloyunho on 6/4/24.
//

import Foundation
import SwiftSoup
import SwiftUI

struct ButtonTag: BodyTagProtocol {
    let html: HTMLGetter
    let tagName = "button"
    let id = UUID()

    var attr: [String: String] = [:] {
        didSet {
            NotificationCenter.default.post(name: .attrUpdated, object: self, userInfo: ["oldValue": oldValue])
        }
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
    
    struct CSSButtonStyle: ButtonStyle {
        let style: CSSRuleSet
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .modifier(CSSRuleSet.CSSPaddingModifier(ruleSet: style))
                .modifier(CSSRuleSet.CSSBackgroundColorModifier(ruleSet: style))
                .modifier(CSSRuleSet.CSSBorderModifier(ruleSet: style))
        }
    }

    var body: some View {
        Button {
            NotificationCenter.default.post(name: .onClick, object: self)
        } label: {
            Text(_children.joined(separator: " "))
                .modifier(CSSRuleSet.CSSFontModifier(ruleSet: style))
        }
        .buttonStyle(CSSButtonStyle(style: style))
        .modifier(CSSRuleSet.CSSMarginModifier(ruleSet: style))
        .modifier(CSSRuleSet.CSSOpacityModifier(ruleSet: style))
    }

    static func parse(_ elem: Element, html: @escaping HTMLGetter) throws -> ButtonTag {
        try HTMLUtils.checkTag(elem, assert: "button")
        let (attr, children) = Self.parseDefaultProps(elem, html: html)

        return ButtonTag(html: html, attr: attr, children: children)
    }
}
