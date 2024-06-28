//
//  CSSRuleSet+Margin.swift
//  NaviX
//
//  Created by Helloyunho on 6/5/24.
//

import Foundation
import SwiftUI

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
    
    struct CSSMarginModifier: ViewModifier {
        let margin: (Int?, Int?, Int?, Int?)
        
        init(_ margin: (Int?, Int?, Int?, Int?)) {
            self.margin = margin
        }
        
        init(ruleSet: CSSRuleSet) {
            self.init(ruleSet.margin)
        }
        
        func body(content: Self.Content) -> some View {
            let (top, right, bottom, left) = margin
            return content.padding(EdgeInsets(top: CGFloat(top ?? 0), leading: CGFloat(left ?? 0), bottom: CGFloat(bottom ?? 0), trailing: CGFloat(right ?? 0)))
        }
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
