//
//  DivTag.swift
//  NaviX
//
//  Created by Helloyunho on 6/4/24.
//

import Foundation
import SwiftSoup
import SwiftUI

struct DivTag: BodyTagProtocol {
    let html: HTMLGetter
    let tagName = "div"
    let id = UUID()

    var attr: [String: String] = [:] {
        didSet {
            NotificationCenter.default.post(name: .attrUpdated, object: self, userInfo: ["oldValue": oldValue])
        }
    }

    var children: [any Content] = [] {
        didSet {
            NotificationCenter.default.post(name: .childrenUpdated, object: self, userInfo: ["oldValue": oldValue as Any])
        }
    }

    var body: some View {
        VStack {
            ForEach(children, id: \.id) { child in
                if let child = child as? String {
                    Text(child)
                        .textSelection(.enabled)
                } else if let child = child as? (any BodyTagProtocol) {
                    AnyView(child)
                }
            }
        }
    }

    static func parse(_ div: Element, html: @escaping HTMLGetter) throws -> DivTag {
        try HTMLUtils.checkTag(div, assert: "div")
        let (attr, children) = Self.parseDefaultProps(div)

        return DivTag(html: html, attr: attr, children: children)
    }
}
