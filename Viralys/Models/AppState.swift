import SwiftUI
import Combine

// MARK: - App State
/// Central state management for the entire app
final class AppState: ObservableObject {

    @Published var hasSeenOnboarding: Bool {
        didSet { StorageManager.hasSeenOnboarding = hasSeenOnboarding }
    }

    @Published var isPremium: Bool {
        didSet { StorageManager.isPremium = isPremium }
    }

    @Published var analysisHistory: [AnalysisResult] {
        didSet { StorageManager.saveHistory(analysisHistory) }
    }

    @Published var dismissedPremiumBanner: Bool {
        didSet { StorageManager.dismissedPremiumBanner = dismissedPremiumBanner }
    }

    @Published var textAnalysisHistory: [TextAnalysisResult] {
        didSet { StorageManager.saveTextHistory(textAnalysisHistory) }
    }

    // MARK: - Upload Limits

    var uploadsToday: Int {
        StorageManager.uploadsToday
    }

    var canUpload: Bool {
        isPremium || uploadsToday < 3
    }

    var remainingUploads: Int {
        max(0, 3 - uploadsToday)
    }

    // MARK: - Text Optimization Limits

    var textOptimizationsToday: Int {
        StorageManager.textOptimizationsToday
    }

    var canOptimizeText: Bool {
        isPremium || textOptimizationsToday < 3
    }

    var remainingTextOptimizations: Int {
        max(0, 3 - textOptimizationsToday)
    }

    // MARK: - Stats

    var totalUploads: Int {
        analysisHistory.count
    }

    var averageScore: Int {
        guard !analysisHistory.isEmpty else { return 0 }
        let sum = analysisHistory.reduce(0) { $0 + $1.score }
        return sum / analysisHistory.count
    }

    var bestScore: Int {
        analysisHistory.map(\.score).max() ?? 0
    }

    // MARK: - Text Stats

    var totalTextOptimizations: Int {
        textAnalysisHistory.count
    }

    var averageTextScore: Int {
        guard !textAnalysisHistory.isEmpty else { return 0 }
        let sum = textAnalysisHistory.reduce(0) { $0 + $1.score }
        return sum / textAnalysisHistory.count
    }

    var bestTextScore: Int {
        textAnalysisHistory.map(\.score).max() ?? 0
    }

    // MARK: - Init

    init() {
        self.hasSeenOnboarding = StorageManager.hasSeenOnboarding
        self.isPremium = StorageManager.isPremium
        self.analysisHistory = StorageManager.loadHistory()
        self.dismissedPremiumBanner = StorageManager.dismissedPremiumBanner
        self.textAnalysisHistory = StorageManager.loadTextHistory()
    }

    // MARK: - Actions

    func recordUpload() {
        StorageManager.recordUpload()
        objectWillChange.send()
    }

    func addResult(_ result: AnalysisResult) {
        analysisHistory.insert(result, at: 0)
        if analysisHistory.count > 50 {
            analysisHistory = Array(analysisHistory.prefix(50))
        }
    }

    func deleteResult(at offsets: IndexSet) {
        analysisHistory.remove(atOffsets: offsets)
    }

    func deleteResult(id: UUID) {
        analysisHistory.removeAll { $0.id == id }
    }

    // MARK: - Text Optimization Actions

    func recordTextOptimization() {
        StorageManager.recordTextOptimization()
        objectWillChange.send()
    }

    func addTextResult(_ result: TextAnalysisResult) {
        textAnalysisHistory.insert(result, at: 0)
        if textAnalysisHistory.count > 50 {
            textAnalysisHistory = Array(textAnalysisHistory.prefix(50))
        }
    }

    func deleteTextResult(at offsets: IndexSet) {
        textAnalysisHistory.remove(atOffsets: offsets)
    }

    func deleteTextResult(id: UUID) {
        textAnalysisHistory.removeAll { $0.id == id }
    }
}
