//
//  Tab.swift
//  NaviX
//
//  Created by Helloyunho on 6/2/24.
//

import Foundation
import SwiftFetch
import SwiftUI
import SwiftSoup

extension NSNotification.Name {
    static let bodyChanged = NSNotification.Name("BodyChanged")
}

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
    let id = UUID()
    var history: [URL] = [URL(string: "https://github.com/face-hh/dingle-frontend/blob/main/index.html")!]
    var historyIndex = 0
    var url: URL {
        history[historyIndex]
    }

    var title = ""
    var body = ""
    var tree: HTMLTag? = nil
    var loading = false
    var error: Error? = nil
    var favicon: Image? = nil

    static func == (lhs: Tab, rhs: Tab) -> Bool {
        lhs.id == rhs.id
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
            title = ""
            favicon = nil
            body = try await resp.text()!
            error = nil
            if let htmlTree = try? SwiftSoup.parse(body) {
                let tree = try HTMLTag.parse(htmlTree)
                self.tree = tree
            } else {
                tree = nil
            }
        } catch {
            self.error = error
        }
    }
}
