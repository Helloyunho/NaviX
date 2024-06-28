//
//  ContentView.swift
//  NaviX
//
//  Created by Helloyunho on 6/1/24.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var windowModel: WindowModel
    @State var addressBarContent = ""
    @Environment(\.dismissWindow) var dismissWindow
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationSplitView {
            List($windowModel.tabs.indices, id: \.self, selection: $windowModel.currentTabIndexOptional) { idx in
                let tab = windowModel.tabs[idx]
                HStack {
                    if tab.loading {
                        ProgressView().progressViewStyle(.circular).controlSize(.mini)
                    }
                    Label(title: {
                        Text(tab.title)
                    }, icon: {
                        if let favicon = tab.favicon {
                            favicon.resizable().aspectRatio(1, contentMode: .fit)
                        } else {
                            Image(systemName: "note")
                        }
                    })
                }
                .contextMenu {
                    Button {
                        if windowModel.tabs.count == 1 {
                            dismissWindow()
                        } else if windowModel.currentTabIndex == idx, idx == windowModel.tabs.count - 1 {
                            windowModel.currentTabIndex -= 1
                            windowModel.tabs.removeLast()
                        } else {
                            if windowModel.currentTabIndex == windowModel.tabs.count - 1 {
                                windowModel.currentTabIndex -= 1
                            }
                            windowModel.tabs.remove(at: idx)
                        }
                    } label: {
                        Label("Close", systemImage: "xmark.circle")
                    }
                    .keyboardShortcut("w", modifiers: .command)
                }
                .id(tab.id)
            }
#if os(iOS)
            .toolbar {
                Button(action: addTabPressed) {
                    Label("Add Tab", systemImage: "plus")
                }
            }
#endif
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
#if os(macOS)
            ToolbarHooker(toolbar:
                AddressToolbar(
                    identifier: NSToolbar.Identifier("MainToolbar"),
                    addressBarView: NSHostingView(
                        rootView: HStack {
                            if windowModel.tab.loading {
                                ProgressView().progressViewStyle(.circular).frame(maxWidth: .infinity)
                            }
                            TextField("Type URL...", text: $addressBarContent)
                                .textFieldStyle(.roundedBorder)
                                .onSubmit {
                                    onSubmitURL()
                                }
                                .frame(idealWidth: 240)
                        }
                    ),
                    enableBackwardButton: $windowModel.backwardEnabled,
                    enableForwardButton: $windowModel.forwardEnabled,
                    addTabPressed: addTabPressed,
                    backwardPressed: backwardPressed,
                    forwardPressed: forwardPressed
                )
            )
#endif
        } detail: {
#if os(macOS)
            BrowserView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
#endif
#if os(iOS)
            ToolbarHooker(container: SearchBarContainer(enableBackwardButton: $windowModel.backwardEnabled, enableForwardButton: $windowModel.forwardEnabled, textBinding: $addressBarContent, onSubmit: onSubmitURL, backwardPressed: backwardPressed, forwardPressed: forwardPressed), swiftUIView: BrowserView())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
#endif
        }
        .onChange(of: windowModel.currentTabIndex) {
            matchAddressBarContent()
        }
        .onChange(of: windowModel.tab.url) {
            matchAddressBarContent()
        }
        .onChange(of: windowModel.tab.historyIndex) {
            windowModel.forwardEnabled = windowModel.tab.historyIndex < windowModel.tab.history.count - 1
            windowModel.backwardEnabled = windowModel.tab.historyIndex > 0
        }
        .onAppear {
            matchAddressBarContent()
            windowModel.tab.loading = true
            Task {
                await $windowModel.tab.load()
                await MainActor.run {
                    windowModel.tab.loading = false
                }
            }
        }
#if os(macOS)
        .frame(minWidth: 600)
#endif
    }

    func matchAddressBarContent() {
        addressBarContent = windowModel.tab.url.absoluteString
    }

    func forwardPressed() {
        windowModel.tab.loading = true
        Task {
            await $windowModel.tab.forward()
            await MainActor.run {
                windowModel.tab.loading = false
            }
        }
    }

    func backwardPressed() {
        windowModel.tab.loading = true
        Task {
            await $windowModel.tab.back()
            await MainActor.run {
                windowModel.tab.loading = false
            }
        }
    }

    func addTabPressed() {
        windowModel.tabs.append(Tab())
        windowModel.currentTabIndex = windowModel.tabs.count - 1
        windowModel.tab.loading = true
        Task {
            await $windowModel.tab.load()
            await MainActor.run {
                windowModel.tab.loading = false
            }
        }
    }

    func onSubmitURL() {
        windowModel.tab.loading = true
        Task {
            await $windowModel.tab.changeURL(url: URL(string: addressBarContent)!)
            await MainActor.run {
                windowModel.tab.loading = false
            }
        }
    }
}

#Preview {
    WindowView()
}
