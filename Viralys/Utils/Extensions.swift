import SwiftUI

// MARK: - Color Hex Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Modifiers
extension View {
    /// Applies dark card styling with shadow
    func cardStyle() -> some View {
        self
            .background(DS.Colors.card)
            .cornerRadius(DS.Radius.lg)
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
    }

    /// Applies glassmorphism effect
    func glassmorphism() -> some View {
        self
            .background(.ultraThinMaterial)
            .cornerRadius(DS.Radius.lg)
    }

    /// Adds a gradient border to a view
    func gradientBorder(lineWidth: CGFloat = 1) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: DS.Radius.lg)
                .stroke(DS.Colors.primaryGradient, lineWidth: lineWidth)
        )
    }

    /// Animated press effect for buttons
    func pressEffect(_ isPressed: Bool) -> some View {
        self.scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(DS.Anim.quick, value: isPressed)
    }

    /// Stagger animation helper
    func staggeredAnimation(index: Int, total: Int) -> some View {
        self.animation(
            DS.Anim.spring.delay(Double(index) * 0.1),
            value: total
        )
    }
}

// MARK: - Date Formatting
extension Date {
    var shortDisplay: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    var dayKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}

// MARK: - Double Formatting
extension Double {
    var durationDisplay: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        }
        return "\(seconds)s"
    }
}

// MARK: - Int64 File Size Formatting
extension Int64 {
    var fileSizeDisplay: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: self)
    }
}
