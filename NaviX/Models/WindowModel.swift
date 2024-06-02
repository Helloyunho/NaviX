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
    @Published var currentTabIndex = 0
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
