//
//  Color+Extensions.swift
//  HabitTracker
//
//  Created by Krishna pradhan on 2026-05-15.
//

import SwiftUI

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        
        guard Scanner(string: hex).scanHexInt64(&int) else {
            return nil
        }
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        return String(format: "%02lX%02lX%02lX",
                     lroundf(r * 255),
                     lroundf(g * 255),
                     lroundf(b * 255))
    }
    
    static let habitColors: [Color] = [
        Color(hex: "E74C3C")!, // Red
        Color(hex: "9B59B6")!, // Purple
        Color(hex: "3498DB")!, // Blue
        Color(hex: "1ABC9C")!, // Turquoise
        Color(hex: "2ECC71")!, // Green
        Color(hex: "F39C12")!, // Orange
        Color(hex: "E67E22")!, // Carrot
        Color(hex: "34495E")!, // Dark Gray
        Color(hex: "FF6B9D")!, // Pink
        Color(hex: "95E1D3")!, // Mint
    ]
}
