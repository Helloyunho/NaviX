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
    
    static func parseHeadTags(_ elem: Element, html: @escaping HTMLGetter) -> [any HeadTagProtocol] {
        var children = [any HeadTagProtocol]()
        for child in elem.children() {
            do {
                switch child.tagName().lowercased() {
                case "title":
                    try children.append(TitleTag.parse(child, html: html))
                case "script":
                    try children.append(ScriptTag.parse(child, html: html))
                case "link":
                    try children.append(LinkTag.parse(child, html: html))
                default:
                    break
                }
            } catch {
                print(error)
                // TODO: Log errors to warnings
            }
        }
        
        return children
    }
    
    static func parseBodyTags(_ elem: Element, html: @escaping HTMLGetter) -> [any Content] {
        var children = [any Content]()
        for child in elem.childNodesCopy() {
            if let str = child as? TextNode, !str.text().trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                children.append(str.text())
            } else if let child = child as? Element {
                do {
                    switch child.tagName().lowercased() {
                    case "div":
                        try children.append(DivTag.parse(child, html: html))
                    case "h1":
                        try children.append(H1Tag.parse(child, html: html))
                    case "h2":
                        try children.append(H2Tag.parse(child, html: html))
                    case "h3":
                        try children.append(H3Tag.parse(child, html: html))
                    case "h4":
                        try children.append(H4Tag.parse(child, html: html))
                    case "h5":
                        try children.append(H5Tag.parse(child, html: html))
                    case "h6":
                        try children.append(H6Tag.parse(child, html: html))
                    case "p":
                        try children.append(PTag.parse(child, html: html))
                    case "hr":
                        try children.append(HrTag.parse(child, html: html))
                    case "a":
                        try children.append(ATag.parse(child, html: html))
                    case "img":
                        try children.append(ImgTag.parse(child, html: html))
                    case "ol":
                        try children.append(OlTag.parse(child, html: html))
                    case "ul":
                        try children.append(UlTag.parse(child, html: html))
                    case "li":
                        try children.append(LiTag.parse(child, html: html))
                    case "input":
                        try children.append(InputTag.parse(child, html: html))
                    case "textarea":
                        try children.append(TextareaTag.parse(child, html: html))
                    case "button":
                        try children.append(ButtonTag.parse(child, html: html))
                    default:
                        break
                    }
                } catch {
                    print(error)
                    // TODO: Log errors to warnings
                }
            }
        }
        
        return children
    }
}
