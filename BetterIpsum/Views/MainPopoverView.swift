//
//  MainPopoverView.swift
//  BetterIpsum
//
//  Created by Wayne Dahlberg on 12/31/25.
//

import SwiftUI

struct MainPopoverView: View {
    @Environment(IpsumGeneratorService.self) private var generator
    @Environment(\.openSettings) private var openSettings

    enum ContentState: Equatable {
        case idle
        case hovering(section: String, count: Int)
        case copied(section: String, count: Int)

        var isCopied: Bool {
            if case .copied = self { return true }
            return false
        }

        var activeSection: String? {
            switch self {
            case .idle: return nil
            case .hovering(let s, _), .copied(let s, _): return s
            }
        }

        var activeCount: Int {
            switch self {
            case .idle: return 0
            case .hovering(_, let c), .copied(_, let c): return c
            }
        }
    }

    @State private var contentState: ContentState = .idle

    var body: some View {
        mainContent
    }

    // MARK: - Main Content

    private var mainContent: some View {
        VStack(spacing: 0) {
            titleArea
            Divider()
                .padding(.horizontal, 8)
            themePickerArea
            Divider()
                .padding(.horizontal, 8)
            sectionsArea
            Divider()
                .padding(.horizontal, 8)
            footerArea
        }
    }

    // MARK: - Title

    private var titleArea: some View {
        ZStack {
            if case .idle = contentState {
                Text("Choose placeholder length")
                    .font(.system(size: 19, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text("\(contentState.activeCount)")
                        .font(.system(size: 19, weight: .bold, design: .rounded).monospacedDigit())
                        .contentTransition(.numericText())
                    Text(unitLabel + (contentState.isCopied ? " copied!" : ""))
                        .font(.system(size: 19, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 32)
        .padding(.top, 16)
        .padding(.bottom, 16)
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: contentState)
    }

    // MARK: - Theme Picker

    private var themePickerArea: some View {
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
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var unitLabel: String {
        let count = contentState.activeCount
        switch contentState.activeSection {
        case "Words":      return count == 1 ? "word"      : "words"
        case "Sentences":  return count == 1 ? "sentence"  : "sentences"
        case "Paragraphs": return count == 1 ? "paragraph" : "paragraphs"
        default:           return ""
        }
    }

    // MARK: - Sections

    private var sectionsArea: some View {
        VStack(spacing: 16) {
            WordSection(
                contentState: contentState,
                onHover: { handleHover(section: "Words", index: $0) },
                onClick: { count in
                    generator.copyToClipboard(count: count, unit: "Words")
                    triggerCopied(section: "Words", count: count)
                }
            )

            SentenceSection(
                contentState: contentState,
                onHover: { handleHover(section: "Sentences", index: $0) },
                onClick: { count in
                    generator.copyToClipboard(count: count, unit: "Sentences")
                    triggerCopied(section: "Sentences", count: count)
                }
            )

            ParagraphSection(
                contentState: contentState,
                onHover: { handleHover(section: "Paragraphs", index: $0) },
                onClick: { count in
                    generator.copyToClipboard(count: count, unit: "Paragraphs")
                    triggerCopied(section: "Paragraphs", count: count)
                }
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
    }

    private func handleHover(section: String, index: Int?) {
        guard !contentState.isCopied else { return }
        if let index {
            withAnimation(.spring(response: 0.15)) {
                contentState = .hovering(section: section, count: index)
            }
        } else if case .hovering(let s, _) = contentState, s == section {
            withAnimation(.spring(response: 0.15)) {
                contentState = .idle
            }
        }
    }

    private func triggerCopied(section: String, count: Int) {
        withAnimation(.spring(response: 0.2)) {
            contentState = .copied(section: section, count: count)
        }
        Task {
            try? await Task.sleep(for: .seconds(2.5))
            await MainActor.run {
                if case .copied = contentState {
                    withAnimation(.spring(response: 0.3)) {
                        contentState = .idle
                    }
                }
            }
        }
    }

    // MARK: - Footer

    private var footerArea: some View {
        HStack {
            FooterIconButton(systemImage: "gearicon") {
                NSApp.activate(ignoringOtherApps: true)
                openSettings()
            }
            Spacer()
            FooterIconButton(systemImage: "powericon") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }
}

// MARK: - Footer Icon Button

struct FooterIconButton: View {
    let systemImage: String
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Image("\(systemImage)")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(isHovered ? Color.primary : Color.secondary.opacity(0.5))
                .frame(width: 24, height: 24)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isHovered ? Color(.secondarySystemFill).opacity(0.5) : .clear)
                )
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}

// MARK: - Word Section

struct WordSection: View {
    let contentState: MainPopoverView.ContentState
    let onHover: (Int?) -> Void
    let onClick: (Int) -> Void

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { index in
                    Capsule()
                        .fill(capsuleColor(for: index))
                        .frame(height: 12)
                        .animation(.spring(response: 0.15), value: contentState)
                }
            }
            .contentShape(Rectangle())
            .onContinuousHover { phase in
                switch phase {
                case .active(let location):
                    let safeIndex = min(max(Int(location.x / (geo.size.width / 5)) + 1, 1), 5)
                    onHover(safeIndex)
                case .ended:
                    onHover(nil)
                }
            }
            .onTapGesture {
                if case .hovering(let s, let c) = contentState, s == "Words" {
                    onClick(c)
                }
            }
        }
        .frame(height: 12)
    }

    private func capsuleColor(for index: Int) -> Color {
        switch contentState {
        case .hovering(let s, let c) where s == "Words" && index <= c:
            return .blue.opacity(1.0)
        case .copied(let s, let c) where s == "Words" && index <= c:
            return Color(.secondarySystemFill).opacity(0.75)
        default:
            return Color(.secondaryLabelColor).opacity(0.25)
        }
    }
}

// MARK: - Sentence Section

struct SentenceSection: View {
    let contentState: MainPopoverView.ContentState
    let onHover: (Int?) -> Void
    let onClick: (Int) -> Void

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 8) {
                ForEach(1...5, id: \.self) { index in
                    Capsule()
                        .fill(capsuleColor(for: index))
                        .frame(maxWidth: .infinity, minHeight: 12, maxHeight: 12)
                        .animation(.spring(response: 0.15), value: contentState)
                }
            }
            .contentShape(Rectangle())
            .onContinuousHover { phase in
                switch phase {
                case .active(let location):
                    let safeIndex = min(max(Int(location.y / (geo.size.height / 5)) + 1, 1), 5)
                    onHover(safeIndex)
                case .ended:
                    onHover(nil)
                }
            }
            .onTapGesture {
                if case .hovering(let s, let c) = contentState, s == "Sentences" {
                    onClick(c)
                }
            }
        }
        .frame(height: 92) // 5 * 12 + 4 * 8
    }

    private func capsuleColor(for index: Int) -> Color {
        switch contentState {
        case .hovering(let s, let c) where s == "Sentences" && index <= c:
            return .green.opacity(1.0)
        case .copied(let s, let c) where s == "Sentences" && index <= c:
            return Color(.secondarySystemFill).opacity(0.75)
        default:
            return Color(.secondaryLabelColor).opacity(0.25)
        }
    }
}

// MARK: - Paragraph Section

struct ParagraphSection: View {
    let contentState: MainPopoverView.ContentState
    let onHover: (Int?) -> Void
    let onClick: (Int) -> Void

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 8) {
                ForEach(1...5, id: \.self) { index in
                    Capsule()
                        .fill(capsuleColor(for: index))
                        .frame(maxWidth: .infinity, minHeight: 28, maxHeight: 28)
                        .animation(.spring(response: 0.15), value: contentState)
                }
            }
            .contentShape(Rectangle())
            .onContinuousHover { phase in
                switch phase {
                case .active(let location):
                    let safeIndex = min(max(Int(location.y / (geo.size.height / 5)) + 1, 1), 5)
                    onHover(safeIndex)
                case .ended:
                    onHover(nil)
                }
            }
            .onTapGesture {
                if case .hovering(let s, let c) = contentState, s == "Paragraphs" {
                    onClick(c)
                }
            }
        }
        .frame(height: 172) // 5 * 28 + 4 * 8
    }

    private func capsuleColor(for index: Int) -> Color {
        switch contentState {
        case .hovering(let s, let c) where s == "Paragraphs" && index <= c:
            return Color(red: 1.0, green: 0.18, blue: 0.49).opacity(1.0)
        case .copied(let s, let c) where s == "Paragraphs" && index <= c:
            return Color(.secondarySystemFill).opacity(0.75)
        default:
            return Color(.secondaryLabelColor).opacity(0.25)
        }
    }
}

// MARK: - Previews

#Preview("Default") {
    MainPopoverView()
        .environment(IpsumGeneratorService())
        .frame(width: 318)
}
