//
//  MainPopoverView.swift
//  BetterIpsum
//
//  Created by Wayne Dahlberg on 12/31/25.
//

import SwiftUI

struct MainPopoverView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Header / Content
            VStack(alignment: .leading, spacing: 16) {
                IpsumBarView(label: "Words", segmentCount: 5) { count in
                    print("Copying \(count) words...")
                }
                
                IpsumBarView(label: "Sentences", segmentCount: 5) { count in
                    print("Copying \(count) sentences...")
                }
                
                IpsumBarView(label: "Paragraphs", segmentCount: 5) { count in
                    print("Copying \(count) paragraphs...")
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
