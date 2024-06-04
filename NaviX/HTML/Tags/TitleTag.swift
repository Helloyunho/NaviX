//
//  TitleTag.swift
//  NaviX
//
//  Created by Helloyunho on 6/3/24.
//

import Foundation
import SwiftSoup

struct TitleTag: HeadTagProtocol {
    let html: HTMLGetter
    let tagName = "title"
    let id = UUID()

    var attr: [String: String] = [:] {
        didSet {
            NotificationCenter.default.post(name: .attrUpdated, object: self, userInfo: ["oldValue": oldValue])
        }
    }

    var children: String = "" {
        didSet {
            NotificationCenter.default.post(name: .childrenUpdated, object: self, userInfo: ["oldValue": oldValue as Any])
        }
    }

    static func parse(_ title: Element, html: @escaping HTMLGetter) throws -> TitleTag {
        try HTMLUtils.checkTag(title, assert: "title")
        let (attr, children) = Self.parseDefaultProps(title)

        return TitleTag(html: html, attr: attr, children: children)
    }
}
