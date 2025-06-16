import SwiftUI

class ThemeManager: ObservableObject {
    // Primary colors
    let primary = Color(red: 0, green: 0.8, blue: 0.7) // Mint/Teal
    let primaryVariant = Color(red: 0, green: 0.7, blue: 0.6)
    
    // Background colors
    let background = Color(red: 0.1, green: 0.11, blue: 0.12) // Dark background
    let surfaceBackground = Color(red: 0.15, green: 0.16, blue: 0.18)
    let elevatedBackground = Color(red: 0.2, green: 0.21, blue: 0.23)
    
    // Text colors
    let textPrimary = Color.white
    let textSecondary = Color(white: 0.7)
    
    // Status colors
    let success = Color.green
    let warning = Color.yellow
    let error = Color.red
    
    // Message bubble colors
    var userMessageBackground: Color { primaryVariant }
    var aiMessageBackground: Color { elevatedBackground }
    
    // Gradient
    var primaryGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [primary, primaryVariant]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Font styling
    let titleFont: Font = .system(.title, design: .rounded, weight: .semibold)
    let headlineFont: Font = .system(.headline, design: .rounded, weight: .semibold)
    let bodyFont: Font = .system(.body, design: .rounded)
    let captionFont: Font = .system(.caption, design: .rounded)
    
    // Animation duration
    let defaultAnimationDuration: Double = 0.3
}

// Extension to provide theme-based modifiers
extension View {
    func primaryButton(theme: ThemeManager) -> some View {
        self
            .font(theme.headlineFont)
            .foregroundColor(theme.textPrimary)
            .padding()
            .background(theme.primaryGradient)
            .cornerRadius(15)
    }
    
    func outlineButton(theme: ThemeManager) -> some View {
        self
            .font(theme.headlineFont)
            .foregroundColor(theme.primary)
            .padding()
            .background(Color.clear)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(theme.primary, lineWidth: 1.5)
            )
    }
    
    func cardStyle(theme: ThemeManager) -> some View {
        self
            .padding()
            .background(theme.surfaceBackground)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.2), radius: 4)
    }
}