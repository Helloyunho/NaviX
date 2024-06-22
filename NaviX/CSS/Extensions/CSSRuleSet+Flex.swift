//
//  CSSRuleSet+Flex.swift
//  NaviX
//
//  Created by Helloyunho on 6/5/24.
//

import Foundation

extension CSSRuleSet {
    enum Direction: String {
        case row
        case column
    }
    
    var direction: Direction? {
        if let direction = properties["direction"] {
            return Direction(rawValue: direction.first!)
        }
        return nil
    }
    
    enum Alignment: String {
        case fill
        case start
        case center
        case end
    }
    
    var alignItems: Alignment? {
        if let alignItems = properties["align-items"] {
            return Alignment(rawValue: alignItems.first!)
        }
        return nil
    }
    
    var rowGap: Int? {
        if let rowGap = properties["row-gap"] {
            return cssUnitToInt(rowGap.first!)
        } else if let gapProp = properties["gap"], let gap = cssSideUnitsToInt(gapProp) {
            return gap.0
        }
        return nil
    }
    
    var columnGap: Int? {
        if let columnGap = properties["column-gap"] {
            return cssUnitToInt(columnGap.first!)
        } else if let gapProp = properties["gap"], let gap = cssSideUnitsToInt(gapProp) {
            return gap.1
        }
        return nil
    }
    
    /**
     - (row, column)
     */
    var gap: (Int?, Int?) {
        var result: (Int?, Int?) = (nil, nil)
        
        if let rowGap {
            result.0 = rowGap
        }
        if let columnGap {
            result.1 = columnGap
        }
        
        return result
    }
    
    var wrap: Bool {
        return properties["wrap"]?.first == "wrap"
    }
}
