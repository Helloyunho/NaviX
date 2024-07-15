//
//  ImgTag.swift
//  NaviX
//
//  Created by Helloyunho on 6/4/24.
//

import Foundation
import SwiftSoup
import SwiftUI

final class ImgTag: BodyTagProtocol {
    let html: HTMLTag
    let tagName = "img"
    let id = UUID()

    @Published var attr: [String: String] = [:] {
        didSet {
            NotificationCenter.default.postMain(
                name: .attrUpdated, object: self, userInfo: ["oldValue": oldValue])
        }
    }

    var src: String? {
        attr["src"]
    }

    var children = [any Content]()

    @Published var style = CSSRuleSet()

    init(html: HTMLTag, attr: [String: String]) {
        self.html = html
        self.attr = attr
    }

    static func parse(_ elem: Element, html: HTMLTag) throws -> ImgTag {
        try HTMLUtils.checkTag(elem, assert: "img")
        let (attr, _) = Self.parseDefaultProps(elem, html: html)

        return ImgTag(html: html, attr: attr)
    }
}

struct ImgTagView: View {
    @ObservedObject var tag: ImgTag

    var body: some View {
        Group {
            if let src = tag.src, let url = URL(string: src) {
                AsyncImage(url: url) { image in
                    image
                } placeholder: {
                    ProgressView()
                }
            } else {
                EmptyView()
            }
        }
        .applyCommonCSS(ruleSet: tag.style, tag: tag)
        .applyCommonListeners(tag: tag)
    }
}
