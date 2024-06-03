//
//  HTMLUtils.swift
//  NaviX
//
//  Created by Helloyunho on 6/3/24.
//

import Foundation
import SwiftSoup

class HTMLUtils {
    static func convertAttr(_ attrs: Attributes?) -> [String: String] {
        if let attrs {
            var result = [String: String]()
            for attr in attrs.makeIterator() {
                result[attr.getKey()] = attr.getValue()
            }
            return result
        } else {
            return [String: String]()
        }
    }
    
    static func checkTag(_ elem: Element, assert expected: String) throws {
        guard elem.tagName().lowercased() == expected else { throw ParseError.invalidTag }
    }
    
    static func parseHeadTags(_ elem: Element) -> [any HeadTagProtocol] {
        var children = [any HeadTagProtocol]()
        for child in elem.children() {
            do {
                switch child.tagName().lowercased() {
                case "title":
                    try children.append(TitleTag.parse(child))
                case "script":
                    try children.append(ScriptTag.parse(child))
                case "link":
                    try children.append(LinkTag.parse(child))
                default:
                    break
                }
            } catch {
                // TODO: Log errors to warnings
            }
        }
        
        return children
    }
    
    static func parseBodyTags(_ elem: Element) -> [any Content] {
        var children = [any Content]()
        for child in elem.childNodesCopy() {
            if let str = child as? TextNode {
                children.append(str.text())
            } else if let child = child as? Element {
                do {
                    switch child.tagName().lowercased() {
                    default:
                        break
                    }
                } catch {
                    // TODO: Log errors to warnings
                }
            }
        }
        
        return children
    }
}
