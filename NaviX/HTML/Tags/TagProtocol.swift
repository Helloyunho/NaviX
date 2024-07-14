//
//  TagProtocol.swift
//  NaviX
//
//  Created by Helloyunho on 6/3/24.
//

import Foundation
import SwiftSoup
import SwiftUI

extension NSNotification.Name {
    static let attrUpdated = NSNotification.Name("AttrUpdated")
    static let childrenUpdated = NSNotification.Name("ChildrenUpdated")
    static let onClick = NSNotification.Name("OnClick")
    static let onSubmit = NSNotification.Name("OnSubmit")
    static let stylesheetsUpdated = NSNotification.Name("StylesheetsUpdated")
}

protocol Content: Identifiable, Hashable, Sendable {
    var id: UUID { get }
}

@MainActor
protocol TagProtocol: Equatable, Identifiable, Hashable, Sendable, ObservableObject {
    nonisolated var id: UUID { get }
    var tagName: String { get }
    var attr: [String: String] { get set }
    var html: HTMLTag { get }
    /**
     NOTE: This function should first check if the tag name matches with desired tag.
     */
    static func parse(_: Element, html: HTMLTag) throws -> Self
}

extension TagProtocol {
    nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension String: @retroactive Identifiable {}
extension String: Content {
    public var id: UUID {
        UUID() // TODO: WE REALLY NEED A BETTER WAY TO GENERATE ID
    }
}

protocol HeadTagProtocol: TagProtocol {
    var children: String { get set }
}

extension HeadTagProtocol {
    static func parseDefaultProps(_ elem: Element) -> ([String: String], String) {
        let attr = HTMLUtils.convertAttr(elem.getAttributes())
        let children = try? elem.text()

        return (attr, children ?? "")
    }
}

protocol BodyTagProtocol: Content, TagProtocol {
    var children: [any Content] { get set }
    var style: CSSRuleSet { get set }
}

extension BodyTagProtocol {
    static func parseDefaultProps(_ elem: Element, html: HTMLTag) -> ([String: String], [any Content]) {
        let attr = HTMLUtils.convertAttr(elem.getAttributes())
        let children = HTMLUtils.parseBodyTags(elem, html: html)

        return (attr, children)
    }
    
    func getStyle() async -> CSSRuleSet {
        var result = CSSRuleSet()
        for stylesheet in html.stylesheets {
            result += await stylesheet.findRuleset(for: self, html: html).reduce(result, +)
        }
        if let css = attr["style"], let ruleset = try? CSSRuleSet.parse(css) {
            result += ruleset
        }

        return result
    }
}

protocol InputTagProtocol: BodyTagProtocol {
    var content: String { get set }
}
