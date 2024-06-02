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
        self.addTabPressed()
    }
    
    @objc func backwardAction(_ sender: Any) {
        self.backwardPressed()
    }
    
    @objc func forwardAction(_ sender: Any) {
        self.forwardPressed()
    }
}

struct ToolbarHooker: NSViewControllerRepresentable {
    
    let toolbar: NSToolbar
    
    func makeNSViewController(context: Context) -> DummyViewController {
        return DummyViewController(toolbar: toolbar)
    }
    
    func updateNSViewController(_ nsViewController: DummyViewController, context: Context) {
        
    }
    
    typealias NSViewControllerType = DummyViewController
    
    class DummyViewController: NSViewController {
        var toolbar: NSToolbar!
        
        init(toolbar: NSToolbar) {
            super.init(nibName: nil, bundle: nil)
            self.toolbar = toolbar
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidAppear() {
            if let window = self.view.window {
                window.toolbar = self.toolbar
                window.titleVisibility = .hidden
                window.toolbarStyle = .unified
            }
        }
    }
}
#endif
