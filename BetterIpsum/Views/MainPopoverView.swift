//
//  MainPopoverView.swift
//  BetterIpsum
//
//  Created by Wayne Dahlberg on 12/31/25.
//

import SwiftUI

struct MainPopoverView: View {
    @Environment(IpsumGeneratorService.self) private var generator
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Main Content Area
                VStack(alignment: .leading, spacing: 16) {
                    // Theme Selection Header
                    HStack {
                        Text("Theme")
                            .font(.system(.caption, design: .rounded).bold())
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Picker("", selection: Bindable(generator).selectedThemeID) {
                            ForEach(generator.themes) { theme in
                                Text(theme.name).tag(theme.id)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .fixedSize()
                    }
                    
                    Divider()
                    
                    // Visual Length Pickers
                    VStack(spacing: 12) {
                        IpsumBarView(label: "Words", segmentCount: 5) { count in
                            generator.copyToClipboard(count: count * 5, unit: "Words")
                        }
                        
                        IpsumBarView(label: "Sentences", segmentCount: 5) { count in
                            generator.copyToClipboard(count: count, unit: "Sentences")
                        }
                        
                        IpsumBarView(label: "Paragraphs", segmentCount: 5) { count in
                            generator.copyToClipboard(count: count, unit: "Paragraphs")
                        }
                    }
                }
                .padding(20)
                
                Divider()
                
                // Footer
                HStack {
                    Button("Preferences...") {
                        // Settings logic for Phase 4
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Button("Quit") {
                        NSApplication.shared.terminate(nil)
                    }
                    .buttonStyle(.plain)
                    .fontWeight(.medium)
                }
                .font(.system(.callout, design: .rounded))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.primary.opacity(0.03))
            }
            
            // "Copied!" Toast Overlay
            if generator.showCopySuccess {
                VStack {
                    Spacer()
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Copied to Clipboard")
                    }
                    .font(.system(.subheadline, design: .rounded).bold())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))
                    .padding(.bottom, 60)
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: generator.showCopySuccess)
    }
}
