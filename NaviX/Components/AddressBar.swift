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

class AddressToolbar: NSToolbar, NSToolbarDelegate {
    var addressBarView: NSView!
    
    init(identifier: NSToolbar.Identifier, addressBarView: NSView) {
        super.init(identifier: identifier)
        self.addressBarView = addressBarView
        self.delegate = self
        self.allowsUserCustomization = true
        self.displayMode = .default
        self.centeredItemIdentifier = NSToolbarItem.Identifier("AddressBar")
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)

        if itemIdentifier.rawValue == "AddressBar" {
            toolbarItem.label = "Address Bar"
            toolbarItem.view = addressBarView
        }

        return toolbarItem
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.toggleSidebar, .sidebarTrackingSeparator, .flexibleSpace, NSToolbarItem.Identifier("AddressBar"), .flexibleSpace]
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.toggleSidebar, .sidebarTrackingSeparator, .flexibleSpace, NSToolbarItem.Identifier("AddressBar"), .flexibleSpace]
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
