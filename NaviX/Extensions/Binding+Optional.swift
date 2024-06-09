//
//  Binding+Optional.swift
//  NaviX
//
//  Created by Helloyunho on 6/6/24.
//

import Foundation
import SwiftUI

extension Binding {
    func toOptional() -> Binding<Value?> {
        return Binding<Value?>(
            get: { self.wrappedValue },
            set: { newValue in
                if let value = newValue {
                    self.wrappedValue = value
                }
            }
        )
    }
}
