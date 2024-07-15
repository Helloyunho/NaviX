//
//  HTMLUtils.swift
//  NaviX
//
//  Created by Helloyunho on 6/3/24.
//

import Foundation
import SwiftSoup
import SwiftUI

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

    @MainActor
    static func parseHeadTags(_ elem: Element, html: HTMLTag) -> [any HeadTagProtocol] {
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

    @MainActor
    static func parseBodyTags(_ elem: Element, html: HTMLTag) -> [any Content] {
        var children = [any Content]()
        for child in elem.childNodesCopy() {
            if let str = child as? TextNode,
                !str.text().trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            {
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

    @MainActor
    static func getViewFromTags(_ tag: any BodyTagProtocol) -> AnyView {
        switch tag.tagName {
        case "div":
            AnyView(DivTagView(tag: tag as! DivTag))
        case "h1":
            AnyView(H1TagView(tag: tag as! H1Tag))
        case "h2":
            AnyView(H2TagView(tag: tag as! H2Tag))
        case "h3":
            AnyView(H3TagView(tag: tag as! H3Tag))
        case "h4":
            AnyView(H4TagView(tag: tag as! H4Tag))
        case "h5":
            AnyView(H5TagView(tag: tag as! H5Tag))
        case "h6":
            AnyView(H6TagView(tag: tag as! H6Tag))
        case "p":
            AnyView(PTagView(tag: tag as! PTag))
        case "hr":
            AnyView(HrTagView(tag: tag as! HrTag))
        case "a":
            AnyView(ATagView(tag: tag as! ATag))
        case "img":
            AnyView(ImgTagView(tag: tag as! ImgTag))
        case "ol":
            AnyView(OlTagView(tag: tag as! OlTag))
        case "ul":
            AnyView(UlTagView(tag: tag as! UlTag))
        case "li":
            AnyView(LiTagView(tag: tag as! LiTag))
        case "input":
            AnyView(InputTagView(tag: tag as! InputTag))
        case "textarea":
            AnyView(TextareaTagView(tag: tag as! TextareaTag))
        case "button":
            AnyView(ButtonTagView(tag: tag as! ButtonTag))
        default:
            AnyView(EmptyView())
        }
    }
}
