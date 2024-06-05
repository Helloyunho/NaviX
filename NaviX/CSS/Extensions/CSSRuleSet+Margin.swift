//
//  CSSRuleSet+Margin.swift
//  NaviX
//
//  Created by Helloyunho on 6/5/24.
//

import Foundation

extension CSSRuleSet {
    var marginTop: Int? {
        oneSideUnitToInt("margin", side: .top)
    }

    var marginRight: Int? {
        oneSideUnitToInt("margin", side: .right)
    }

    var marginBottom: Int? {
        oneSideUnitToInt("margin", side: .bottom)
    }

    var marginLeft: Int? {
        oneSideUnitToInt("margin", side: .left)
    }

    /**
     - (top, right, bottom, left)
     */
    var margin: (Int?, Int?, Int?, Int?) {
        var result: (Int?, Int?, Int?, Int?) = (nil, nil, nil, nil)

        if let marginTop {
            result.0 = marginTop
        }
        if let marginRight {
            result.1 = marginRight
        }
        if let marginBottom {
            result.2 = marginBottom
        }
        if let marginLeft {
            result.3 = marginLeft
        }

        return result
    }
}
