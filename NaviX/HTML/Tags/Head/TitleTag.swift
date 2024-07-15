//
//  TitleTag.swift
//  NaviX
//
//  Created by Helloyunho on 6/3/24.
//

import Foundation
import SwiftSoup

final class TitleTag: HeadTagProtocol {
    let html: HTMLTag
    let tagName = "title"
    let id = UUID()

    @Published var attr: [String: String] = [:] {
        didSet {
            NotificationCenter.default.postMain(
                name: .attrUpdated, object: self, userInfo: ["oldValue": oldValue])
        }
    }

    @Published var children: String = "" {
        didSet {
            NotificationCenter.default.postMain(
                name: .childrenUpdated, object: self, userInfo: ["oldValue": oldValue as Any])
        }
    }

    init(html: HTMLTag, attr: [String: String], children: String) {
        self.html = html
        self.attr = attr
        self.children = children
    }

    static func parse(_ title: Element, html: HTMLTag) throws -> TitleTag {
        try HTMLUtils.checkTag(title, assert: "title")
        let (attr, children) = Self.parseDefaultProps(title)

        return TitleTag(html: html, attr: attr, children: children)
    }
}
