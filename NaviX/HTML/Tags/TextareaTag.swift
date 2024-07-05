//
//  TextareaTag.swift
//  NaviX
//
//  Created by Helloyunho on 6/4/24.
//

import Foundation
import SwiftSoup
import SwiftUI

struct TextareaTag: InputTagProtocol {
    let html: HTMLGetter
    let tagName = "textarea"
    let id = UUID()

    var attr: [String: String] = [:] {
        didSet {
            NotificationCenter.default.post(name: .attrUpdated, object: self, userInfo: ["oldValue": oldValue])
        }
    }
    
    @State var content = ""
    
    private var _children = [String]()

    var children: [any Content] {
        get {
            _children
        }
        set {
            let oldValue = _children
            _children = newValue.filter { $0 is String }.map { $0 as! String }
            content = _children.joined(separator: "\n")
            NotificationCenter.default.post(name: .childrenUpdated, object: self, userInfo: ["oldValue": oldValue as Any])
        }
    }
    
    var style: CSSRuleSet {
        CSSRuleSet()
    }
    
    init(html: @escaping HTMLGetter, attr: [String : String], children: [any Content] = [any Content]()) {
        self.html = html
        self.attr = attr
        self.children = children
    }

    var body: some View {
        TextEditor(text: $content)
            .modifier(CSSRuleSet.CSSWidthModifier(ruleSet: style))
            .modifier(CSSRuleSet.CSSHeightModifier(ruleSet: style))
            .applyCommonCSS(ruleSet: style, tag: self)
            .onAppear {
                content = _children.joined(separator: "\n")
            }
    }

    static func parse(_ elem: Element, html: @escaping HTMLGetter) throws -> TextareaTag {
        try HTMLUtils.checkTag(elem, assert: "textarea")
        let (attr, children) = Self.parseDefaultProps(elem, html: html)

        return TextareaTag(html: html, attr: attr, children: children)
    }
}
