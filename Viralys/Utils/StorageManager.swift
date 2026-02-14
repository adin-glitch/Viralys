import Foundation

// MARK: - Storage Manager
/// Handles all UserDefaults persistence for the app
enum StorageManager {
    private static let defaults = UserDefaults.standard

    // MARK: - Keys
    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let isPremium = "isPremium"
        static let analysisHistory = "analysisHistory"
        static let dismissedPremiumBanner = "dismissedPremiumBanner"
        static let textAnalysisHistory = "textAnalysisHistory"
        static func uploadHistory(for date: String) -> String {
            "uploadHistory_\(date)"
        }
        static func textOptimizeHistory(for date: String) -> String {
            "textOptimizeHistory_\(date)"
        }
    }

    // MARK: - Onboarding
    static var hasSeenOnboarding: Bool {
        get { defaults.bool(forKey: Keys.hasSeenOnboarding) }
        set { defaults.set(newValue, forKey: Keys.hasSeenOnboarding) }
    }

    // MARK: - Premium Status
    static var isPremium: Bool {
        get { defaults.bool(forKey: Keys.isPremium) }
        set { defaults.set(newValue, forKey: Keys.isPremium) }
    }

    // MARK: - Premium Banner
    static var dismissedPremiumBanner: Bool {
        get { defaults.bool(forKey: Keys.dismissedPremiumBanner) }
        set { defaults.set(newValue, forKey: Keys.dismissedPremiumBanner) }
    }

    // MARK: - Upload Tracking
    static var uploadsToday: Int {
        let key = Keys.uploadHistory(for: Date().dayKey)
        return defaults.integer(forKey: key)
    }

    static func recordUpload() {
        let today = Date().dayKey
        let key = Keys.uploadHistory(for: today)
        let current = defaults.integer(forKey: key)
        defaults.set(current + 1, forKey: key)
        cleanOldUploadHistory(currentDay: today)
    }

    /// Remove upload counts from previous days
    private static func cleanOldUploadHistory(currentDay: String) {
        let allKeys = defaults.dictionaryRepresentation().keys
        for key in allKeys where key.hasPrefix("uploadHistory_") && !key.hasSuffix(currentDay) {
            defaults.removeObject(forKey: key)
        }
    }

    // MARK: - Analysis History
    static func loadHistory() -> [AnalysisResult] {
        guard let data = defaults.data(forKey: Keys.analysisHistory) else { return [] }
        return (try? JSONDecoder().decode([AnalysisResult].self, from: data)) ?? []
    }

    static func saveHistory(_ history: [AnalysisResult]) {
        let trimmed = Array(history.prefix(50))
        if let data = try? JSONEncoder().encode(trimmed) {
            defaults.set(data, forKey: Keys.analysisHistory)
        }
    }

    // MARK: - Text Optimization Tracking

    static var textOptimizationsToday: Int {
        let key = Keys.textOptimizeHistory(for: Date().dayKey)
        return defaults.integer(forKey: key)
    }

    static func recordTextOptimization() {
        let today = Date().dayKey
        let key = Keys.textOptimizeHistory(for: today)
        let current = defaults.integer(forKey: key)
        defaults.set(current + 1, forKey: key)
        cleanOldTextOptimizeHistory(currentDay: today)
    }

    private static func cleanOldTextOptimizeHistory(currentDay: String) {
        let allKeys = defaults.dictionaryRepresentation().keys
        for key in allKeys where key.hasPrefix("textOptimizeHistory_") && !key.hasSuffix(currentDay) {
            defaults.removeObject(forKey: key)
        }
    }

    // MARK: - Text Analysis History

    static func loadTextHistory() -> [TextAnalysisResult] {
        guard let data = defaults.data(forKey: Keys.textAnalysisHistory) else { return [] }
        return (try? JSONDecoder().decode([TextAnalysisResult].self, from: data)) ?? []
    }

    static func saveTextHistory(_ history: [TextAnalysisResult]) {
        let trimmed = Array(history.prefix(50))
        if let data = try? JSONEncoder().encode(trimmed) {
            defaults.set(data, forKey: Keys.textAnalysisHistory)
        }
    }

    // MARK: - Reset (for testing)
    static func resetAll() {
        let domain = Bundle.main.bundleIdentifier ?? ""
        defaults.removePersistentDomain(forName: domain)
    }
}
