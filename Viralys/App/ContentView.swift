import SwiftUI

// MARK: - Content View
/// Root view managing splash → onboarding → main app transitions
struct ContentView: View {
    @StateObject private var appState = AppState()
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashScreen()
                    .transition(.opacity)
            } else if !appState.hasSeenOnboarding {
                OnboardingView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity
                    ))
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .environmentObject(appState)
        .onAppear {
            // Auto-dismiss splash after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(DS.Anim.spring) {
                    showSplash = false
                }
            }
        }
    }
}
