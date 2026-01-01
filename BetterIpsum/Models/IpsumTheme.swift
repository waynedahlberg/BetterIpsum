//
//  IpsumTheme.swift
//  BetterIpsum
//
//  Created by Wayne Dahlberg on 12/31/25.
//

import Foundation

struct IpsumTheme : Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let paragraphs: [String]
}


