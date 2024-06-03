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

protocol Content {}

protocol TagProtocol: Equatable, Identifiable {
    var attr: [String: String] { get set }
    /**
     NOTE: This function should first check if the tag name matches with desired tag.
     */
    static func parse(_: Element) throws -> Self
}

extension String: Content {}

protocol HeadTagProtocol: TagProtocol {
    var children: String? { get set }
}

extension HeadTagProtocol {
    static func parseDefaultProps(_ elem: Element) -> ([String: String], String?) {
        let attr = HTMLUtils.convertAttr(elem.getAttributes())
        let children = try? elem.text()

        return (attr, children)
    }
}

protocol BodyTagProtocol: Content, TagProtocol {
    var children: [Content]? { get set }
    @ViewBuilder func toSwiftUI() -> any View
}

extension BodyTagProtocol {
    static func parseDefaultProps(_ elem: Element) -> ([String: String], [Content]?) {
        let attr = HTMLUtils.convertAttr(elem.getAttributes())
        let children = HTMLUtils.parseBodyTags(elem)

        return (attr, children)
    }
}
