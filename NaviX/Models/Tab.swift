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
    var historyIndex = 0
    var url: URL {
        history[historyIndex]
    }
    var title = "Dingle"
    var body = ""

    static func == (lhs: Tab, rhs: Tab) -> Bool {
        lhs.history == rhs.history && lhs.historyIndex == rhs.historyIndex && lhs.title == rhs.title && lhs.body == rhs.body
    }

    mutating func back() -> URL {
        guard historyIndex > 0 else { return history.first! }
        historyIndex -= 1
        return history[historyIndex]
    }

    mutating func forward() -> URL {
        guard historyIndex < history.count - 1 else { return history.last! }
        historyIndex += 1
        return history[historyIndex]
    }

    mutating func changeURL(url: URL) -> URL {
        history.removeSubrange(historyIndex + 1 ..< history.count)
        history.append(url)
        historyIndex += 1
        return url
    }
}
