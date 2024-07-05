//
//  InputTag.swift
//  NaviX
//
//  Created by Helloyunho on 6/4/24.
//

import Foundation
import SwiftSoup
import SwiftUI

struct InputTag: InputTagProtocol {
    let html: HTMLGetter
    let tagName = "input"
    let id = UUID()

    var attr: [String: String] = [:] {
        didSet {
            NotificationCenter.default.post(name: .attrUpdated, object: self, userInfo: ["oldValue": oldValue])
        }
    }
    
    var type: String? {
        attr["type"]
    }
    
    var placeholder: String? {
        attr["placeholder"]
    }
    
    @State var content: String = ""
    
    private var _children = [String]()

    var children: [any Content] {
        get {
            _children
        }
        set {}
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
        Group {
            switch (type ?? "") {
            case "text":
                TextField(placeholder ?? "", text: $content)
                    .onSubmit {
                        NotificationCenter.default.post(name: .onSubmit, object: self, userInfo: ["content": content])
                    }
            default:
                EmptyView()
            }
        }
        .modifier(CSSRuleSet.CSSWidthModifier(ruleSet: style))
        .modifier(CSSRuleSet.CSSHeightModifier(ruleSet: style))
        .applyCommonCSS(ruleSet: style, tag: self)
    }

    static func parse(_ elem: Element, html: @escaping HTMLGetter) throws -> InputTag {
        try HTMLUtils.checkTag(elem, assert: "input")
        let (attr, children) = Self.parseDefaultProps(elem, html: html)

        return InputTag(html: html, attr: attr, children: children)
    }
}
