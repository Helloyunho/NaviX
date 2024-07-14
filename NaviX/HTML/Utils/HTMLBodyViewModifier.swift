//
//  HTMLBodyViewModifier.swift
//  NaviX
//
//  Created by Helloyunho on 7/14/24.
//

import SwiftUI

struct HTMLBodyViewModifier: ViewModifier {
    let tag: any BodyTagProtocol
    
    func body(content: Self.Content) -> some View {
        content
            .task {
                tag.style = await tag.getStyle()
            }
            .onChange(of: tag.attr) {
                Task {
                    tag.style = await tag.getStyle()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .stylesheetsUpdated)) {_ in
                Task {
                    tag.style = await tag.getStyle()
                }
            }
    }
}

extension View {
    func applyCommonListeners(tag: any BodyTagProtocol) -> some View {
        self.modifier(HTMLBodyViewModifier(tag: tag))
    }
}
