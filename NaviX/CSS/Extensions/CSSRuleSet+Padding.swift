//
//  CSSRuleSet+Padding.swift
//  NaviX
//
//  Created by Helloyunho on 6/5/24.
//

import Foundation
import SwiftUI

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

    struct CSSPaddingModifier: ViewModifier {
        let _padding: (Int?, Int?, Int?, Int?)

        init(_ padding: (Int?, Int?, Int?, Int?)) {
            self._padding = padding
        }

        init(ruleSet: CSSRuleSet) {
            self.init(ruleSet.padding)
        }

        func body(content: Self.Content) -> some View {
            let (top, right, bottom, left) = _padding
            return content.padding(
                EdgeInsets(
                    top: CGFloat(top ?? 0), leading: CGFloat(left ?? 0),
                    bottom: CGFloat(bottom ?? 0), trailing: CGFloat(right ?? 0)))
        }
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
