//
//  WindowModel.swift
//  NaviX
//
//  Created by Helloyunho on 6/2/24.
//

import Foundation
import SwiftUI

class WindowModel: ObservableObject {
    @Published var tabs: [Tab] = [Tab()]
    @Published var currentTabIndex = 0 {
        didSet {
            if currentTabIndex != currentTabIndexOptional {
                currentTabIndexOptional = currentTabIndex
            }
        }
    }
    @Published var currentTabIndexOptional: Int? = 0 {
        didSet {
            if let currentTabIndexOptional, currentTabIndexOptional != currentTabIndex {
                currentTabIndex = currentTabIndexOptional
            }
        }
    }
    var tab: Tab {
        get {
            self.tabs[self.currentTabIndex]
        }
        set(value) {
            self.tabs[self.currentTabIndex] = value
        }
    }

    @Published var forwardEnabled = false
    @Published var backwardEnabled = false
}
