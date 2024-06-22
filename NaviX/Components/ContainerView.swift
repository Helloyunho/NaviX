//
//  ContainerView.swift
//  NaviX
//
//  Created by Helloyunho on 6/22/24.
//

import SwiftUI
import WrappingStack

extension HorizontalAlignment {
    func toAlignment() -> Alignment {
        switch self {
        case .leading:
            return .topLeading
        case .center:
            return .center
        case .trailing:
            return .topTrailing
        default:
            return .topLeading
        }
    }
}
    
extension VerticalAlignment {
    func toAlignment() -> Alignment {
        switch self {
        case .top:
            return .topLeading
        case .center:
            return .center
        case .bottom:
            return .bottomLeading
        default:
            return .topLeading
        }
    }
}

struct ContainerView<Content: View>: View {
    let verticalAlignment: VerticalAlignment
    let horizontalAlignment: HorizontalAlignment
    let fillItems: Bool
    let columnGap: Int
    let rowGap: Int
    let direction: CSSRuleSet.Direction
    let wrap: Bool
    @ViewBuilder let content: () -> Content
    
    init(columnGap: Int = 0, rowGap: Int = 0, direction: CSSRuleSet.Direction = .row, alignItems: CSSRuleSet.Alignment = .fill, wrap: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.columnGap = columnGap
        self.rowGap = rowGap
        self.direction = direction
        self.wrap = wrap
        self.content = content
        switch alignItems {
        case .fill:
            self.fillItems = true
            self.verticalAlignment = .top
            self.horizontalAlignment = .leading
        case .start:
            self.fillItems = false
            self.verticalAlignment = .top
            self.horizontalAlignment = .leading
        case .center:
            self.fillItems = false
            self.verticalAlignment = .center
            self.horizontalAlignment = .center
        case .end:
            self.fillItems = false
            self.verticalAlignment = .bottom
            self.horizontalAlignment = .trailing
        }
    }
    
    var body: some View {
        switch direction {
        case .row:
            if wrap {
                WrappingHStack(alignment: horizontalAlignment.toAlignment(), horizontalSpacing: CGFloat(columnGap), verticalSpacing: CGFloat(rowGap)) {
                    content()
                }
                .frame(maxWidth: .infinity)
            } else {
                HStack(spacing: CGFloat(columnGap)) {
                    content()
                }
                .frame(maxWidth: .infinity, alignment: horizontalAlignment.toAlignment())
            }
        case .column:
            if wrap {
                WrappingVStack(alignment: verticalAlignment.toAlignment(), verticalSpacing: CGFloat(rowGap), horizontalSpacing: CGFloat(columnGap)) {
                    content()
                }
                .frame(maxHeight: .infinity)
            } else {
                VStack(spacing: CGFloat(rowGap)) {
                    content()
                }
                .frame(maxHeight: .infinity, alignment: verticalAlignment.toAlignment())
            }
        }
    }
}
