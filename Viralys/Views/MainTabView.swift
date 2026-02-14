import SwiftUI

// MARK: - Main Tab View
/// Bottom tab navigation with Home and Profile tabs
struct MainTabView: View {
    @State private var selectedTab = 0

    init() {
        // Style the tab bar
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(DS.Colors.card)
        appearance.shadowColor = .clear

        // Selected item
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(DS.Colors.accent)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(DS.Colors.accent)
        ]

        // Unselected item
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(DS.Colors.textSecondary)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(DS.Colors.textSecondary)
        ]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(0)

            TextOptimizerView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "text.badge.star" : "text.badge.star")
                    Text("Optimize")
                }
                .tag(1)

            ProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "person.fill" : "person")
                    Text("Profile")
                }
                .tag(2)
        }
        .onChange(of: selectedTab) { _ in
            HapticManager.selection()
        }
    }
}
