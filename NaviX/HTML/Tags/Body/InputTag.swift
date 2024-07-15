//
//  InputTag.swift
//  NaviX
//
//  Created by Helloyunho on 6/4/24.
//

import Foundation
import SwiftSoup
import SwiftUI

final class InputTag: InputTagProtocol {
    let html: HTMLTag
    let tagName = "input"
    let id = UUID()

    @Published var attr: [String: String] = [:] {
        didSet {
            NotificationCenter.default.postMain(
                name: .attrUpdated, object: self, userInfo: ["oldValue": oldValue])
        }
    }

    var type: String? {
        attr["type"]
    }

    var placeholder: String? {
        attr["placeholder"]
    }

    @Published var content: String = ""

    @Published var _children = [String]()

    var children: [any Content] {
        get {
            _children
        }
        set {}
    }

    @Published var style = CSSRuleSet()

    init(html: HTMLTag, attr: [String: String], children: [any Content] = [any Content]()) {
        self.html = html
        self.attr = attr
        self.children = children
    }

    static func parse(_ elem: Element, html: HTMLTag) throws -> InputTag {
        try HTMLUtils.checkTag(elem, assert: "input")
        let (attr, children) = Self.parseDefaultProps(elem, html: html)

        return InputTag(html: html, attr: attr, children: children)
    }
}

struct InputTagView: View {
    @ObservedObject var tag: InputTag

    var body: some View {
        Group {
            switch tag.type ?? "" {
            case "text":
                TextField(tag.placeholder ?? "", text: $tag.content)
                    .onSubmit {
                        NotificationCenter.default.postMain(
                            name: .onSubmit, object: tag, userInfo: ["content": tag.content])
                    }
            default:
                EmptyView()
            }
        }
        .modifier(CSSRuleSet.CSSWidthModifier(ruleSet: tag.style))
        .modifier(CSSRuleSet.CSSHeightModifier(ruleSet: tag.style))
        .applyCommonCSS(ruleSet: tag.style, tag: tag)
        .applyCommonListeners(tag: tag)
    }
}
