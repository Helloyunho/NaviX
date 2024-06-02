//
//  ContentView.swift
//  NaviX
//
//  Created by Helloyunho on 6/1/24.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State var tabs: [Tab] = [Tab()]
    @State var tabIndex = 0
    @State var addressBarContent = ""

    var body: some View {
        NavigationSplitView {
            List(tabs.indices, id: \.self, selection: $tabIndex) { idx in
                let tab = tabs[idx]
                Text(tab.title)
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
                                    rootView: TextField("Type URL...", text: $addressBarContent)
                                        .textFieldStyle(.roundedBorder)
                                        .onSubmit {
                                            tabs[tabIndex].changeURL(url: URL(string: addressBarContent)!)
                                        }
                                        .frame(idealWidth: 240)
                                )
                            ) {
                                tabs.append(Tab())
                            }
            )
        } detail: {
            Text(tabs[tabIndex].body)
        }
        .onChange(of: tabIndex) {
            addressBarContent = tabs[tabIndex].url.absoluteString
        }
        .onChange(of: tabs[tabIndex].url) {
            addressBarContent = tabs[tabIndex].url.absoluteString
        }
        .onChange(of: addressBarContent) {
            print(addressBarContent)
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
