//
//  ButtonTag.swift
//  NaviX
//
//  Created by Helloyunho on 6/4/24.
//

import Foundation
import SwiftSoup
import SwiftUI

final class ButtonTag: BodyTagProtocol {
    let html: HTMLTag
    let tagName = "button"
    let id = UUID()

    @Published var attr: [String: String] = [:] {
        didSet {
            NotificationCenter.default.postMain(name: .attrUpdated, object: self, userInfo: ["oldValue": oldValue])
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
            NotificationCenter.default.postMain(name: .childrenUpdated, object: self, userInfo: ["oldValue": oldValue as Any])
        }
    }

    @Published var style = CSSRuleSet()

    init(html: HTMLTag, attr: [String : String], children: [any Content] = [any Content]()) {
        self.html = html
        self.attr = attr
        self.children = children
    }

    static func parse(_ elem: Element, html: HTMLTag) throws -> ButtonTag {
        try HTMLUtils.checkTag(elem, assert: "button")
        let (attr, children) = Self.parseDefaultProps(elem, html: html)

        return ButtonTag(html: html, attr: attr, children: children)
    }
}

private struct CSSButtonStyle: ButtonStyle {
    let style: CSSRuleSet
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .modifier(CSSRuleSet.CSSPaddingModifier(ruleSet: style))
            .modifier(CSSRuleSet.CSSBackgroundColorModifier(ruleSet: style))
            .modifier(CSSRuleSet.CSSBorderModifier(ruleSet: style))
    }
}

struct ButtonTagView: View {
    @ObservedObject var tag: ButtonTag

    var body: some View {
        Button {
            NotificationCenter.default.postMain(name: .onClick, object: tag)
        } label: {
            Text(tag._children.joined(separator: " "))
                .modifier(CSSRuleSet.CSSFontModifier(ruleSet: tag.style))
        }
        .buttonStyle(CSSButtonStyle(style: tag.style))
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
        .modifier(CSSRuleSet.CSSMarginModifier(ruleSet: tag.style))
        .modifier(CSSRuleSet.CSSOpacityModifier(ruleSet: tag.style))
        .applyCommonListeners(tag: tag)
    }
}
