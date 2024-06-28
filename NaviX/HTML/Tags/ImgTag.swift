//
//  ImgTag.swift
//  NaviX
//
//  Created by Helloyunho on 6/4/24.
//

import Foundation
import SwiftSoup
import SwiftUI

struct ImgTag: BodyTagProtocol {
    let html: HTMLGetter
    let tagName = "img"
    let id = UUID()

    var attr: [String: String] = [:] {
        didSet {
            NotificationCenter.default.post(name: .attrUpdated, object: self, userInfo: ["oldValue": oldValue])
        }
    }
    
    var src: String? {
        attr["src"]
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
    
    init(html: @escaping HTMLGetter, attr: [String : String]) {
        self.html = html
        self.attr = attr
    }

    var body: some View {
        Group {
            if let src, let url = URL(string: src) {
                AsyncImage(url: url) { image in
                    image
                } placeholder: {
                    ProgressView()
                }
            } else {
                EmptyView()
            }
        }
        .applyCommonCSS(ruleSet: style, tag: self)
    }

    static func parse(_ elem: Element, html: @escaping HTMLGetter) throws -> ImgTag {
        try HTMLUtils.checkTag(elem, assert: "img")
        let (attr, children) = Self.parseDefaultProps(elem, html: html)

        return ImgTag(html: html, attr: attr)
    }
}
