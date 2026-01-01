//
//  BetterIpsumApp.swift
//  BetterIpsum
//
//  Created by Wayne Dahlberg on 12/31/25.
//

import SwiftUI

@main
struct BetterIpsumApp: App {
    var body: some Scene {
        MenuBarExtra("BetterIpsum", systemImage: "text.quote") {
            MainPopoverView()
                .frame(width: 300)
        }
        .menuBarExtraStyle(.window)
    }
}
