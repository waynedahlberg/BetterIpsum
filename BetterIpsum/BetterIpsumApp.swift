//
//  BetterIpsumApp.swift
//  BetterIpsum
//
//  Created by Wayne Dahlberg on 12/31/25.
//

import SwiftUI

@main
struct BetterIpsumApp: App {
    
    @State private var generator = IpsumGeneratorService()
    
    var body: some Scene {
            MenuBarExtra("BetterIpsum", image: "menubar-icon") {
                MainPopoverView()
                    .environment(generator) // Use modern environment injection
                    .frame(width: 300)
            }
            .menuBarExtraStyle(.window)
        }
}
