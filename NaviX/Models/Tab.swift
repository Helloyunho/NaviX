//
//  Tab.swift
//  NaviX
//
//  Created by Helloyunho on 6/2/24.
//

import Foundation
import SwiftFetch
import SwiftSoup
import SwiftUI

extension NSNotification.Name {
    static let historyUpdated = NSNotification.Name("historyUpdated")
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

struct Tab: Equatable, Hashable {
    let id = UUID()
    var history: [URL] = [URL(string: "buss://dingle.it")!]
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

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(history)
        hasher.combine(historyIndex)
        hasher.combine(title)
        hasher.combine(body)
        hasher.combine(tree)
        hasher.combine(loading)
    }

    mutating func back() async {
        guard historyIndex > 0 else { return }
        DispatchQueue.main.sync {
            historyIndex -= 1
        }
        await load()
    }

    mutating func forward() async {
        guard historyIndex < history.count - 1 else { return }
        DispatchQueue.main.sync {
            historyIndex += 1
        }
        await load()
    }

    mutating func changeURL(url: URL) async {
        DispatchQueue.main.sync {
            history.removeSubrange(historyIndex + 1..<history.count)
            history.append(url)
            historyIndex += 1
        }
        await load()
    }

    mutating func load() async {
        do {
            var url = url
            if !url.lastPathComponent.contains(".") {
                url.appendPathComponent("index.html")
            }
            let resp = try await Request.fetch(url)
            let body = try await resp.text()!
            DispatchQueue.main.sync {
                title = ""
                favicon = nil
                self.body = body
                error = nil
            }
            if let htmlTree = try? SwiftSoup.parse(body) {
                let tree = try await HTMLTag.parse(htmlTree)
                DispatchQueue.main.sync {
                    self.tree = tree
                }
            } else {
                DispatchQueue.main.sync {
                    tree = nil
                }
            }
        } catch {
            DispatchQueue.main.sync {
                self.error = error
            }
        }
    }
}
