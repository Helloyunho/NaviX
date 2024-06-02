//
//  Tab.swift
//  NaviX
//
//  Created by Helloyunho on 6/2/24.
//

import Foundation
import SwiftUI

struct Tab: Equatable {
    var history: [URL] = [URL(string: "https://github.com/face-hh/dingle-frontend")!]
    var currentIndex = 0
    var url: URL {
        history[currentIndex]
    }
    var title = "Dingle"
    var body = ""

    static func == (lhs: Tab, rhs: Tab) -> Bool {
        lhs.history == rhs.history && lhs.currentIndex == rhs.currentIndex && lhs.title == rhs.title && lhs.body == rhs.body
    }

    mutating func back() -> URL {
        guard currentIndex > 0 else { return history.first! }
        currentIndex -= 1
        return history[currentIndex]
    }

    mutating func forward() -> URL {
        guard currentIndex < history.count - 1 else { return history.last! }
        currentIndex += 1
        return history[currentIndex]
    }

    mutating func changeURL(url: URL) -> URL {
        history.removeSubrange(currentIndex + 1 ..< history.count)
        history.append(url)
        currentIndex += 1
        return url
    }
}
