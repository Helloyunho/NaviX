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

final class ATag: BodyTagProtocol {
    let html: HTMLTag
    let tagName = "a"
    let id = UUID()

    @Published var attr: [String: String] = [:] {
        didSet {
            NotificationCenter.default.postMain(
                name: .attrUpdated, object: self, userInfo: ["oldValue": oldValue])
        }
    }

    var href: String? {
        attr["href"]
    }

    @Published var _children = [String]()

    var children: [any Content] {
        get {
            _children
        }
        set {
            let oldValue = _children
            _children = newValue.filter { $0 is String }.map { $0 as! String }
            NotificationCenter.default.postMain(
                name: .childrenUpdated, object: self, userInfo: ["oldValue": oldValue as Any])
        }
    }

    @Published var style = CSSRuleSet()

    init(html: HTMLTag, attr: [String: String], children: [any Content] = [any Content]()) {
        self.html = html
        self.attr = attr
        self.children = children
    }

    static func parse(_ elem: Element, html: HTMLTag) throws -> ATag {
        try HTMLUtils.checkTag(elem, assert: "a")
        let (attr, children) = Self.parseDefaultProps(elem, html: html)

        return ATag(html: html, attr: attr, children: children)
    }
}

struct ATagView: View {
    @ObservedObject var tag: ATag

    var body: some View {
        Group {
            Text(tag._children.joined(separator: " "))
                .textSelection(.enabled)
                .modifier(
                    CSSRuleSet.CSSFontModifier(
                        ruleSet: tag.style, defaultUnderline: .single, defaultUnderlineColor: .blue)
                )
                .modifier(CSSRuleSet.CSSColorModifier(tag.style.color ?? .blue))
                .modifier(CSSRuleSet.CSSPaddingModifier(ruleSet: tag.style))
                .modifier(CSSRuleSet.CSSBackgroundColorModifier(ruleSet: tag.style))
                .modifier(CSSRuleSet.CSSBorderModifier(ruleSet: tag.style))
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
                    if let href = tag.href {
                        NotificationCenter.default.postMain(
                            name: .changeURLRequested, object: tag, userInfo: ["url": href])
                    }
                    NotificationCenter.default.postMain(name: .onClick, object: tag, userInfo: nil)
                }
        }
        .modifier(CSSRuleSet.CSSMarginModifier(ruleSet: tag.style))
        .modifier(CSSRuleSet.CSSOpacityModifier(ruleSet: tag.style))
        .applyCommonListeners(tag: tag)
    }
}
