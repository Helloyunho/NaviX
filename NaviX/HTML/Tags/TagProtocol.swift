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
}

protocol Content: Identifiable, Hashable {
    var id: UUID { get }
}

typealias HTMLGetter = () -> HTMLTag

protocol TagProtocol: Equatable, Identifiable, Hashable {
    var id: UUID { get }
    var tagName: String { get }
    var attr: [String: String] { get set }
    var html: HTMLGetter { get }
    /**
     NOTE: This function should first check if the tag name matches with desired tag.
     */
    static func parse(_: Element, html: @escaping HTMLGetter) throws -> Self
}

extension TagProtocol {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(tagName)
        hasher.combine(id)
        hasher.combine(attr)
    }
}

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

protocol BodyTagProtocol: Content, TagProtocol, View {
    var children: [any Content] { get set }
}

extension BodyTagProtocol {
    static func parseDefaultProps(_ elem: Element, html: @escaping HTMLGetter) -> ([String: String], [any Content]) {
        let attr = HTMLUtils.convertAttr(elem.getAttributes())
        let children = HTMLUtils.parseBodyTags(elem, html: html)

        return (attr, children)
    }
}
