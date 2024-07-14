//
//  OlTag.swift
//  NaviX
//
//  Created by Helloyunho on 6/4/24.
//

import Foundation
import SwiftSoup
import SwiftUI

final class OlTag: BodyTagProtocol {
    let html: HTMLTag
    let tagName = "ol"
    let id = UUID()

    @Published var attr: [String: String] = [:] {
        didSet {
            NotificationCenter.default.postMain(name: .attrUpdated, object: self, userInfo: ["oldValue": oldValue])
        }
    }

    @Published var children: [any Content] = [] {
        didSet {
            NotificationCenter.default.postMain(name: .childrenUpdated, object: self, userInfo: ["oldValue": oldValue as Any])
        }
    }
    
    @Published var style = CSSRuleSet()
    
    init(html: HTMLTag, attr: [String : String], children: [any Content]) {
        self.html = html
        self.attr = attr
        self.children = children
    }

    static func parse(_ elem: Element, html: HTMLTag) throws -> OlTag {
        try HTMLUtils.checkTag(elem, assert: "ol")
        let (attr, children) = Self.parseDefaultProps(elem, html: html)
        print(children)

        return OlTag(html: html, attr: attr, children: children)
    }
}

struct OlTagView: View {
    @ObservedObject var tag: OlTag
    
    var body: some View {
        VStack {
            ForEach(Array(tag.children.enumerated()), id: \.1.id) { (number, child) in
                HStack {
                    Text("\(number + 1). ")
                    if let child = child as? String {
                        Text(child)
                            .textSelection(.enabled)
                    } else if let child = child as? (any BodyTagProtocol) {
                        HTMLUtils.getViewFromTags(child)
                    }
                }
            }
        }
        .applyCommonCSS(ruleSet: tag.style, tag: tag)
        .applyCommonListeners(tag: tag)
    }
}
