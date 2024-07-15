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

@ViewBuilder func ContainerView<Content: View>(
    columnGap: Int = 0, rowGap: Int = 0, direction: CSSRuleSet.Direction = .column,
    alignItems: CSSRuleSet.Alignment = .fill, wrap: Bool = false,
    @ViewBuilder content: @escaping () -> Content
) -> some View {
    switch direction {
    case .row:
        if wrap {
            WrappingHStack(
                alignment: alignItems.toHorizontalAlignment().toAlignment(),
                horizontalSpacing: CGFloat(columnGap), verticalSpacing: CGFloat(rowGap)
            ) {
                content()
            }
            .frame(maxWidth: .infinity)
        } else {
            HStack(alignment: alignItems.toVerticalAlignment(), spacing: CGFloat(columnGap)) {
                content()
            }
            .frame(maxWidth: .infinity, alignment: alignItems.toHorizontalAlignment().toAlignment())
        }
    case .column:
        if wrap {
            WrappingVStack(
                alignment: alignItems.toVerticalAlignment().toAlignment(),
                verticalSpacing: CGFloat(rowGap), horizontalSpacing: CGFloat(columnGap)
            ) {
                content()
            }
            .frame(maxHeight: .infinity)
        } else {
            VStack(alignment: alignItems.toHorizontalAlignment(), spacing: CGFloat(rowGap)) {
                content()
            }
            .frame(maxHeight: .infinity, alignment: alignItems.toVerticalAlignment().toAlignment())
        }
    }
}
