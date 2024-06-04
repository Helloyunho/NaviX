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

    var body: some View {
        NavigationSplitView {
            List(windowModel.tabs.indices, id: \.self, selection: $windowModel.currentTabIndex) { idx in
                let tab = windowModel.tabs[idx]
                HStack {
                    if tab.loading {
                        ProgressView().progressViewStyle(.circular).controlSize(.mini)
                    }
                    Label(title: {
                        Text(tab.title)
                    }, icon: {
                        if let favicon = tab.favicon {
                            favicon.resizable()
                        } else {
                            Image(systemName: "note")
                        }
                    })
                }
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
//                ToolbarItem(placement: .principal) {
//                    TextField("Type URL...", text: $addressBarContent).textFieldStyle(.roundedBorder).frame(idealWidth: 240)
//                }
            }
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
                                    Task {
                                        windowModel.tab.loading = true
                                        await $windowModel.tab.changeURL(url: URL(string: addressBarContent)!)
                                        windowModel.tab.loading = false
                                    }
                                }
                                .frame(idealWidth: 240)
                        }
                    ),
                    enableBackwardButton: $windowModel.backwardEnabled,
                    enableForwardButton: $windowModel.forwardEnabled,
                    addTabPressed: {
                        windowModel.tabs.append(Tab())
                    },
                    backwardPressed: {
                        Task {
                            windowModel.tab.loading = true
                            await $windowModel.tab.back()
                            windowModel.tab.loading = false
                        }
                    },
                    forwardPressed: {
                        Task {
                            windowModel.tab.loading = true
                            await $windowModel.tab.forward()
                            windowModel.tab.loading = false
                        }
                    }
                )
            )
        } detail: {
            BrowserView()
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
            Task {
                await $windowModel.tab.load()
            }
        }
        .frame(minWidth: 600)
    }

    func matchAddressBarContent() {
        addressBarContent = windowModel.tab.url.absoluteString
    }
}

#Preview {
    WindowView()
}
