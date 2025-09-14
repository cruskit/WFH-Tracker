import SwiftUI

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.blue)
                    .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            )
            .accessibilityAddTraits(.isButton)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.blue)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.blue, lineWidth: 2)
                    .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            )
            .accessibilityAddTraits(.isButton)
    }
}

struct ClearButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.red, lineWidth: 2)
                    .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            )
            .accessibilityAddTraits(.isButton)
            .accessibilityHint("Removes all entered work hours for this week")
    }
}

struct AdvancedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .foregroundStyle(.blue)
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.blue, lineWidth: 1)
                    .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            )
            .accessibilityAddTraits(.isButton)
            .accessibilityHint("Opens detailed entry for custom work hours")
    }
}