//
//  BrowserView.swift
//  NaviX
//
//  Created by Helloyunho on 6/3/24.
//

import SwiftSoup
import SwiftUI

struct BrowserView: View {
    @EnvironmentObject var windowModel: WindowModel

    var body: some View {
        ScrollView {
            if let error = windowModel.tab.error {
                Text(error.localizedDescription)
                    .onAppear {
                        print(error)
                    }
            } else if windowModel.tab.tree == nil {
                Text(windowModel.tab.body)
                    .textSelection(.enabled)
            }
        }
        .onChange(of: windowModel.tab.tree) {
            processInitialHead()
        }
        .onReceive(NotificationCenter.default.publisher(for: .attrUpdated), perform: { notification in
            DispatchQueue.global(qos: .userInteractive).async {
                if let script = notification.object as? ScriptTag {
                    // TODO: update matching script execution
                } else if let link = notification.object as? LinkTag {
                    // TODO: update matching link execution
                    processLinkTag(link)
                } else if let title = notification.object as? TitleTag {
                    processTitleTag(title)
                }
            }
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func processLinkTag(_ tag: LinkTag) {
        if let href = tag.href, let url = URL(string: href, relativeTo: windowModel.tab.url) {
            if url.pathExtension == "css" {
                Task {
                    do {
                        if let cssString = try await Request.fetch(url).text() {
                            let stylesheet = try CSSStylesheet.parse(cssString)
                            await MainActor.run {
                                windowModel.tab.tree?.stylesheets.append(stylesheet)
                            }
                        }
                    } catch {
                        await MainActor.run {
                            windowModel.tab.error = error
                        }
                    }
                }
            } else if ["png", "jpg", "jpeg"].contains(url.pathExtension) {
                Task {
                    do {
                        let imageData = try await Request.fetch(url).data()
                        #if os(macOS)
                        let image = NSImage(data: imageData)
                        #else
                        let image = UIImage(data: imageData)
                        #endif

                        if let image {
                            #if os(macOS)
                            let swiftUIImage = Image(nsImage: image)
                            #else
                            let swiftUIImage = Image(uiImage: image)
                            #endif
                            await MainActor.run {
                                windowModel.tab.favicon = swiftUIImage
                            }
                        }
                    } catch {
                        await MainActor.run {
                            windowModel.tab.error = error
                        }
                    }
                }
            }
        }
    }

    func processTitleTag(_ tag: TitleTag) {
        DispatchQueue.main.async {
            windowModel.tab.title = tag.children
        }
    }

    func processInitialHead() {
        if let headChildren = windowModel.tab.tree?.head?.children {
            for tag in headChildren {
                if let script = tag as? ScriptTag {
                    // TODO: create script execution
                } else if let link = tag as? LinkTag {
                    processLinkTag(link)
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
