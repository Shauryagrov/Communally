//
//  Theme.swift
//  Communally
//
//  Created by Madhur Grover on 10/2/25.
//

import SwiftUI

struct CommunallyTheme {
    // Colors
    static let primaryGreen = Color(red: 0.7, green: 0.9, blue: 0.3) // Light lime green
    static let secondaryGreen = Color(red: 0.6, green: 0.8, blue: 0.2) // Slightly darker green
    static let accentGreen = Color(red: 0.5, green: 0.7, blue: 0.1) // Darker accent
    static let white = Color.white
    static let lightGray = Color(red: 0.95, green: 0.95, blue: 0.95)
    static let darkGray = Color(red: 0.3, green: 0.3, blue: 0.3)
    
    // Simple backgrounds (no gradients)
    static let backgroundGradient = white // Just use white background
    static let buttonGradient = primaryGreen // Just use solid green
    
    // Typography
    static let titleFont = Font.system(size: 28, weight: .bold, design: .rounded)
    static let subtitleFont = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let bodyFont = Font.system(size: 16, weight: .regular, design: .rounded)
    static let captionFont = Font.system(size: 14, weight: .medium, design: .rounded)
    static let labelFont = Font.system(size: 16, weight: .medium, design: .rounded)
    
    // Spacing
    static let padding: CGFloat = 20
    static let smallPadding: CGFloat = 12
    static let largePadding: CGFloat = 32
    static let cornerRadius: CGFloat = 12
    static let buttonHeight: CGFloat = 50
    
    // Button Styles
    static let primaryButtonStyle = PrimaryButtonStyle()
    static let secondaryButtonStyle = SecondaryButtonStyle()
    
    // Text Field Style
    static let textFieldStyle = CommunallyTextFieldStyle()
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(CommunallyTheme.bodyFont)
            .foregroundColor(.white)
            .padding()
            .frame(height: CommunallyTheme.buttonHeight)
            .background(CommunallyTheme.buttonGradient)
            .cornerRadius(CommunallyTheme.cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(CommunallyTheme.bodyFont)
            .foregroundColor(CommunallyTheme.darkGray)
            .padding()
            .frame(height: CommunallyTheme.buttonHeight)
            .background(CommunallyTheme.lightGray)
            .cornerRadius(CommunallyTheme.cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Text Field Style
struct CommunallyTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white)
            .cornerRadius(CommunallyTheme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: CommunallyTheme.cornerRadius)
                    .stroke(CommunallyTheme.lightGray, lineWidth: 1)
            )
    }
}
