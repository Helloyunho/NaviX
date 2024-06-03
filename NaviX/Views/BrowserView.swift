//
//  BrowserView.swift
//  NaviX
//
//  Created by Helloyunho on 6/3/24.
//

import SwiftUI
import SwiftSoup

struct BrowserView: View {
    @EnvironmentObject var windowModel: WindowModel
    @State var tree: HTMLTag? = nil

    var body: some View {
        ScrollView {
            if let error = windowModel.tab.error {
                Text(error.localizedDescription)
            } else if tree == nil {
                Text(windowModel.tab.body)
                    .textSelection(.enabled)
            }
        }
        .task {
            readBody()
        }
        .onChange(of: windowModel.tab.body) {
            readBody()
        }
        .onReceive(NotificationCenter.default.publisher(for: .attrUpdated), perform: { notification in
            if let script = notification.object as? ScriptTag {
                // TODO: update matching script execution
            } else if let link = notification.object as? LinkTag {
                // TODO: update matching link execution
            } else if let title = notification.object as? TitleTag {
                processTitleTag(title)
            }
        })
    }

    func readBody() {
        do {
            if let htmlTree = try? SwiftSoup.parse(windowModel.tab.body) {
                var tree = try HTMLTag.parse(htmlTree)
                self.tree = tree
                processInitialHead()
            }
        } catch {
            windowModel.tab.error = error
        }
    }
    
    func processTitleTag(_ tag: TitleTag) {
        windowModel.tab.title = tag.children ?? ""
    }
    
    func processInitialHead() {
        if let headChildren = tree?.head.children {
            for tag in headChildren {
                if let script = tag as? ScriptTag {
                    // TODO: create script execution
                } else if let link = tag as? LinkTag {
                    // TODO: read link tags
                } else if let title = tag as? TitleTag {
                    processTitleTag(title)
                }
            }
        }
    }
}

#Preview {
    WindowView()
}
