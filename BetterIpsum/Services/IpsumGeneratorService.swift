//
//  IpsumGeneratorService.swift
//  BetterIpsum
//
//  Created by Wayne Dahlberg on 12/31/25.
//

import SwiftUI
import AppKit
import Foundation
import ServiceManagement

/// The main logic engine for BetterIpsum.
/// Handles theme data loading, clipboard integration, and stubs for Apple Intelligence.
@Observable
class IpsumGeneratorService {
    // MARK: - Properties
    
    /// The full list of themes loaded from the bundled JSON
    var themes: [IpsumTheme] = []
    
    /// The currently selected theme ID, used for the UI Picker
    var selectedThemeID: String = ""
    
    /// AI Generation states
    var isGenerating = false
    var aiGeneratedText = ""
    
    /// Computed property to return the active theme object
    var selectedTheme: IpsumTheme? {
        themes.first { $0.id == selectedThemeID }
    }
    
    /// Checks if the system supports the FoundationModels framework (macOS 26+)
    var isAIReady: Bool {
        if #available(macOS 26.0, *) {
            return true
        }
        return false
    }
    
    var launchAtLoginEnabled: Bool {
        get {
            return SMAppService.mainApp.status == .enabled  // No init needed!
        }
        set {
            do {
                if newValue {
                    // Registers the main app bundle for launch at login
                    try SMAppService.mainApp.register()
                } else {
                    // Removes it from the login items list
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("SMAppService error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Initializer
    
    init() {
        loadThemesFromBundle()
    }
    
    // MARK: - Data Loading
    
    /// Loads the unified 'themes.json' from the app bundle
    private func loadThemesFromBundle() {
        let bundle = Bundle(for: IpsumGeneratorService.self) // not Bundle.main
        guard let url = bundle.url(forResource: "themes", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Error: themes.json not found in bundle.")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            // Decodes the root key "themes" into the array of IpsumTheme
            let wrapper = try decoder.decode([String: [IpsumTheme]].self, from: data)
            self.themes = wrapper["themes"] ?? []
            
            // Default to the first theme or an empty string if none exist
            self.selectedThemeID = themes.first?.id ?? ""
        } catch {
            print("Decoding error: \(error)")
        }
    }
    
    // MARK: - Clipboard Logic
    
    /// Processes and copies text to the system clipboard
    /// - Parameters:
    ///   - count: The number of units requested
    ///   - unit: "Words", "Sentences", or "Paragraphs"
    func copyToClipboard(count: Int, unit: String) {
        guard let theme = selectedTheme, !theme.paragraphs.isEmpty else { return }
        
        let resultText: String
        
        switch unit {
        case "Words":
            // Take a random paragraph and slice the required words
            let rawWords = theme.paragraphs.randomElement()?.components(separatedBy: .whitespacesAndNewlines) ?? []
            let cleanWords = rawWords.filter { !$0.isEmpty }
            resultText = cleanWords.prefix(count).joined(separator: " ")
            
        case "Sentences":
            // Flatten paragraphs into sentences and pick random ones
            let allText = theme.paragraphs.joined(separator: " ")
            let sentences = allText.components(separatedBy: CharacterSet(charactersIn: ".!?"))
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { $0.count > 10 } // Ensure it's a substantial sentence
            
            resultText = sentences.shuffled().prefix(count).joined(separator: ". ") + "."
            
        case "Paragraphs":
            // Select random whole paragraphs from the list
            resultText = theme.paragraphs.shuffled().prefix(count).joined(separator: "\n\n")
            
        default:
            resultText = ""
        }
        
        // Apply to NSPasteboard
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(resultText, forType: .string)
    }
    
    // MARK: - Future AI Stub
    
    /// Future implementation for macOS 26 (Tahoe)
    func generateCreativeIpsum(theme: String, count: Int, unit: String) async {
        guard isAIReady else { return }
        
        // This is a placeholder for the FoundationModels implementation
        await MainActor.run {
            self.isGenerating = true
            self.aiGeneratedText = "AI Generation is stubs for macOS 26 Tahoe."
            self.isGenerating = false
        }
    }
}

/// Preview static factory for richer mock states
/// Best practice - a `static var preview` on the service so we can test multiple states without building:
extension IpsumGeneratorService {
    static var preview: IpsumGeneratorService {
        let service = IpsumGeneratorService()
        // Override with hardcoded mock data so no bundle needed
        service.themes = [
            IpsumTheme(id: "lorem", name: "Lorem Ipsum", paragraphs: [
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor.",
                "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris."
            ])
        ]
        service.selectedThemeID = "lorem"
        return service
    }
    
}
