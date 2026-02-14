import SwiftUI

// MARK: - Gradient Button
/// Premium-styled button with gradient background and press animation
struct GradientButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let action: () -> Void

    @State private var isPressed = false

    enum ButtonStyle {
        case primary    // Gradient fill
        case secondary  // Outline with gradient border
        case accent     // Cyan accent
    }

    init(_ title: String, icon: String? = nil, style: ButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: {
            HapticManager.impact()
            action()
        }) {
            HStack(spacing: DS.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .foregroundColor(foregroundColor)
            .background(backgroundView)
            .cornerRadius(DS.Radius.xl)
            .overlay(borderView)
        }
        .buttonStyle(PressButtonStyle())
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary:
            DS.Colors.primaryGradient
        case .secondary:
            Color.clear
        case .accent:
            DS.Colors.accent
        }
    }

    @ViewBuilder
    private var borderView: some View {
        switch style {
        case .secondary:
            RoundedRectangle(cornerRadius: DS.Radius.xl)
                .stroke(DS.Colors.primaryGradient, lineWidth: 2)
        default:
            EmptyView()
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return .white
        case .secondary: return DS.Colors.primaryPurple
        case .accent: return .black
        }
    }
}

// MARK: - Press Button Style
/// Custom button style with scale-down press effect
struct PressButtonStyle: SwiftUI.ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(DS.Anim.quick, value: configuration.isPressed)
    }
}

// MARK: - Small Text Button
struct TextButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    init(_ title: String, color: Color = DS.Colors.accent, action: @escaping () -> Void) {
        self.title = title
        self.color = color
        self.action = action
    }

    var body: some View {
        Button(action: {
            HapticManager.selection()
            action()
        }) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(color)
        }
    }
}
