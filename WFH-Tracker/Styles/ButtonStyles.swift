import SwiftUI

// MARK: - Breeze Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .heavy))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                LinearGradient.breezeBrandGrad
                    .clipShape(Capsule())
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
            .breezeShadowBrand()
            .accessibilityAddTraits(.isButton)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .heavy))
            .foregroundStyle(Color.breezeBrandInk)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                Capsule()
                    .fill(Color.breezeSurface)
                    .overlay(Capsule().strokeBorder(Color.breezeLineStrong, lineWidth: 1.5))
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
            .breezeShadowSm()
            .accessibilityAddTraits(.isButton)
    }
}

struct ClearButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .heavy))
            .foregroundStyle(Color.breezeInkMuted)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
            .accessibilityAddTraits(.isButton)
            .accessibilityHint("Removes all entered work hours for this week")
    }
}

struct AdvancedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .heavy))
            .foregroundStyle(Color.breezeBrandInk)
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(Color.breezeBrandSoft)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .accessibilityAddTraits(.isButton)
            .accessibilityHint("Opens detailed entry for custom work hours")
    }
}
