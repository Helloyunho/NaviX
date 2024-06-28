//
//  CSSRuleSet+Background.swift
//  NaviX
//
//  Created by Helloyunho on 6/5/24.
//

import Foundation
import SwiftUI
import Kroma

extension CSSRuleSet {
    var backgroundColor: Color? {
        if let backgroundColor = properties["background-color"] {
            return cssColorToSwiftUI(backgroundColor.first!)
        }
        return nil
    }
    
    struct CSSBackgroundColorModifier: ViewModifier {
        let backgroundColor: Color?
        
        init(_ backgroundColor: Color?) {
            self.backgroundColor = backgroundColor
        }
        
        init(ruleSet: CSSRuleSet) {
            self.init(ruleSet.backgroundColor)
        }
        
        func body(content: Self.Content) -> some View {
            if let backgroundColor {
                content.background(backgroundColor)
            } else {
                content
            }
        }
    }
}
