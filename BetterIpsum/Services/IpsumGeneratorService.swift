//
//  IpsumGeneratorService.swift
//  BetterIpsum
//
//  Created by Wayne Dahlberg on 12/31/25.
//

import SwiftUI
import AppKit // Required for NSPasteboard

@Observable
class IpsumGeneratorService {
    var themes: [IpsumTheme] = []
    var selectedTheme: IpsumTheme?
    
    init() {
        loadLocalData()
    }
    
    private func loadLocalData() {
        // In a real app, you'd bundle a 'LoremData.json' file
        // For now, let's create a 'Classic' default to test the engine
        let classic = IpsumTheme(
            id: "classic",
            name: "Classic Latin",
            paragraphs: [
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                "Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                "Ut enim ad minim veniam, quis nostrud exercitation ullamco.",
                "Duis aute irure dolor in reprehenderit in voluptate velit esse.",
                "Excepteur sint occaecat cupidatat non proident, sunt in culpa."
            ]
        )
        self.themes = [classic]
        self.selectedTheme = classic
    }
    
    func copyToClipboard(count: Int, unit: String) {
        guard let theme = selectedTheme else { return }
        
        let generatedText: String
        
        switch unit {
        case "Paragraphs":
            // Take the requested number of paragraphs, looping if count > availability
            generatedText = (0..<count).map { theme.paragraphs[$0 % theme.paragraphs.count] }.joined(separator: "\n\n")
        
        case "Sentences":
            // For simplicity in this step, we'll treat paragraphs as sentences
            generatedText = (0..<count).map { theme.paragraphs[$0 % theme.paragraphs.count] }.joined(separator: " ")
            
        case "Words":
            // Split the first paragraph into words and take the count
            let allWords = theme.paragraphs[0].components(separatedBy: .whitespaces)
            generatedText = allWords.prefix(count).joined(separator: " ")
            
        default:
            generatedText = ""
        }
        
        // Use NSPasteboard as per PRD
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(generatedText, forType: .string)
        
        print("Copied to clipboard: \(generatedText)")
    }
}
