//
//  CSSRuleSet+Padding.swift
//  NaviX
//
//  Created by Helloyunho on 6/5/24.
//

import Foundation

extension CSSRuleSet {
    var paddingTop: Int? {
        oneSideUnitToInt("padding", side: .top)
    }

    var paddingRight: Int? {
        oneSideUnitToInt("padding", side: .right)
    }

    var paddingBottom: Int? {
        oneSideUnitToInt("padding", side: .bottom)
    }

    var paddingLeft: Int? {
        oneSideUnitToInt("padding", side: .left)
    }

    /**
     - (top, right, bottom, left)
     */
    var padding: (Int?, Int?, Int?, Int?) {
        var result: (Int?, Int?, Int?, Int?) = (nil, nil, nil, nil)

        if let paddingTop {
            result.0 = paddingTop
        }
        if let paddingRight {
            result.1 = paddingRight
        }
        if let paddingBottom {
            result.2 = paddingBottom
        }
        if let paddingLeft {
            result.3 = paddingLeft
        }

        return result
    }
}
