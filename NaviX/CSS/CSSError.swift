//
//  CSSError.swift
//  NaviX
//
//  Created by Helloyunho on 6/4/24.
//

import Foundation

enum CSSError: Error {
    case unexpectedEOF
    case unexpectedToken(CSSPosition, CSSTokenType, CSSTokenType)
    case tokenEndWithoutStart
}
