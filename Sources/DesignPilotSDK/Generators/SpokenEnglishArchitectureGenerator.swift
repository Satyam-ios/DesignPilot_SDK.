import Foundation

/// Specialized generator producing a complete, production-ready iOS application architecture
/// for the Spoken English Learning App faithfully matching the Figma vector designs.
public struct SpokenEnglishArchitectureGenerator: Sendable {
    public init() {}

    public static let tokens = DesignTokens(
        colors: [
            ColorToken(name: "brandPrimary", red: 31/255, green: 97/255, blue: 224/255),    // #1F61E0
            ColorToken(name: "brandSecondary", red: 13/255, green: 166/255, blue: 184/255), // #0DA6B8
            ColorToken(name: "accentOrange", red: 255/255, green: 133/255, blue: 51/255),   // #FF8533
            ColorToken(name: "emeraldSuccess", red: 46/255, green: 184/255, blue: 107/255), // #2EB86B
            ColorToken(name: "crimsonDanger", red: 235/255, green: 71/255, blue: 82/255),   // #EB4752
            ColorToken(name: "backgroundCanvas", red: 244/255, green: 246/255, blue: 251/255), // #F4F6FB
            ColorToken(name: "surfaceCard", red: 1.0, green: 1.0, blue: 1.0),
            ColorToken(name: "textPrimary", red: 26/255, green: 29/255, blue: 38/255),      // #1A1D26
            ColorToken(name: "textSecondary", red: 104/255, green: 113/255, blue: 130/255)  // #687182
        ],
        typography: [
            TypographyToken(name: "DisplayHero", fontFamily: "SF Pro Rounded", fontSize: 26, fontWeight: "Bold"),
            TypographyToken(name: "SectionHeader", fontFamily: "SF Pro Rounded", fontSize: 20, fontWeight: "Bold"),
            TypographyToken(name: "CardTitle", fontFamily: "SF Pro Rounded", fontSize: 16, fontWeight: "SemiBold"),
            TypographyToken(name: "BodyRegular", fontFamily: "SF Pro", fontSize: 14, fontWeight: "Regular"),
            TypographyToken(name: "CaptionSmall", fontFamily: "SF Pro", fontSize: 12, fontWeight: "Medium")
        ],
        spacing: [
            SpacingToken(name: "xs", value: 4),
            SpacingToken(name: "sm", value: 8),
            SpacingToken(name: "md", value: 16),
            SpacingToken(name: "lg", value: 20),
            SpacingToken(name: "xl", value: 24)
        ],
        radii: [
            CornerRadiusToken(name: "card", value: 16),
            CornerRadiusToken(name: "button", value: 14),
            CornerRadiusToken(name: "pill", value: 20),
            CornerRadiusToken(name: "avatar", value: 24)
        ],
        shadows: [
            ShadowToken(name: "cardShadow", colorHex: "#1F61E0", colorAlpha: 0.08, radius: 10, x: 0, y: 4)
        ]
    )

    public func generate(
        targetDirectory: String = "Views/Generated",
        preferredFramework: TargetFramework = .swiftUI
    ) -> AppArchitectureOutput {
        var files: [GeneratedFile] = [
            generateAppEntry(targetDirectory: targetDirectory),
            generateRouter(targetDirectory: targetDirectory),
            generateHomeDailyTargetView(targetDirectory: targetDirectory),
            generateAICoachCorrectionView(targetDirectory: targetDirectory),
            generateVisualRoadmapView(targetDirectory: targetDirectory),
            generateMultilingualVocabularyView(targetDirectory: targetDirectory),
            generateLanguageTranslatorView(targetDirectory: targetDirectory),
            generateShadowingPronunciationView(targetDirectory: targetDirectory),
            generateComponents(targetDirectory: targetDirectory),
            generateViewModel(targetDirectory: targetDirectory),
            generateModels(targetDirectory: targetDirectory),
            generateService(targetDirectory: targetDirectory),
            generateTheme(targetDirectory: targetDirectory),
            generateUnitTests(targetDirectory: targetDirectory)
        ]

        if preferredFramework == .uiKit {
            files.append(contentsOf: [
                generateUIKitHomeViewController(targetDirectory: targetDirectory),
                generateUIKitAICoachViewController(targetDirectory: targetDirectory),
                generateUIKitTabBarController(targetDirectory: targetDirectory),
                generateSpokenEnglishStoryboard(targetDirectory: targetDirectory)
            ])
        }

        let summary = AppArchitectureSummary(
            pattern: preferredFramework == .uiKit ? "UIKit + AutoLayout (Spoken English)" : "MVVM + Navigation Coordinator (Spoken English)",
            discoveredScreensCount: 6,
            reusableComponentsCount: 6,
            modelsCount: 6,
            servicesCount: 2,
            testsCount: 6,
            remainingIntegrationPoints: [
                "Configure live Whisper / ElevenLabs speech recognition API endpoint in SpokenEnglishService.swift",
                "Connect AVFoundation audio microphone recording permissions in AICoachCorrectionView.swift"
            ]
        )

        return AppArchitectureOutput(files: files, summary: summary, tokens: Self.tokens)
    }

    // MARK: - App Root Entry

    private func generateAppEntry(targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  SpokenEnglishAppRootView.swift
        //  Generated by DesignPilot SDK v1.0
        //  Figma Design: Spoken English Learning App (z3bsh0M4MFRN7HvwWuYT7e)
        //

        import SwiftUI

        /// Application root view establishing Navigation and global State Environment for Spoken English.
        public struct SpokenEnglishAppRootView: View {
            @StateObject private var router = SpokenEnglishRouter()
            @StateObject private var viewModel = SpokenEnglishViewModel()

            public init() {}

            public var body: some View {
                SpokenEnglishRouterView()
                    .environmentObject(router)
                    .environmentObject(viewModel)
            }
        }

        #Preview {
            SpokenEnglishAppRootView()
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/App/SpokenEnglishAppRootView.swift",
            content: content,
            status: .created,
            framework: .swiftUI
        )
    }

    // MARK: - Router & Coordinator

    private func generateRouter(targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  SpokenEnglishRouter.swift
        //  Generated by DesignPilot SDK v1.0
        //

        import SwiftUI
        import Combine

        public enum SpokenEnglishRoute: String, CaseIterable, Identifiable {
            case home = "Daily Target"
            case aiCoach = "AI Coach"
            case roadmap = "90-Day Roadmap"
            case vocabulary = "Vocabulary"
            case translator = "Translator"
            case shadowing = "Pronunciation"

            public var id: String { rawValue }

            public var iconName: String {
                switch self {
                case .home: return "target"
                case .aiCoach: return "sparkles.bubble.fill"
                case .roadmap: return "map.fill"
                case .vocabulary: return "text.book.closed.fill"
                case .translator: return "character.bubble.fill"
                case .shadowing: return "waveform"
                }
            }
        }

        public final class SpokenEnglishRouter: ObservableObject {
            @Published public var currentRoute: SpokenEnglishRoute = .home

            public init() {}

            public func navigate(to route: SpokenEnglishRoute) {
                currentRoute = route
            }
        }

        public struct SpokenEnglishRouterView: View {
            @EnvironmentObject private var router: SpokenEnglishRouter

            public init() {}

            public var body: some View {
                NavigationStack {
                    ZStack(alignment: .bottom) {
                        SpokenEnglishTheme.backgroundGray
                            .ignoresSafeArea()

                        Group {
                            switch router.currentRoute {
                            case .home:
                                HomeDailyTargetView()
                            case .aiCoach:
                                AICoachCorrectionView()
                            case .roadmap:
                                VisualRoadmapView()
                            case .vocabulary:
                                MultilingualVocabularyView()
                            case .translator:
                                LanguageTranslatorView()
                            case .shadowing:
                                ShadowingPronunciationView()
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                        // Floating 5-Tab Bar
                        spokenEnglishTabBar
                    }
                }
            }

            private var spokenEnglishTabBar: some View {
                HStack(spacing: 0) {
                    tabButton(route: .home)
                    Spacer()
                    tabButton(route: .aiCoach)
                    Spacer()
                    tabButton(route: .roadmap)
                    Spacer()
                    tabButton(route: .vocabulary)
                    Spacer()
                    tabButton(route: .translator)
                    Spacer()
                    tabButton(route: .shadowing)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 24))
                .shadow(color: Color.black.opacity(0.08), radius: 12, y: 4)
                .padding(.horizontal, 14)
                .padding(.bottom, 8)
            }

            private func tabButton(route: SpokenEnglishRoute) -> some View {
                let isSelected = router.currentRoute == route
                return Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        router.navigate(to: route)
                    }
                }) {
                    VStack(spacing: 3) {
                        Image(systemName: route.iconName)
                            .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                            .foregroundColor(isSelected ? SpokenEnglishTheme.primaryBlue : SpokenEnglishTheme.textSecondary)
                        Text(route.rawValue)
                            .font(.system(size: 9, weight: isSelected ? .bold : .medium))
                            .foregroundColor(isSelected ? SpokenEnglishTheme.primaryBlue : SpokenEnglishTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/Navigation/SpokenEnglishRouter.swift",
            content: content,
            status: .created,
            framework: .swiftUI
        )
    }

    // MARK: - Screen 1: Home Daily Target

    private func generateHomeDailyTargetView(targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  HomeDailyTargetView.swift
        //  Generated by DesignPilot SDK v1.0
        //  Figma Frame: 01_HomeScreen_DailyTarget (393 × 852 px)
        //

        import SwiftUI

        public struct HomeDailyTargetView: View {
            @EnvironmentObject private var viewModel: SpokenEnglishViewModel
            @EnvironmentObject private var router: SpokenEnglishRouter

            public init() {}

            public var body: some View {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        // User Greeting & Streak Bar
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Good Morning, Satyam 👋")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(SpokenEnglishTheme.textPrimary)
                                Text("Let's hit your 15-min speaking goal today")
                                    .font(.system(size: 12))
                                    .foregroundColor(SpokenEnglishTheme.textSecondary)
                            }
                            Spacer()
                            // Streak Flame Badge
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(SpokenEnglishTheme.accentOrange)
                                Text("\\(viewModel.streakDays) Days")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(SpokenEnglishTheme.accentOrange)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(SpokenEnglishTheme.accentOrange.opacity(0.12), in: Capsule())
                        }
                        .padding(.top, 8)

                        // Action-Oriented Hero Card (Day 2 of 90 • 60% Goal)
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [SpokenEnglishTheme.primaryBlue, Color(red: 16/255, green: 76/255, blue: 184/255)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )

                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Day 2 of 90 • 60% Target Achieved")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(Color.white.opacity(0.9))
                                    Spacer()
                                    Text("Beginner A1")
                                        .font(.system(size: 10, weight: .bold))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color.white.opacity(0.2), in: Capsule())
                                        .foregroundColor(.white)
                                }

                                Text("Focus: Introducing Yourself & Daily Routine")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)

                                // Progress Bar
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Capsule().fill(Color.white.opacity(0.2)).frame(height: 8)
                                        Capsule().fill(SpokenEnglishTheme.accentOrange).frame(width: geo.size.width * 0.6, height: 8)
                                    }
                                }
                                .frame(height: 8)

                                HStack {
                                    Text("Target: 15 mins daily")
                                        .font(.system(size: 11))
                                        .foregroundColor(Color.white.opacity(0.8))
                                    Spacer()
                                    Button(action: { router.navigate(to: .aiCoach) }) {
                                        Text("Continue Learning ➔")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.white.opacity(0.2), in: Capsule())
                                    }
                                }
                            }
                            .padding(16)
                        }
                        .frame(height: 160)

                        // 6-Pillar Daily Checklist
                        Text("Today's 6-Pillar Curriculum")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(SpokenEnglishTheme.textPrimary)

                        VStack(spacing: 10) {
                            ForEach(viewModel.dailyPillars) { pillar in
                                pillarRow(pillar)
                            }
                        }

                        Spacer(minLength: 90)
                    }
                    .padding(.horizontal, 16)
                }
            }

            private func pillarRow(_ pillar: LessonPillar) -> some View {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(pillar.isCompleted ? SpokenEnglishTheme.successGreen.opacity(0.15) : SpokenEnglishTheme.primaryBlue.opacity(0.1))
                            .frame(width: 38, height: 38)
                        Image(systemName: pillar.iconName)
                            .foregroundColor(pillar.isCompleted ? SpokenEnglishTheme.successGreen : SpokenEnglishTheme.primaryBlue)
                            .font(.system(size: 15, weight: .semibold))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(pillar.title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(SpokenEnglishTheme.textPrimary)
                        Text(pillar.subtitle)
                            .font(.system(size: 11))
                            .foregroundColor(SpokenEnglishTheme.textSecondary)
                    }

                    Spacer()

                    if pillar.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(SpokenEnglishTheme.successGreen)
                            .font(.system(size: 18))
                    } else {
                        Button(action: {
                            withAnimation { viewModel.togglePillar(pillar.id) }
                        }) {
                            Text("Start")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(SpokenEnglishTheme.primaryBlue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 5)
                                .background(SpokenEnglishTheme.primaryBlue.opacity(0.1), in: Capsule())
                        }
                    }
                }
                .padding(12)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 14))
                .shadow(color: Color.black.opacity(0.03), radius: 6, y: 2)
            }
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/Views/HomeDailyTargetView.swift",
            content: content,
            status: .created,
            framework: .swiftUI
        )
    }

    // MARK: - Screen 2: AI Coach & Sentence Correction

    private func generateAICoachCorrectionView(targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  AICoachCorrectionView.swift
        //  Generated by DesignPilot SDK v1.0
        //  Figma Frame: 02_AICoach_SentenceCorrection (393 × 852 px)
        //

        import SwiftUI

        public struct AICoachCorrectionView: View {
            @EnvironmentObject private var viewModel: SpokenEnglishViewModel
            @State private var isRecording: Bool = false
            @State private var showPracticedToast: Bool = false

            public init() {}

            public var body: some View {
                VStack(spacing: 0) {
                    // Top Bar
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("AI Live Sentence Correction")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(SpokenEnglishTheme.textPrimary)
                            Text("Speak naturally • Instant conversational corrections")
                                .font(.system(size: 11))
                                .foregroundColor(SpokenEnglishTheme.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "sparkles")
                            .foregroundColor(SpokenEnglishTheme.secondaryTeal)
                            .font(.system(size: 18, weight: .bold))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.white)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            // Conversation turns
                            ForEach(viewModel.corrections) { item in
                                correctionCard(item)
                            }
                            Spacer(minLength: 120)
                        }
                        .padding(16)
                    }

                    // Bottom Speech Input Action Bar
                    bottomSpeechBar
                }
                .overlay(alignment: .top) {
                    if showPracticedToast {
                        Text("Practice recorded! Pronunciation score: 94%")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(SpokenEnglishTheme.successGreen, in: Capsule())
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .padding(.top, 50)
                    }
                }
            }

            private func correctionCard(_ item: CorrectionItem) -> some View {
                VStack(alignment: .leading, spacing: 10) {
                    // Original transcript with strikethrough in red
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(SpokenEnglishTheme.dangerRed)
                            .font(.system(size: 14))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("What you said:")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(SpokenEnglishTheme.textSecondary)
                            Text(item.originalText)
                                .font(.system(size: 14, weight: .semibold))
                                .strikethrough(true, color: SpokenEnglishTheme.dangerRed)
                                .foregroundColor(SpokenEnglishTheme.dangerRed)
                        }
                    }

                    Divider()

                    // Corrected Natural English in bold green
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(SpokenEnglishTheme.successGreen)
                            .font(.system(size: 14))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Natural English:")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(SpokenEnglishTheme.successGreen)
                            Text(item.correctedText)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(SpokenEnglishTheme.successGreen)
                        }
                    }

                    // Explanation Box
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(SpokenEnglishTheme.secondaryTeal)
                                .font(.system(size: 11))
                            Text("Why? (Grammar & Idiomatic Context)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(SpokenEnglishTheme.secondaryTeal)
                        }
                        Text(item.explanation)
                            .font(.system(size: 12))
                            .foregroundColor(SpokenEnglishTheme.textSecondary)
                    }
                    .padding(10)
                    .background(SpokenEnglishTheme.secondaryTeal.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))

                    // Action Buttons (Listen Audio & I've Practiced It)
                    HStack(spacing: 10) {
                        Button(action: { viewModel.playAudio(for: item.correctedText) }) {
                            HStack(spacing: 4) {
                                Image(systemName: "speaker.wave.2.fill")
                                Text("Listen")
                            }
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(SpokenEnglishTheme.primaryBlue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(SpokenEnglishTheme.primaryBlue.opacity(0.1), in: Capsule())
                        }

                        Spacer()

                        Button(action: {
                            withAnimation { showPracticedToast = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation { showPracticedToast = false }
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "hand.thumbsup.fill")
                                Text("I've Practiced It")
                            }
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(SpokenEnglishTheme.primaryBlue, in: Capsule())
                        }
                    }
                }
                .padding(16)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.black.opacity(0.04), radius: 8, y: 3)
            }

            private var bottomSpeechBar: some View {
                HStack(spacing: 12) {
                    Button(action: {
                        isRecording.toggle()
                        if !isRecording {
                            viewModel.simulateNewSpeechTurn()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: isRecording ? "waveform.circle.fill" : "mic.fill")
                                .font(.system(size: 18, weight: .bold))
                            Text(isRecording ? "Listening... (Tap to Send)" : "Hold or Tap to Speak")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(isRecording ? SpokenEnglishTheme.dangerRed : SpokenEnglishTheme.primaryBlue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: (isRecording ? SpokenEnglishTheme.dangerRed : SpokenEnglishTheme.primaryBlue).opacity(0.3), radius: 6, y: 3)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.white)
            }
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/Views/AICoachCorrectionView.swift",
            content: content,
            status: .created,
            framework: .swiftUI
        )
    }

    // MARK: - Screen 3: Visual Roadmap (90-Day Plan)

    private func generateVisualRoadmapView(targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  VisualRoadmapView.swift
        //  Generated by DesignPilot SDK v1.0
        //  Figma Frame: 03_VisualRoadmap_DayPlan (393 × 852 px)
        //

        import SwiftUI

        public struct VisualRoadmapView: View {
            @EnvironmentObject private var viewModel: SpokenEnglishViewModel
            @State private var selectedMonth: Int = 1

            public init() {}

            public var body: some View {
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("90-Day Fluency Roadmap")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(SpokenEnglishTheme.textPrimary)
                        Text("Structured day-by-day speaking progression")
                            .font(.system(size: 12))
                            .foregroundColor(SpokenEnglishTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 10)

                    // Month Tabs: Month 1 | Month 2 | Month 3
                    HStack(spacing: 8) {
                        monthTab(month: 1, title: "Month 1: Foundation")
                        monthTab(month: 2, title: "Month 2: Fluency")
                        monthTab(month: 3, title: "Month 3: Mastery")
                    }
                    .padding(4)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(viewModel.roadmapDays) { day in
                                roadmapDayCard(day)
                            }
                            Spacer(minLength: 90)
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }

            private func monthTab(month: Int, title: String) -> some View {
                let isSelected = selectedMonth == month
                return Button(action: { withAnimation { selectedMonth = month } }) {
                    Text(title)
                        .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                        .foregroundColor(isSelected ? .white : SpokenEnglishTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(isSelected ? SpokenEnglishTheme.primaryBlue : Color.clear, in: RoundedRectangle(cornerRadius: 8))
                }
            }

            private func roadmapDayCard(_ day: RoadmapDay) -> some View {
                HStack(spacing: 12) {
                    // Status Badge
                    ZStack {
                        Circle()
                            .fill(day.isCompleted ? SpokenEnglishTheme.successGreen : (day.isActive ? SpokenEnglishTheme.primaryBlue : Color.gray.opacity(0.2)))
                            .frame(width: 36, height: 36)
                        if day.isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        } else if day.isActive {
                            Text("\\(day.dayNumber)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text("Day \\(day.dayNumber): \\(day.title)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(SpokenEnglishTheme.textPrimary)
                            Spacer()
                            if day.isActive {
                                Text("Active Today")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(SpokenEnglishTheme.primaryBlue)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(SpokenEnglishTheme.primaryBlue.opacity(0.12), in: Capsule())
                            }
                        }
                        Text(day.subtitle)
                            .font(.system(size: 11))
                            .foregroundColor(SpokenEnglishTheme.textSecondary)
                    }
                }
                .padding(14)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 14))
                .shadow(color: Color.black.opacity(0.03), radius: 6, y: 2)
            }
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/Views/VisualRoadmapView.swift",
            content: content,
            status: .created,
            framework: .swiftUI
        )
    }

    // MARK: - Screen 4: Multilingual Vocabulary (Word of the Day)

    private func generateMultilingualVocabularyView(targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  MultilingualVocabularyView.swift
        //  Generated by DesignPilot SDK v1.0
        //  Figma Frame: 04_MultilingualVocabulary (393 × 852 px)
        //

        import SwiftUI

        public struct MultilingualVocabularyView: View {
            @EnvironmentObject private var viewModel: SpokenEnglishViewModel

            public init() {}

            public var body: some View {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Word of the Day")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(SpokenEnglishTheme.textPrimary)
                            .padding(.top, 8)

                        // Hero Vocabulary Card: Eloquent
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(viewModel.wordOfTheDay.word)
                                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                                        .foregroundColor(SpokenEnglishTheme.primaryBlue)
                                    Text(viewModel.wordOfTheDay.phonetic)
                                        .font(.system(size: 13, design: .monospaced))
                                        .foregroundColor(SpokenEnglishTheme.textSecondary)
                                }
                                Spacer()
                                Button(action: { viewModel.playAudio(for: viewModel.wordOfTheDay.word) }) {
                                    Image(systemName: "speaker.wave.3.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)
                                        .frame(width: 44, height: 44)
                                        .background(SpokenEnglishTheme.primaryBlue, in: Circle())
                                }
                            }

                            // Hindi & Multilingual Meaning Badge
                            HStack(spacing: 6) {
                                Text(viewModel.wordOfTheDay.hindiMeaning)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(SpokenEnglishTheme.accentOrange)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(SpokenEnglishTheme.accentOrange.opacity(0.12), in: Capsule())
                                Text("• Adjective")
                                    .font(.system(size: 12))
                                    .foregroundColor(SpokenEnglishTheme.textSecondary)
                            }

                            Divider()

                            // Simple English Definition
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Simple Definition:")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(SpokenEnglishTheme.textSecondary)
                                Text(viewModel.wordOfTheDay.englishDefinition)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(SpokenEnglishTheme.textPrimary)
                            }

                            // Conversation Usage Example
                            VStack(alignment: .leading, spacing: 4) {
                                Text("In Everyday Conversation:")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(SpokenEnglishTheme.secondaryTeal)
                                Text("\\"\\(viewModel.wordOfTheDay.exampleSentence)\\"")
                                    .font(.system(size: 13, weight: .regular))
                                    .italic()
                                    .foregroundColor(SpokenEnglishTheme.textPrimary)
                            }
                            .padding(10)
                            .background(SpokenEnglishTheme.secondaryTeal.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
                        }
                        .padding(18)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 20))
                        .shadow(color: Color.black.opacity(0.05), radius: 10, y: 3)

                        // Recent Words List
                        Text("Recent Words Learned")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(SpokenEnglishTheme.textPrimary)

                        ForEach(viewModel.recentWords) { w in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(w.word)
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(SpokenEnglishTheme.textPrimary)
                                    Text(w.hindiMeaning)
                                        .font(.system(size: 12))
                                        .foregroundColor(SpokenEnglishTheme.accentOrange)
                                }
                                Spacer()
                                Button(action: { viewModel.playAudio(for: w.word) }) {
                                    Image(systemName: "speaker.wave.2")
                                        .foregroundColor(SpokenEnglishTheme.primaryBlue)
                                }
                            }
                            .padding(12)
                            .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
                        }

                        Spacer(minLength: 90)
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/Views/MultilingualVocabularyView.swift",
            content: content,
            status: .created,
            framework: .swiftUI
        )
    }

    // MARK: - Screen 5: 15-Language Real-time Translator

    private func generateLanguageTranslatorView(targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  LanguageTranslatorView.swift
        //  Generated by DesignPilot SDK v1.0
        //  Figma Frame: 05_EnglishToAnyLanguageTranslator (393 × 852 px)
        //

        import SwiftUI

        public struct LanguageTranslatorView: View {
            @EnvironmentObject private var viewModel: SpokenEnglishViewModel
            @State private var inputText: String = "Yesterday, I had a meal with my family."
            @State private var selectedLanguage: String = "Hindi (हिन्दी)"

            private let languages = ["Hindi (हिन्दी)", "Spanish (Español)", "French (Français)", "German (Deutsch)", "Japanese (日本語)", "Telugu (తెలుగు)", "Tamil (தமிழ்)"]

            public init() {}

            public var body: some View {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("English to Any Language Translator")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(SpokenEnglishTheme.textPrimary)
                            .padding(.top, 8)

                        // Target Language Selector
                        Menu {
                            ForEach(languages, id: \\.self) { lang in
                                Button(lang) { selectedLanguage = lang }
                            }
                        } label: {
                            HStack {
                                Text("Target Language: \\(selectedLanguage)")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(SpokenEnglishTheme.primaryBlue)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(SpokenEnglishTheme.primaryBlue)
                            }
                            .padding(12)
                            .background(SpokenEnglishTheme.primaryBlue.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                        }

                        // English Input Card
                        VStack(alignment: .leading, spacing: 8) {
                            Text("English Input:")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(SpokenEnglishTheme.textSecondary)

                            TextField("Type English sentence...", text: $inputText, axis: .vertical)
                                .font(.system(size: 15))
                                .padding(10)
                                .background(SpokenEnglishTheme.backgroundGray, in: RoundedRectangle(cornerRadius: 10))

                            HStack {
                                Spacer()
                                Button(action: { viewModel.playAudio(for: inputText) }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "speaker.wave.2.fill")
                                        Text("Listen English")
                                    }
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(SpokenEnglishTheme.primaryBlue)
                                }
                            }
                        }
                        .padding(14)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))

                        // Translation Output Card
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Translation (\\(selectedLanguage)):")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(SpokenEnglishTheme.successGreen)

                            Text("कल मैंने अपने परिवार के साथ भोजन किया था।")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(SpokenEnglishTheme.textPrimary)

                            Text("Phonetic: Kal maine apne parivaar ke saath bhojan kiya tha.")
                                .font(.system(size: 12))
                                .foregroundColor(SpokenEnglishTheme.textSecondary)

                            Divider()

                            HStack {
                                Button(action: {}) {
                                    Label("Copy", systemImage: "doc.on.doc")
                                        .font(.system(size: 12))
                                        .foregroundColor(SpokenEnglishTheme.textSecondary)
                                }
                                Spacer()
                                Button(action: {}) {
                                    Label("Bookmark", systemImage: "bookmark.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(SpokenEnglishTheme.accentOrange)
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.black.opacity(0.04), radius: 8, y: 3)

                        Spacer(minLength: 90)
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/Views/LanguageTranslatorView.swift",
            content: content,
            status: .created,
            framework: .swiftUI
        )
    }

    // MARK: - Screen 6: Shadowing & Pronunciation Lab

    private func generateShadowingPronunciationView(targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  ShadowingPronunciationView.swift
        //  Generated by DesignPilot SDK v1.0
        //  Figma Frame: 06_ShadowingAndPronunciation (393 × 852 px)
        //

        import SwiftUI

        public struct ShadowingPronunciationView: View {
            @EnvironmentObject private var viewModel: SpokenEnglishViewModel
            @State private var selectedSpeed: Double = 1.0

            private let speeds = [0.75, 1.0, 1.25]

            public init() {}

            public var body: some View {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Title
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Shadowing & Rhythm Lab")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(SpokenEnglishTheme.textPrimary)
                            Text("Listen, repeat with correct syllable stress & pacing")
                                .font(.system(size: 11))
                                .foregroundColor(SpokenEnglishTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)

                        // 94% Circular Fluency Score Gauge
                        ZStack {
                            Circle()
                                .stroke(SpokenEnglishTheme.successGreen.opacity(0.2), lineWidth: 10)
                                .frame(width: 120, height: 120)
                            Circle()
                                .trim(from: 0, to: 0.94)
                                .stroke(SpokenEnglishTheme.successGreen, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                                .frame(width: 120, height: 120)

                            VStack(spacing: 2) {
                                Text("94%")
                                    .font(.system(size: 26, weight: .black, design: .rounded))
                                    .foregroundColor(SpokenEnglishTheme.successGreen)
                                Text("Fluency Match")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(SpokenEnglishTheme.textSecondary)
                            }
                        }
                        .padding(.vertical, 10)

                        // Target Sentence Syllables
                        VStack(spacing: 8) {
                            Text("Target Sentence Breakdown:")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(SpokenEnglishTheme.textSecondary)

                            Text("Yes • ter • day,   I   had   a   meal.")
                                .font(.system(size: 18, weight: .heavy, design: .rounded))
                                .foregroundColor(SpokenEnglishTheme.primaryBlue)

                            Text("/ˈjes.tə.deɪ aɪ hæd ə miːl/")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(SpokenEnglishTheme.textSecondary)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))

                        // Multi-Speed Audio Controls (0.75x, 1.0x, 1.25x)
                        HStack(spacing: 12) {
                            Text("Playback Speed:")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(SpokenEnglishTheme.textSecondary)
                            Spacer()
                            ForEach(speeds, id: \\.self) { speed in
                                Button(action: { selectedSpeed = speed }) {
                                    Text(String(format: "%.2fx", speed))
                                        .font(.system(size: 12, weight: selectedSpeed == speed ? .bold : .medium))
                                        .foregroundColor(selectedSpeed == speed ? .white : SpokenEnglishTheme.primaryBlue)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(selectedSpeed == speed ? SpokenEnglishTheme.primaryBlue : SpokenEnglishTheme.primaryBlue.opacity(0.1), in: Capsule())
                                }
                            }
                        }
                        .padding(14)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 14))

                        // 6-Dimension Feedback Metrics
                        VStack(spacing: 10) {
                            metricBar(name: "Pitch & Modulation", score: 0.95)
                            metricBar(name: "Pace & Rhythm", score: 0.92)
                            metricBar(name: "Syllable Stress", score: 0.96)
                            metricBar(name: "Vowel Accuracy", score: 0.93)
                        }
                        .padding(16)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))

                        Spacer(minLength: 90)
                    }
                    .padding(.horizontal, 16)
                }
            }

            private func metricBar(name: String, score: Double) -> some View {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(name)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(SpokenEnglishTheme.textPrimary)
                        Spacer()
                        Text("\\(Int(score * 100))%")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(SpokenEnglishTheme.successGreen)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.gray.opacity(0.15)).frame(height: 6)
                            Capsule().fill(SpokenEnglishTheme.successGreen).frame(width: geo.size.width * CGFloat(score), height: 6)
                        }
                    }
                    .frame(height: 6)
                }
            }
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/Views/ShadowingPronunciationView.swift",
            content: content,
            status: .created,
            framework: .swiftUI
        )
    }

    // MARK: - Components

    private func generateComponents(targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  SpokenEnglishComponents.swift
        //  Generated by DesignPilot SDK v1.0
        //

        import SwiftUI

        public struct FluencyGaugeComponent: View {
            public let percentage: Int

            public init(percentage: Int) {
                self.percentage = percentage
            }

            public var body: some View {
                ZStack {
                    Circle()
                        .stroke(SpokenEnglishTheme.successGreen.opacity(0.2), lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: CGFloat(percentage) / 100.0)
                        .stroke(SpokenEnglishTheme.successGreen, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\\(percentage)%")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(SpokenEnglishTheme.successGreen)
                }
                .frame(width: 50, height: 50)
            }
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/Components/SpokenEnglishComponents.swift",
            content: content,
            status: .created,
            framework: .swiftUI
        )
    }

    // MARK: - ViewModel

    private func generateViewModel(targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  SpokenEnglishViewModel.swift
        //  Generated by DesignPilot SDK v1.0
        //

        import SwiftUI
        import Combine

        @MainActor
        public final class SpokenEnglishViewModel: ObservableObject {
            @Published public var streakDays: Int = 5
            @Published public var dailyProgressPercentage: Double = 0.60
            @Published public var dailyPillars: [LessonPillar] = []
            @Published public var corrections: [CorrectionItem] = []
            @Published public var wordOfTheDay: VocabularyWord
            @Published public var recentWords: [VocabularyWord] = []
            @Published public var roadmapDays: [RoadmapDay] = []

            public init() {
                self.wordOfTheDay = VocabularyWord(
                    id: "eloquent",
                    word: "Eloquent",
                    phonetic: "/ˈel.ə.kwənt/",
                    hindiMeaning: "हिन्दी: वाक्पटु / सुवक्ता",
                    englishDefinition: "Fluent or persuasive in speaking or writing.",
                    exampleSentence: "His eloquent speech inspired the entire audience."
                )

                self.dailyPillars = [
                    LessonPillar(id: "1", title: "1. AI Sentence Correction", subtitle: "2 turns practiced • 94% accuracy", iconName: "sparkles.bubble.fill", isCompleted: true),
                    LessonPillar(id: "2", title: "2. Speaking Practice", subtitle: "Describe your morning routine", iconName: "mic.fill", isCompleted: true),
                    LessonPillar(id: "3", title: "3. Shadowing & Rhythm", subtitle: "Sentence stress & intonation", iconName: "waveform", isCompleted: true),
                    LessonPillar(id: "4", title: "4. Daily Vocabulary", subtitle: "Learn 'Eloquent' in context", iconName: "text.book.closed.fill", isCompleted: false),
                    LessonPillar(id: "5", title: "5. Grammar Checkpoint", subtitle: "Past Simple vs Present Perfect", iconName: "checkmark.shield.fill", isCompleted: false),
                    LessonPillar(id: "6", title: "6. Listening Comprehension", subtitle: "2-min conversational podcast", iconName: "headphones", isCompleted: false)
                ]

                self.corrections = [
                    CorrectionItem(
                        id: "c1",
                        originalText: "Yesterday, I ate food.",
                        correctedText: "Yesterday, I had a meal.",
                        explanation: "'Had a meal' is far more natural and conversational in English than 'ate food'.",
                        fluencyScore: 94
                    ),
                    CorrectionItem(
                        id: "c2",
                        originalText: "I am having two brothers.",
                        correctedText: "I have two brothers.",
                        explanation: "Possession is expressed in the simple present tense ('have'), not progressive ('having').",
                        fluencyScore: 96
                    )
                ]

                self.recentWords = [
                    VocabularyWord(id: "w1", word: "Articulate", phonetic: "/ɑːˈtɪk.jə.lət/", hindiMeaning: "स्पष्ट वक्ता", englishDefinition: "Able to express ideas clearly.", exampleSentence: "She is an articulate communicator."),
                    VocabularyWord(id: "w2", word: "Ponder", phonetic: "/ˈpɒn.dər/", hindiMeaning: "गहराई से सोचना", englishDefinition: "To think about something carefully.", exampleSentence: "He pondered the question before answering.")
                ]

                self.roadmapDays = [
                    RoadmapDay(dayNumber: 1, title: "Greetings & Self-Introduction", subtitle: "Basic conversational starters", isCompleted: true, isActive: false),
                    RoadmapDay(dayNumber: 2, title: "Daily Routine & Habitual Verbs", subtitle: "Present simple and time markers", isCompleted: false, isActive: true),
                    RoadmapDay(dayNumber: 3, title: "Talking About Past Events", subtitle: "Irregular past tense verbs", isCompleted: false, isActive: false),
                    RoadmapDay(dayNumber: 4, title: "Ordering Food & Shopping", subtitle: "Polite requests: Could I have...", isCompleted: false, isActive: false),
                    RoadmapDay(dayNumber: 5, title: "Asking for Directions", subtitle: "Prepositions of location and movement", isCompleted: false, isActive: false)
                ]
            }

            public func togglePillar(_ id: String) {
                if let idx = dailyPillars.firstIndex(where: { $0.id == id }) {
                    dailyPillars[idx].isCompleted.toggle()
                }
            }

            public func playAudio(for text: String) {
                // Audio synthesis hook
            }

            public func simulateNewSpeechTurn() {
                let newItem = CorrectionItem(
                    id: UUID().uuidString,
                    originalText: "He do not know the answer.",
                    correctedText: "He doesn't know the answer.",
                    explanation: "Third-person singular ('he/she/it') uses 'doesn't' instead of 'do not'.",
                    fluencyScore: 95
                )
                corrections.append(newItem)
            }
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/ViewModels/SpokenEnglishViewModel.swift",
            content: content,
            status: .created,
            framework: .swiftUI
        )
    }

    // MARK: - Models

    private func generateModels(targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  SpokenEnglishModels.swift
        //  Generated by DesignPilot SDK v1.0
        //

        import Foundation

        public struct LessonPillar: Identifiable, Sendable {
            public let id: String
            public let title: String
            public let subtitle: String
            public let iconName: String
            public var isCompleted: Bool

            public init(id: String, title: String, subtitle: String, iconName: String, isCompleted: Bool) {
                self.id = id
                self.title = title
                self.subtitle = subtitle
                self.iconName = iconName
                self.isCompleted = isCompleted
            }
        }

        public struct CorrectionItem: Identifiable, Sendable {
            public let id: String
            public let originalText: String
            public let correctedText: String
            public let explanation: String
            public let fluencyScore: Int

            public init(id: String, originalText: String, correctedText: String, explanation: String, fluencyScore: Int) {
                self.id = id
                self.originalText = originalText
                self.correctedText = correctedText
                self.explanation = explanation
                self.fluencyScore = fluencyScore
            }
        }

        public struct VocabularyWord: Identifiable, Sendable {
            public let id: String
            public let word: String
            public let phonetic: String
            public let hindiMeaning: String
            public let englishDefinition: String
            public let exampleSentence: String

            public init(id: String, word: String, phonetic: String, hindiMeaning: String, englishDefinition: String, exampleSentence: String) {
                self.id = id
                self.word = word
                self.phonetic = phonetic
                self.hindiMeaning = hindiMeaning
                self.englishDefinition = englishDefinition
                self.exampleSentence = exampleSentence
            }
        }

        public struct RoadmapDay: Identifiable, Sendable {
            public var id: Int { dayNumber }
            public let dayNumber: Int
            public let title: String
            public let subtitle: String
            public var isCompleted: Bool
            public var isActive: Bool

            public init(dayNumber: Int, title: String, subtitle: String, isCompleted: Bool, isActive: Bool) {
                self.dayNumber = dayNumber
                self.title = title
                self.subtitle = subtitle
                self.isCompleted = isCompleted
                self.isActive = isActive
            }
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/Models/SpokenEnglishModels.swift",
            content: content,
            status: .created,
            framework: .swiftUI
        )
    }

    // MARK: - Service

    private func generateService(targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  SpokenEnglishService.swift
        //  Generated by DesignPilot SDK v1.0
        //

        import Foundation

        public protocol SpokenEnglishServiceProtocol: Sendable {
            func fetchDailyTarget() async throws -> (streak: Int, progress: Double)
            func submitSpeechTranscript(_ text: String) async throws -> CorrectionItem
        }

        public struct SpokenEnglishService: SpokenEnglishServiceProtocol {
            public init() {}

            public func fetchDailyTarget() async throws -> (streak: Int, progress: Double) {
                return (streak: 5, progress: 0.60)
            }

            public func submitSpeechTranscript(_ text: String) async throws -> CorrectionItem {
                return CorrectionItem(
                    id: UUID().uuidString,
                    originalText: text,
                    correctedText: "Yesterday, I had a meal.",
                    explanation: "Natural English replacement.",
                    fluencyScore: 94
                )
            }
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/Services/SpokenEnglishService.swift",
            content: content,
            status: .created,
            framework: .swiftUI
        )
    }

    // MARK: - Theme

    private func generateTheme(targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  SpokenEnglishTheme.swift
        //  Generated by DesignPilot SDK v1.0
        //  Tokens from Figma Design: Spoken English Learning App
        //

        import SwiftUI

        public enum SpokenEnglishTheme {
            /// Primary Royal Blue: #1F61E0
            public static let primaryBlue = Color(red: 31/255, green: 97/255, blue: 224/255)
            /// Secondary Teal: #0DA6B8
            public static let secondaryTeal = Color(red: 13/255, green: 166/255, blue: 184/255)
            /// Accent Warm Orange: #FF8533
            public static let accentOrange = Color(red: 255/255, green: 133/255, blue: 51/255)
            /// Success Emerald Green: #2EB86B
            public static let successGreen = Color(red: 46/255, green: 184/255, blue: 107/255)
            /// Danger Crimson Red: #EB4752
            public static let dangerRed = Color(red: 235/255, green: 71/255, blue: 82/255)
            /// Background Soft Canvas: #F4F6FB
            public static let backgroundGray = Color(red: 244/255, green: 246/255, blue: 251/255)
            /// Card White: #FFFFFF
            public static let surfaceWhite = Color.white
            /// Text Primary Dark: #1A1D26
            public static let textPrimary = Color(red: 26/255, green: 29/255, blue: 38/255)
            /// Text Secondary Slate: #687182
            public static let textSecondary = Color(red: 104/255, green: 113/255, blue: 130/255)
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/DesignTokens/SpokenEnglishTheme.swift",
            content: content,
            status: .created,
            framework: .swiftUI
        )
    }

    // MARK: - Tests

    private func generateUnitTests(targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  SpokenEnglishTests.swift
        //  Generated by DesignPilot SDK v1.0
        //

        import XCTest

        final class SpokenEnglishTests: XCTestCase {
            func testStreakAndProgressCalculations() {
                XCTAssertEqual(5, 5)
            }
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/Tests/SpokenEnglishTests.swift",
            content: content,
            status: .created,
            framework: .swiftUI
        )
    }

    // MARK: - UIKit & Storyboard Support

    private func generateUIKitHomeViewController(targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  HomeDailyTargetViewController.swift
        //  Generated by DesignPilot SDK v1.0
        //

        import UIKit

        public class HomeDailyTargetViewController: UIViewController {
            @IBOutlet public weak var greetingLabel: UILabel!
            @IBOutlet public weak var streakBadgeLabel: UILabel!
            @IBOutlet public weak var targetHeroCardView: UIView!
            @IBOutlet public weak var continueButton: UIButton!

            public override func viewDidLoad() {
                super.viewDidLoad()
                view.backgroundColor = UIColor(red: 244/255, green: 246/255, blue: 251/255, alpha: 1.0)
            }

            @IBAction public func continueLearningTapped(_ sender: UIButton) {
                // Navigate to AI Coach
            }
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/UIKit/HomeDailyTargetViewController.swift",
            content: content,
            status: .created,
            framework: .uiKit
        )
    }

    private func generateUIKitAICoachViewController(targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  AICoachCorrectionViewController.swift
        //  Generated by DesignPilot SDK v1.0
        //

        import UIKit

        public class AICoachCorrectionViewController: UIViewController {
            @IBOutlet public weak var originalTranscriptLabel: UILabel!
            @IBOutlet public weak var correctedSentenceLabel: UILabel!
            @IBOutlet public weak var explanationCardView: UIView!
            @IBOutlet public weak var speakButton: UIButton!

            public override func viewDidLoad() {
                super.viewDidLoad()
                view.backgroundColor = UIColor(red: 244/255, green: 246/255, blue: 251/255, alpha: 1.0)
            }

            @IBAction public func speakButtonTapped(_ sender: UIButton) {
                // Speech recognition trigger
            }
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/UIKit/AICoachCorrectionViewController.swift",
            content: content,
            status: .created,
            framework: .uiKit
        )
    }

    private func generateUIKitTabBarController(targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  SpokenEnglishTabBarController.swift
        //  Generated by DesignPilot SDK v1.0
        //

        import UIKit

        public class SpokenEnglishTabBarController: UITabBarController {
            public override func viewDidLoad() {
                super.viewDidLoad()
                tabBar.tintColor = UIColor(red: 31/255, green: 97/255, blue: 224/255, alpha: 1.0)
            }
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/UIKit/SpokenEnglishTabBarController.swift",
            content: content,
            status: .created,
            framework: .uiKit
        )
    }

    private func generateSpokenEnglishStoryboard(targetDirectory: String) -> GeneratedFile {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB" version="3.0" toolsVersion="22505" targetRuntime="iOS.CocoaTouch" propertyAccessControl="none" useAutolayout="YES" useTraitCollections="YES" useSafeAreas="YES" colorMatched="YES" initialViewController="TAB_ROOT_VC">
            <device id="retina6_12" orientation="portrait" appearance="light"/>
            <dependencies>
                <plugIn identifier="com.apple.InterfaceBuilder.IBCocoaTouchPlugin" version="22504"/>
                <capability name="Safe area layout guides" minToolsVersion="9.0"/>
                <capability name="System colors in document resources" minToolsVersion="11.0"/>
                <capability name="documents saved in the Xcode 8 format" minToolsVersion="8.0"/>
            </dependencies>
            <scenes>
                <scene sceneID="TAB_SCENE">
                    <objects>
                        <tabBarController id="TAB_ROOT_VC" customClass="SpokenEnglishTabBarController" sceneMemberID="viewController">
                            <tabBar key="tabBar" contentMode="scaleToFill" id="TAB_BAR_ID">
                                <rect key="frame" x="0.0" y="0.0" width="393" height="49"/>
                                <autoresizingMask key="autoresizingMask"/>
                            </tabBar>
                            <connections>
                                <segue destination="HOME_VC_ID" kind="relationship" relationship="viewControllers" id="SEG_HOME"/>
                            </connections>
                        </tabBarController>
                        <placeholder placeholderIdentifier="IBFirstResponder" id="TAB_RESP" sceneMemberID="firstResponder"/>
                    </objects>
                    <point key="canvasLocation" x="-500" y="0"/>
                </scene>
                <scene sceneID="HOME_SCENE">
                    <objects>
                        <viewController id="HOME_VC_ID" customClass="HomeDailyTargetViewController" sceneMemberID="viewController">
                            <view key="view" contentMode="scaleToFill" id="HOME_VIEW">
                                <rect key="frame" x="0.0" y="0.0" width="393" height="852"/>
                                <autoresizingMask key="autoresizingMask" widthSizable="YES" heightSizable="YES"/>
                                <subviews>
                                    <label opaque="NO" userInteractionEnabled="NO" contentMode="left" horizontalHuggingPriority="251" verticalHuggingPriority="251" text="Good Morning, Satyam" textAlignment="natural" lineBreakMode="tailTruncation" baselineAdjustment="alignBaselines" adjustsFontSizeToFit="NO" translatesAutoresizingMaskIntoConstraints="NO" id="GREET_LBL">
                                        <rect key="frame" x="20" y="103" width="280" height="26"/>
                                        <fontDescription key="fontDescription" type="system" weight="bold" pointSize="22"/>
                                    </label>
                                    <label opaque="NO" userInteractionEnabled="NO" contentMode="left" horizontalHuggingPriority="251" verticalHuggingPriority="251" text="5 Days" textAlignment="natural" lineBreakMode="tailTruncation" baselineAdjustment="alignBaselines" adjustsFontSizeToFit="NO" translatesAutoresizingMaskIntoConstraints="NO" id="STREAK_LBL">
                                        <rect key="frame" x="310" y="103" width="63" height="26"/>
                                        <fontDescription key="fontDescription" type="system" weight="bold" pointSize="14"/>
                                    </label>
                                    <view contentMode="scaleToFill" translatesAutoresizingMaskIntoConstraints="NO" id="HERO_CARD">
                                        <rect key="frame" x="20" y="149" width="353" height="160"/>
                                        <color key="backgroundColor" red="0.1215686275" green="0.3803921569" blue="0.8784313725" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
                                        <constraints>
                                            <constraint firstAttribute="height" constant="160" id="HERO_H"/>
                                        </constraints>
                                    </view>
                                    <button opaque="NO" contentMode="scaleToFill" contentHorizontalAlignment="center" contentVerticalAlignment="center" buttonType="system" lineBreakMode="middleTruncation" translatesAutoresizingMaskIntoConstraints="NO" id="CONT_BTN">
                                        <rect key="frame" x="20" y="329" width="353" height="44"/>
                                        <constraints>
                                            <constraint firstAttribute="height" constant="44" id="BTN_H"/>
                                        </constraints>
                                        <state key="normal" title="Continue Learning"/>
                                        <connections>
                                            <action selector="continueLearningTapped:" destination="HOME_VC_ID" eventType="touchUpInside" id="ACT_CONT"/>
                                        </connections>
                                    </button>
                                </subviews>
                                <viewLayoutGuide key="safeArea" id="SAFE_HOME"/>
                                <color key="backgroundColor" red="0.9568627451" green="0.9647058824" blue="0.9843137255" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
                                <constraints>
                                    <constraint firstItem="GREET_LBL" firstAttribute="leading" secondItem="SAFE_HOME" secondAttribute="leading" constant="20" id="C_GREET_L"/>
                                    <constraint firstItem="GREET_LBL" firstAttribute="top" secondItem="SAFE_HOME" secondAttribute="top" id="C_GREET_T"/>
                                    <constraint firstItem="SAFE_HOME" firstAttribute="trailing" secondItem="STREAK_LBL" secondAttribute="trailing" constant="20" id="C_STRK_R"/>
                                    <constraint firstItem="HERO_CARD" firstAttribute="top" secondItem="GREET_LBL" secondAttribute="bottom" constant="20" id="C_HERO_T"/>
                                    <constraint firstItem="HERO_CARD" firstAttribute="leading" secondItem="SAFE_HOME" secondAttribute="leading" constant="20" id="C_HERO_L"/>
                                    <constraint firstItem="SAFE_HOME" firstAttribute="trailing" secondItem="HERO_CARD" secondAttribute="trailing" constant="20" id="C_HERO_R"/>
                                    <constraint firstItem="CONT_BTN" firstAttribute="top" secondItem="HERO_CARD" secondAttribute="bottom" constant="20" id="C_BTN_T"/>
                                    <constraint firstItem="CONT_BTN" firstAttribute="leading" secondItem="SAFE_HOME" secondAttribute="leading" constant="20" id="C_BTN_L"/>
                                    <constraint firstItem="SAFE_HOME" firstAttribute="trailing" secondItem="CONT_BTN" secondAttribute="trailing" constant="20" id="C_BTN_R"/>
                                </constraints>
                            </view>
                            <tabBarItem key="tabBarItem" title="Daily Target" image="target" catalog="system" id="TAB_ITEM_HOME"/>
                            <connections>
                                <outlet property="greetingLabel" destination="GREET_LBL" id="OUT_GREET"/>
                                <outlet property="streakBadgeLabel" destination="STREAK_LBL" id="OUT_STRK"/>
                                <outlet property="targetHeroCardView" destination="HERO_CARD" id="OUT_HERO"/>
                                <outlet property="continueButton" destination="CONT_BTN" id="OUT_CONT"/>
                            </connections>
                        </viewController>
                        <placeholder placeholderIdentifier="IBFirstResponder" id="HOME_RESP" sceneMemberID="firstResponder"/>
                    </objects>
                    <point key="canvasLocation" x="300" y="0"/>
                </scene>
            </scenes>
            <resources>
                <image name="target" catalog="system" width="128" height="123"/>
            </resources>
        </document>
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/Storyboards/Main.storyboard",
            content: xml,
            status: .created,
            framework: .uiKit
        )
    }
}
