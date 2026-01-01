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
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
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
            .padding(20)
            
            Divider()
            
            // Footer (Preferences & Quit)
            HStack {
                Button("Preferences...") {
                    // We will implement a Settings scene later
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
            }
            .font(.callout)
            .padding(12)
            .background(Color.primary.opacity(0.03))
        }
    }
}
