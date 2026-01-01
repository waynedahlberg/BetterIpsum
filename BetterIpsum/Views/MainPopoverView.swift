//
//  MainPopoverView.swift
//  BetterIpsum
//
//  Created by Wayne Dahlberg on 12/31/25.
//

import SwiftUI

struct MainPopoverView: View {
    @Environment(IpsumGeneratorService.self) private var generator
    
    enum Screen {
        case main
        case preferences
    }
    
    @State private var currentScreen: Screen = .main
    @State private var hoverCount: Int = 0
    @State private var hoverUnit: String = "Ipsum length"
    
    var body: some View {
        ZStack {
            Group {
                if currentScreen == .main {
                    mainContent
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading),
                            removal: .move(edge: .trailing)
                        ))
                        .zIndex(1)
                } else {
                    preferencesContent
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                        .zIndex(2)
                }
            }
            .animation(.default, value: currentScreen)
            
            // Copied! Toast Overlay
            if currentScreen == .main && generator.showCopySuccess {
                copyToastOverlay
            }
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            // Header: Dynamic Action Label
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                // The Animated Integer
                Text("\(hoverCount)")
                    .font(.system(size: 18, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText()) // Optimizes for digit swapping
                
                // The Unit Label
                Text(hoverUnit)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: hoverCount)
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            Divider().padding(.top, 12).padding(.horizontal, 20)
            
            // Isolated Visual Length Sections
            VStack(spacing: 12) {
                // Section 1: Words (Small Dashes)
                WordSection(hoverCount: $hoverCount, hoverUnit: $hoverUnit) { count in
                                    generator.copyToClipboard(count: count, unit: "Words")
                                }
                                
                                SentenceSection(hoverCount: $hoverCount, hoverUnit: $hoverUnit) { count in
                                    generator.copyToClipboard(count: count, unit: "Sentences")
                                }
                                
                                ParagraphSection(hoverCount: $hoverCount, hoverUnit: $hoverUnit) { count in
                                    generator.copyToClipboard(count: count, unit: "Paragraphs")
                                }
            }
            .padding(20)
            
            Divider()
            
            footerSection
        }
    }
    
    private var footerSection: some View {
        HStack {
            Button("Preferences...") {
                withAnimation { currentScreen = .preferences }
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .onHover { isHovering in
                if isHovering { NSCursor.pointingHand.push() }
                else { NSCursor.pop() }
            }
            
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
    
    private var preferencesContent: some View {
        PreferencesView(generator: generator) {
            withAnimation { currentScreen = .main }
        }
    }
    
    private var copyToastOverlay: some View {
        VStack {
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                Text("Copied to Clipboard")
            }
            .font(.system(.subheadline, design: .rounded).bold())
            .padding(.horizontal, 16).padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.primary.opacity(0.1), lineWidth: 0.5))
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
            .padding(.bottom, 60)
        }
    }
}

// MARK: - Isolated Section Components

struct WordSection: View {
    @Binding var hoverCount: Int
    @Binding var hoverUnit: String
    let onSelect: (Int) -> Void
    @State private var hoveredIndex: Int? = nil

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 4) {
                ForEach(1...5, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(hoveredIndex != nil && index <= hoveredIndex! ? Color.blue.opacity(0.6) : Color.gray.opacity(0.4))
                        .frame(height: 12)
                }
            }
            .contentShape(Rectangle())
            .onContinuousHover { phase in
                switch phase {
                case .active(let location):
                    let itemWidth = geo.size.width / 5
                    let index = Int(location.x / itemWidth) + 1
                    let safeIndex = min(max(index, 1), 5)
                    
                    hoveredIndex = safeIndex
                    hoverCount = safeIndex * 1 // Custom multiplier for words
                    hoverUnit = safeIndex == 1 ? "Word" : "Words"
                case .ended:
                    hoveredIndex = nil
                    hoverCount = 0
                    hoverUnit = "Select length"
                }
            }
            .onTapGesture {
                if let index = hoveredIndex { onSelect(index * 5) }
            }
        }
        .frame(height: 12)
    }
}

struct SentenceSection: View {
    @Binding var hoverCount: Int
    @Binding var hoverUnit: String
    let onSelect: (Int) -> Void
    @State private var hoveredIndex: Int? = nil

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 4) {
                ForEach(1...5, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(hoveredIndex != nil && index <= hoveredIndex! ? Color.blue.opacity(0.6) : Color.gray.opacity(0.4))
                        .frame(maxWidth: .infinity)
                }
            }
            .contentShape(Rectangle()) // Gapless hover
            .onContinuousHover { phase in
                switch phase {
                case .active(let location):
                    let rowHeight = geo.size.height / 5
                    let index = Int(location.y / rowHeight) + 1
                    let safeIndex = min(max(index, 1), 5)
                    
                    hoveredIndex = safeIndex
                    hoverCount = safeIndex // Updates the monospaced digit
                    hoverUnit = safeIndex == 1 ? "Sentence" : "Sentences"
                case .ended:
                    hoveredIndex = nil
                    hoverCount = 0
                    hoverUnit = "Select length"
                }
            }
            .onTapGesture {
                if let index = hoveredIndex { onSelect(index) }
            }
        }
        .frame(height: 56) // 5 rows @ 8pt + 4 gaps @ 4pt
    }
}

struct ParagraphSection: View {
    @Binding var hoverCount: Int
    @Binding var hoverUnit: String
    let onSelect: (Int) -> Void
    @State private var hoveredIndex: Int? = nil

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 4) {
                ForEach(1...4, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(hoveredIndex != nil && index <= hoveredIndex! ? Color.blue.opacity(0.6) : Color.gray.opacity(0.4))
                        .frame(maxWidth: .infinity)
                }
            }
            .contentShape(Rectangle()) // Capture hover over gaps
            .onContinuousHover { phase in
                switch phase {
                case .active(let location):
                    // Logic: total height / number of rows
                    let rowHeight = geo.size.height / 4
                    let index = Int(location.y / rowHeight) + 1
                    let safeIndex = min(max(index, 1), 4)
                    
                    hoveredIndex = safeIndex
                    hoverCount = safeIndex
                    hoverUnit = safeIndex == 1 ? "Paragraph" : "Paragraphs"
                case .ended:
                    hoveredIndex = nil
                    hoverCount = 0
                    hoverUnit = "Select length"
                }
            }
            .onTapGesture {
                if let index = hoveredIndex { onSelect(index) }
            }
        }
        .frame(height: 108) // (4 rows * 24 height) + (3 gaps * 4 spacing)
    }
}
