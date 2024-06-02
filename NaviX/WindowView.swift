//
//  WindowView.swift
//  NaviX
//
//  Created by Helloyunho on 6/2/24.
//

import SwiftUI

struct WindowView: View {
    @StateObject var windowModel = WindowModel()
    var body: some View {
        ContentView()
            .environmentObject(windowModel)
    }
}

#Preview {
    WindowView()
}
