//
//  TextareaTag.swift
//  NaviX
//
//  Created by Helloyunho on 6/4/24.
//

import Foundation
import SwiftSoup
import SwiftUI

final class TextareaTag: InputTagProtocol {
    let html: HTMLTag
    let tagName = "textarea"
    let id = UUID()

    @Published var attr: [String: String] = [:] {
        didSet {
            NotificationCenter.default.postMain(name: .attrUpdated, object: self, userInfo: ["oldValue": oldValue])
            
        }
    }
    
    @Published var content = ""
    
    @Published var _children = [String]() {
        didSet {
            content = _children.joined(separator: "\n")
        }
    }

    var children: [any Content] {
        get {
            _children
        }
        set {
            let oldValue = _children
            _children = newValue.filter { $0 is String }.map { $0 as! String }
            content = _children.joined(separator: "\n")
            NotificationCenter.default.postMain(name: .childrenUpdated, object: self, userInfo: ["oldValue": oldValue as Any])
        }
    }
    
    @Published var style = CSSRuleSet()
    
    init(html: HTMLTag, attr: [String : String], children: [any Content] = [any Content]()) {
        self.html = html
        self.attr = attr
        self.children = children
    }

    static func parse(_ elem: Element, html: HTMLTag) throws -> TextareaTag {
        try HTMLUtils.checkTag(elem, assert: "textarea")
        let (attr, children) = Self.parseDefaultProps(elem, html: html)

        return TextareaTag(html: html, attr: attr, children: children)
    }
}

struct TextareaTagView: View {
    @ObservedObject var tag: TextareaTag
    
    var body: some View {
        TextEditor(text: $tag.content)
            .modifier(CSSRuleSet.CSSWidthModifier(ruleSet: tag.style))
            .modifier(CSSRuleSet.CSSHeightModifier(ruleSet: tag.style))
            .applyCommonCSS(ruleSet: tag.style, tag: tag)
            .applyCommonListeners(tag: tag)
    }
}
