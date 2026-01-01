//
//  IpsumBarView.swift
//  BetterIpsum
//
//  Created by Wayne Dahlberg on 12/31/25.
//

import SwiftUI

struct IpsumBarView: View {
    let label: String
    let segmentCount: Int
    let onSelect: (Int) -> Void
    
    @State private var hoveredIndex: Int? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
            
            HStack(spacing: 4) {
                ForEach(0..<segmentCount, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(fillColor(for: index))
                        .frame(height: 24)
                        .onHover { isHovering in
                            hoveredIndex = isHovering ? index : nil
                        }
                        .onTapGesture {
                            onSelect(index + 1) // +1 because index is 0-based
                        }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    // Logic: Highlight the bar if it's the one hovered OR to the left of the hovered one
    private func fillColor(for index: Int) -> Color {
        if let hovered = hoveredIndex, index <= hovered {
            return Color.blue.opacity(0.8)
        }
        return Color.primary.opacity(0.1)
    }
}
