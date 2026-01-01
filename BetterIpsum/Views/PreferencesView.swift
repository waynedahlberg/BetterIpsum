//
//  PreferencesView.swift
//  BetterIpsum
//
//  Created by Wayne Dahlberg on 1/1/26.
//

//
//  PreferencesView.swift
//

import SwiftUI

struct PreferencesView: View {
    let generator: IpsumGeneratorService
    let onDone: () -> Void  // New: callback to go back
    
    @State private var isLoginEnabled: Bool
    
    init(generator: IpsumGeneratorService, onDone: @escaping () -> Void = {}) {
        self.generator = generator
        self.onDone = onDone
        self._isLoginEnabled = State(initialValue: generator.launchAtLoginEnabled)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            Text("BetterIpsum Preferences")
                .font(.system(.headline, design: .rounded))
            
            Divider()
            
            // Launch at Login Toggle
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Start at Login:")
                        .fontWeight(.medium)
                    
                    Toggle("", isOn: $isLoginEnabled)
                        .labelsHidden()
                        .onChange(of: isLoginEnabled) { _, newValue in
                            generator.launchAtLoginEnabled = newValue
                        }
                }
                
                Text("Keep the app ready in your menu bar whenever you restart.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Support Section
            HStack {
                Spacer()
                Button(action: openSupportURL) {
                    Text("BetterIpsum Support...")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                Spacer()
            }
            
            Divider()
            
            // Done Button
            HStack {
                Spacer()
                Button("Done") {
                    withAnimation {
                        onDone()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
                .keyboardShortcut(.defaultAction)  // Optional: Enter/Return triggers Done
            }
        }
        .padding(24)
        .frame(width: 340)  // Slightly wider for comfort
        .onAppear {
            isLoginEnabled = generator.launchAtLoginEnabled
        }
    }
    
    private func openSupportURL() {
        if let url = URL(string: "https://github.com/waynedahlberg") {
            NSWorkspace.shared.open(url)
        }
    }
}
