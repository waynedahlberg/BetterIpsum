//
//  PreferencesView.swift
//  BetterIpsum
//
//  Created by Wayne Dahlberg on 1/1/26.
//

import SwiftUI

struct PreferencesView: View {
    @Environment(IpsumGeneratorService.self) private var generator
    @State private var isLoginEnabled: Bool = false

    var body: some View {
        Form {
            Section {
                Toggle("Launch at Login", isOn: $isLoginEnabled)
                    .onChange(of: isLoginEnabled) { _, newValue in
                        generator.launchAtLoginEnabled = newValue
                    }
            } footer: {
                Text("Keep BetterIpsum ready in your menu bar after every restart.")
                    .foregroundStyle(.secondary)
            }

            Section {
                Link("Support & Feedback",
                     destination: URL(string: "https://github.com/waynedahlberg/BetterIpsum/issues")!)
            }
        }
        .formStyle(.grouped)
        .frame(width: 256)
        .onAppear {
            isLoginEnabled = generator.launchAtLoginEnabled
        }
    }
}

