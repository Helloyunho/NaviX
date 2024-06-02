//
//  Tab.swift
//  NaviX
//
//  Created by Helloyunho on 6/2/24.
//

import Foundation
import SwiftUI
import SwiftFetch

@MainActor
extension Binding where Value == Tab {

    func back() async {
        await wrappedValue.back()
    }
    
    func forward() async {
        await wrappedValue.forward()
    }
    
    func changeURL(url: URL) async {
        await wrappedValue.changeURL(url: url)
    }
    
    func load() async {
        await wrappedValue.load()
    }
}

struct Tab: Equatable {
    var history: [URL] = [URL(string: "https://github.com/face-hh/dingle-frontend/blob/main/index.html")!]
    var historyIndex = 0
    var url: URL {
        history[historyIndex]
    }
    var title = "Dingle"
    var body = ""
    var loading = false
    var error: Error? = nil

    static func == (lhs: Tab, rhs: Tab) -> Bool {
        lhs.history == rhs.history && lhs.historyIndex == rhs.historyIndex && lhs.title == rhs.title && lhs.body == rhs.body && lhs.loading == rhs.loading
    }

    mutating func back() async {
        guard historyIndex > 0 else { return }
        historyIndex -= 1
        await load()
    }

    mutating func forward() async {
        guard historyIndex < history.count - 1 else { return }
        historyIndex += 1
        await load()
    }

    mutating func changeURL(url: URL) async {
        history.removeSubrange(historyIndex + 1 ..< history.count)
        history.append(url)
        historyIndex += 1
        await load()
    }
    
    mutating func load() async {
        do {
            let resp = try await Request.fetch(url)
            body = try await resp.text()!
            error = nil
        } catch {
            self.error = error
        }
    }
}
