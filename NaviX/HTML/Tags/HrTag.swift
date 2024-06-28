//
//  HrTag.swift
//  NaviX
//
//  Created by Helloyunho on 6/4/24.
//

import Foundation
import SwiftSoup
import SwiftUI

struct HrTag: BodyTagProtocol {
    let html: HTMLGetter
    let tagName = "hr"
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
        Divider()
            .frame(width: 0)
    }

    static func parse(_ elem: Element, html: @escaping HTMLGetter) throws -> HrTag {
        try HTMLUtils.checkTag(elem, assert: "hr")
        let (attr, children) = Self.parseDefaultProps(elem, html: html)

        return HrTag(html: html, attr: attr, children: children)
    }
}
