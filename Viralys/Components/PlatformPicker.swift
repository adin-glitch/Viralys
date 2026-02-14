import SwiftUI

// MARK: - Platform Picker
/// Horizontal pill selector for choosing Twitter or LinkedIn
struct PlatformPicker: View {
    @Binding var selected: SocialPlatform

    var body: some View {
        HStack(spacing: DS.Spacing.sm) {
            ForEach(SocialPlatform.allCases, id: \.self) { platform in
                platformPill(platform)
            }
        }
    }

    private func platformPill(_ platform: SocialPlatform) -> some View {
        let isSelected = selected == platform

        return Button {
            withAnimation(DS.Anim.quick) {
                selected = platform
            }
            HapticManager.selection()
        } label: {
            HStack(spacing: DS.Spacing.sm) {
                Image(systemName: platform.icon)
                    .font(.system(size: 15, weight: .semibold))
                Text(platform.shortName)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(isSelected ? .black : DS.Colors.textSecondary)
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.vertical, DS.Spacing.sm + 2)
            .background(isSelected ? DS.Colors.accent : DS.Colors.cardElevated)
            .cornerRadius(DS.Radius.xl)
        }
        .buttonStyle(PressButtonStyle())
    }
}
