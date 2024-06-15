//
//  AddressBar.swift
//  NaviX
//
//  Created by Helloyunho on 6/2/24.
//

import Foundation
import SwiftUI

#if os(macOS)
import AppKit

extension NSToolbarItem.Identifier {
    static let addressBar = NSToolbarItem.Identifier("AddressBar")
    static let addTab = NSToolbarItem.Identifier("AddTab")
    static let forward = NSToolbarItem.Identifier("Forward")
    static let backward = NSToolbarItem.Identifier("Backward")
}

class AddressToolbar: NSToolbar, NSToolbarDelegate, NSToolbarItemValidation {
    var addressBarView: NSView!
    var enableBackwardButton: Binding<Bool>!
    var enableForwardButton: Binding<Bool>!
    
    var addTabPressed: (() -> Void)!
    var backwardPressed: (() -> Void)!
    var forwardPressed: (() -> Void)!
    
    init(identifier: NSToolbar.Identifier, addressBarView: NSView, enableBackwardButton: Binding<Bool>, enableForwardButton: Binding<Bool>, addTabPressed: @escaping () -> Void, backwardPressed: @escaping () -> Void, forwardPressed: @escaping () -> Void) {
        super.init(identifier: identifier)
        self.addressBarView = addressBarView
        self.enableForwardButton = enableForwardButton
        self.enableBackwardButton = enableBackwardButton
        self.addTabPressed = addTabPressed
        self.backwardPressed = backwardPressed
        self.forwardPressed = forwardPressed
        self.delegate = self
        self.allowsUserCustomization = true
        self.displayMode = .default
        self.centeredItemIdentifier = .addressBar
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)

        if itemIdentifier == .addressBar {
            toolbarItem.label = "Address Bar"
            toolbarItem.view = addressBarView
        } else if itemIdentifier == .addTab {
            toolbarItem.label = "Add Tab"
            toolbarItem.image = NSImage(systemSymbolName: "plus", accessibilityDescription: "Add Tab")
            toolbarItem.action = #selector(addTabAction(_:))
            toolbarItem.target = self
            toolbarItem.isBordered = true
        } else if itemIdentifier == .forward {
            toolbarItem.label = "Forward"
            toolbarItem.image = NSImage(systemSymbolName: "chevron.right", accessibilityDescription: "Forward")
            toolbarItem.action = #selector(forwardAction(_:))
            toolbarItem.target = self
            toolbarItem.isBordered = true
        } else if itemIdentifier == .backward {
            toolbarItem.label = "Backward"
            toolbarItem.image = NSImage(systemSymbolName: "chevron.left", accessibilityDescription: "Backward")
            toolbarItem.action = #selector(backwardAction(_:))
            toolbarItem.target = self
            toolbarItem.isBordered = true
        }

        return toolbarItem
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.toggleSidebar, .flexibleSpace, .addTab, .sidebarTrackingSeparator, .backward, .forward, .flexibleSpace, .addressBar, .flexibleSpace]
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.toggleSidebar, .flexibleSpace, .addTab, .sidebarTrackingSeparator, .backward, .forward, .flexibleSpace, .addressBar, .flexibleSpace]
    }
    
    func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
        if item.itemIdentifier == .forward {
            return enableForwardButton.wrappedValue
        } else if item.itemIdentifier == .backward {
            return enableBackwardButton.wrappedValue
        }
        return true
    }
    
    @objc func addTabAction(_ sender: Any) {
        addTabPressed()
    }
    
    @objc func backwardAction(_ sender: Any) {
        backwardPressed()
    }
    
    @objc func forwardAction(_ sender: Any) {
        forwardPressed()
    }
}

struct ToolbarHooker: NSViewControllerRepresentable {
    let toolbar: NSToolbar
    
    func makeNSViewController(context: Context) -> DummyViewController {
        return DummyViewController(toolbar: toolbar)
    }
    
    func updateNSViewController(_ nsViewController: DummyViewController, context: Context) {}
    
    class DummyViewController: NSViewController {
        var toolbar: NSToolbar!
        
        init(toolbar: NSToolbar) {
            super.init(nibName: nil, bundle: nil)
            self.toolbar = toolbar
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidAppear() {
            if let window = view.window {
                window.toolbar = toolbar
                window.titleVisibility = .hidden
                window.toolbarStyle = .unified
            }
        }
    }
}
#endif
#if os(iOS)
import UIKit

class SearchBarContainer {
    var enableBackwardButton: Binding<Bool>!
    var enableForwardButton: Binding<Bool>!
    var textBinding: Binding<String>!
    
    var onSubmit: (() -> Void)!
    var backwardPressed: (() -> Void)!
    var forwardPressed: (() -> Void)!
    
    init(enableBackwardButton: Binding<Bool>, enableForwardButton: Binding<Bool>, textBinding: Binding<String>, onSubmit: @escaping () -> Void, backwardPressed: @escaping () -> Void, forwardPressed: @escaping () -> Void) {
        self.enableForwardButton = enableForwardButton
        self.enableBackwardButton = enableBackwardButton
        self.textBinding = textBinding
        self.onSubmit = onSubmit
        self.backwardPressed = backwardPressed
        self.forwardPressed = forwardPressed
    }
    
    @objc func backwardAction(_ sender: Any) {
        backwardPressed()
    }
    
    @objc func forwardAction(_ sender: Any) {
        forwardPressed()
    }
}

struct ToolbarHooker<V: View>: UIViewControllerRepresentable {
    let container: SearchBarContainer
    let swiftUIView: V
    
    func makeUIViewController(context: Context) -> DummyViewController<V> {
        return DummyViewController(rootView: swiftUIView, container: container)
    }
    
    func updateUIViewController(_ uiViewController: DummyViewController<V>, context: Context) {}
    
    class DummyViewController<V_: View>: UIHostingController<V_>, UISearchBarDelegate {
        var container: SearchBarContainer!
        var searchController: UISearchController!
        var backwardButton: UIBarButtonItem!
        var forwardButton: UIBarButtonItem!

        init(rootView: V_, container: SearchBarContainer) {
            super.init(rootView: rootView)
            self.container = container
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            if let navigationController {
                let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
                backwardButton = UIBarButtonItem(title: "Back", image: UIImage(systemName: "chevron.left"), target: container, action: #selector(container.backwardAction(_:)))
                forwardButton = UIBarButtonItem(title: "Forward", image: UIImage(systemName: "chevron.right"), target: container, action: #selector(container.forwardAction(_:)))
                toolbarItems = [
                    backwardButton,
                    flexibleSpace,
                    forwardButton,
                    flexibleSpace,
                    flexibleSpace,
                    flexibleSpace,
                    UIBarButtonItem(title: "Tabs", image: UIImage(systemName: "square.grid.2x2"), target: self, action: #selector(goBackToTabListPressed))
                ]
                navigationController.isToolbarHidden = false
                navigationController.toolbar.setItems(toolbarItems, animated: false)
                let bar = navigationController.navigationBar
                searchController = UISearchController(searchResultsController: nil)
                searchController.searchBar.placeholder = "Type URL"
                searchController.searchBar.delegate = self
                searchController.searchBar.text = container.textBinding.wrappedValue
                searchController.searchBar.autocorrectionType = .no
                searchController.searchBar.autocapitalizationType = .none
                searchController.hidesNavigationBarDuringPresentation = false
                searchController.searchBar.translatesAutoresizingMaskIntoConstraints = false

                bar.topItem?.titleView = UIView(frame: CGRect(x: 0, y: 0, width: bar.frame.width, height: 44))
                bar.topItem?.titleView?.addSubview(searchController.searchBar)

                NSLayoutConstraint.activate([
                    searchController.searchBar.leadingAnchor.constraint(equalTo: bar.topItem!.titleView!.leadingAnchor),
                    searchController.searchBar.trailingAnchor.constraint(equalTo: bar.topItem!.titleView!.trailingAnchor),
                    searchController.searchBar.topAnchor.constraint(equalTo: bar.topItem!.titleView!.topAnchor),
                    searchController.searchBar.bottomAnchor.constraint(equalTo: bar.topItem!.titleView!.bottomAnchor)
                ])
                
                bar.topItem?.largeTitleDisplayMode = .never
                bar.topItem?.hidesBackButton = true
                bar.topItem?.hidesSearchBarWhenScrolling = false
            }
        }
        
        @objc func goBackToTabListPressed() {
            if let navigationController {
                navigationController.popViewController(animated: true)
            }
        }
        
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchBar.setShowsCancelButton(true, animated: true)
        }

        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            searchController.searchBar.text = container.textBinding.wrappedValue
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.setShowsCancelButton(false, animated: true)
            container.onSubmit()
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.setShowsCancelButton(false, animated: true)
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            container.textBinding.wrappedValue = searchText
            container.textBinding.update()
        }
    }
}
#endif
