//
//  CSSToken.swift
//  NaviX
//
//  Created by Helloyunho on 6/4/24.
//

import Foundation

enum CSSTokenType {
    case identifier
    case lbracket
    case rbracket
    case colon
    case comment
    case commentMultiline
    case semi
    case comma
}

struct CSSToken {
    var type: CSSTokenType
    var value: String
    var start: CSSPosition
    var end: CSSPosition
    
    private static var tokenState = CSSTokenState()
    private static var value = ""
    private static var position = CSSPosition(line: 1, col: 1)
    private static var tokens: [CSSToken] = []
    private static var idx = 0
    
    private static func generateOneToken(_ char: String, type tokenType: CSSTokenType) {
        if let token = tokenState.end(endPos: position) {
            tokens.append(token)
        }
        tokenState.start(type: tokenType, startPos: position)
        tokenState.push(ch: char)
        position.col += 1
        tokens.append(tokenState.end(endPos: position)!)
        position.col -= 1
    }
    
    static func tokenize(_ css: String) throws -> [CSSToken] {
        let css = css.replacingOccurrences(of: "\r\n", with: "\n")
        tokenState = CSSTokenState()
        value = ""
        position = CSSPosition(line: 1, col: 1)
        tokens = []
        idx = 0
        while idx < css.count {
            let char = css[idx]
            if tokenState.type == .commentMultiline {
                if idx + 1 >= css.count {
                    throw CSSError.unexpectedEOF
                }
                if char + css[idx + 1] == "*/" {
                    position.col += 1
                    idx += 1
                    tokens.append(tokenState.end(endPos: position)!)
                } else {
                    if char == "\n" {
                        position.line += 1
                        position.col = 1
                    }
                    tokenState.value += char
                }
            } else if tokenState.type == .comment {
                if char == "\n" {
                    tokens.append(tokenState.end(endPos: position)!)
                    position.line += 1
                    position.col = 1
                } else {
                    tokenState.value += char
                }
            } else {
                if " \t".contains(char) {
                    if let token = tokenState.end(endPos: position) {
                        tokens.append(token)
                    }
                } else if char == "\n" {
                    if let token = tokenState.end(endPos: position) {
                        tokens.append(token)
                    }
                    position.line += 1
                    position.col = 1
                } else if char == "{" {
                    generateOneToken(char, type: .lbracket)
                } else if char == "}" {
                    generateOneToken(char, type: .rbracket)
                } else if char == ":" {
                    generateOneToken(char, type: .colon)
                } else if char == ";" {
                    generateOneToken(char, type: .semi)
                } else if char == "," {
                    generateOneToken(char, type: .comma)
                } else {
                    if tokenState.type != .identifier {
                        if let token = tokenState.end(endPos: position) {
                            tokens.append(token)
                        }
                        tokenState.start(type: .identifier, startPos: position)
                    }
                    tokenState.push(ch: char)
                }
            }
            position.col += 1
            idx += 1
        }
        
        if let token = tokenState.end(endPos: position) {
            tokens.append(token)
        }
        
        return tokens
    }
}

class CSSTokenState {
    var position = CSSPosition(line: 0, col: 0)
    var type: CSSTokenType?
    var value = ""
    
    func reset() {
        type = nil
        value = ""
        position.line = 0
        position.col = 0
    }
    
    func push(ch: String) {
        value += ch
    }
    
    func pos(_ pos: CSSPosition) {
        position = pos
    }
    
    func start(type: CSSTokenType, startPos: CSSPosition) {
        self.type = type
        pos(startPos)
        value = ""
    }
    
    func token(_ type: CSSTokenType, endPos: CSSPosition) -> CSSToken {
        let token = CSSToken(type: type, value: value, start: position, end: endPos)
        return token
    }
    
    func end(endPos: CSSPosition) -> CSSToken? {
        var result: CSSToken?
        if let type = type {
            result = token(type, endPos: endPos)
        }
        reset()
        return result
    }
}
