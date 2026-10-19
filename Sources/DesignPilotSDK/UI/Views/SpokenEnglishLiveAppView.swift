import SwiftUI

/// Color tokens extracted directly from the Spoken English Figma design palette.
public enum SpokenEnglishLiveTheme {
    public static let primaryBlue = Color(red: 31/255, green: 97/255, blue: 224/255)      // #1F61E0
    public static let secondaryTeal = Color(red: 13/255, green: 166/255, blue: 184/255)   // #0DA6B8
    public static let accentOrange = Color(red: 255/255, green: 133/255, blue: 51/255)    // #FF8533
    public static let emeraldGreen = Color(red: 46/255, green: 184/255, blue: 107/255)    // #2EB86B
    public static let crimsonDanger = Color(red: 235/255, green: 71/255, blue: 82/255)    // #EB4752
    public static let backgroundCanvas = Color(red: 244/255, green: 246/255, blue: 251/255) // #F4F6FB
    public static let surfaceWhite = Color.white
    public static let textPrimary = Color(red: 26/255, green: 29/255, blue: 38/255)       // #1A1D26
    public static let textSecondary = Color(red: 104/255, green: 113/255, blue: 130/255)  // #687182
    public static let dividerGray = Color(red: 228/255, green: 233/255, blue: 242/255)
}

/// The 6 screens identified from the Spoken English Figma design.
public enum SpokenEnglishScreenTab: String, CaseIterable, Identifiable {
    case target = "Daily Target"
    case aiCoach = "AI Coach"
    case roadmap = "90-Day Plan"
    case vocabulary = "Vocabulary"
    case translator = "Translator"
    case shadowing = "Pronunciation"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .target: return "target"
        case .aiCoach: return "sparkles.bubble.fill"
        case .roadmap: return "map.fill"
        case .vocabulary: return "text.book.closed.fill"
        case .translator: return "character.bubble.fill"
        case .shadowing: return "waveform"
        }
    }
}

/// Interactive live preview container faithfully reproducing the 6 Spoken English screens.
public struct SpokenEnglishLiveAppView: View {
    public let result: GenerationResult
    public let onBackToGenerator: () -> Void
    public let onInspectArchitecture: () -> Void

    @State private var activeTab: SpokenEnglishScreenTab = .target

    // Screen 1: Daily Target state
    @State private var checkedItems: Set<Int> = [0, 1, 2]

    // Screen 2: AI Coach state
    @State private var isRecording: Bool = false
    @State private var hasPracticedCorrection: Bool = false

    // Screen 4: Vocabulary state
    @State private var isWordBookmarked: Bool = true
    @State private var isPlayingAudio: Bool = false

    // Screen 5: Translator state
    @State private var sourceText: String = "Yesterday, I had lunch with my family."
    @State private var selectedLanguage: String = "Hindi (हिन्दी)"
    @State private var copiedToast: Bool = false

    // Screen 6: Shadowing state
    @State private var selectedSpeed: Double = 1.0
    @State private var isShadowingActive: Bool = false

    public init(
        result: GenerationResult,
        onBackToGenerator: @escaping () -> Void,
        onInspectArchitecture: @escaping () -> Void
    ) {
        self.result = result
        self.onBackToGenerator = onBackToGenerator
        self.onInspectArchitecture = onInspectArchitecture
    }

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                SpokenEnglishLiveTheme.backgroundCanvas
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    developerHUDHeader
                        .padding(.top, 4)
                        .padding(.bottom, 6)

                    screenTabSelector
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)

                    // Active Figma Screen
                    ScrollView(.vertical, showsIndicators: false) {
                        Group {
                            switch activeTab {
                            case .target:
                                dailyTargetScreen
                            case .aiCoach:
                                aiCoachScreen
                            case .roadmap:
                                roadmapScreen
                            case .vocabulary:
                                vocabularyScreen
                            case .translator:
                                translatorScreen
                            case .shadowing:
                                shadowingScreen
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 90)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                // Floating 6-Tab Navigation Bar
                bottomTabBar
            }
        }
    }

    // MARK: - Developer HUD Header

    private var developerHUDHeader: some View {
        HStack(spacing: 12) {
            Button(action: onBackToGenerator) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Generator")
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(SpokenEnglishLiveTheme.primaryBlue)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(SpokenEnglishLiveTheme.primaryBlue.opacity(0.10))
                .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Spoken English Learning App")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(SpokenEnglishLiveTheme.textPrimary)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Text("Figma Node: \(result.figmaURL?.nodeId ?? "0:1")")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(SpokenEnglishLiveTheme.textSecondary)
                    Circle().fill(SpokenEnglishLiveTheme.emeraldGreen).frame(width: 5, height: 5)
                    Text("Live Preview")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(SpokenEnglishLiveTheme.emeraldGreen)
                }
            }

            Spacer()

            Button(action: onInspectArchitecture) {
                HStack(spacing: 4) {
                    Image(systemName: "doc.text.magnifyingglass")
                    Text("Inspect")
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(SpokenEnglishLiveTheme.primaryBlue)
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Top Tab Selector

    private var screenTabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(SpokenEnglishScreenTab.allCases) { tab in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            activeTab = tab
                        }
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: tab.iconName)
                                .font(.system(size: 11, weight: .semibold))
                            Text(tab.rawValue)
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(activeTab == tab ? .white : SpokenEnglishLiveTheme.textSecondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(
                            activeTab == tab ?
                            SpokenEnglishLiveTheme.primaryBlue :
                            Color.white
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(activeTab == tab ? 0.12 : 0.03), radius: 4, y: 2)
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }

    // MARK: - Screen 1: Daily Target & Progress

    private var dailyTargetScreen: some View {
        VStack(spacing: 16) {
            // User Header Card
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [SpokenEnglishLiveTheme.primaryBlue, SpokenEnglishLiveTheme.secondaryTeal],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 52, height: 52)
                    Text("S")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Good Morning, Satyam")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(SpokenEnglishLiveTheme.textPrimary)
                    HStack(spacing: 8) {
                        Text("Level: Beginner (A1)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(SpokenEnglishLiveTheme.primaryBlue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(SpokenEnglishLiveTheme.primaryBlue.opacity(0.10))
                            .clipShape(Capsule())

                        Text("Day 2 of 90")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(SpokenEnglishLiveTheme.textSecondary)
                    }
                }

                Spacer()

                // Streak Flame Card
                VStack(spacing: 2) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 20))
                        .foregroundColor(SpokenEnglishLiveTheme.accentOrange)
                    Text("5 Days")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(SpokenEnglishLiveTheme.textPrimary)
                    Text("Streak")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(SpokenEnglishLiveTheme.textSecondary)
                }
                .padding(8)
                .background(SpokenEnglishLiveTheme.accentOrange.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(16)
            .background(SpokenEnglishLiveTheme.surfaceWhite)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color.black.opacity(0.04), radius: 6, y: 3)

            // Today's Goal Progress Card
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Today's Progress")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(SpokenEnglishLiveTheme.textPrimary)
                        Text("3 of 5 daily exercises completed")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(SpokenEnglishLiveTheme.textSecondary)
                    }
                    Spacer()
                    Text("60%")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(SpokenEnglishLiveTheme.primaryBlue)
                }

                // Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(SpokenEnglishLiveTheme.dividerGray)
                            .frame(height: 10)
                        Capsule()
                            .fill(LinearGradient(
                                colors: [SpokenEnglishLiveTheme.primaryBlue, SpokenEnglishLiveTheme.secondaryTeal],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: geo.size.width * 0.60, height: 10)
                    }
                }
                .frame(height: 10)
            }
            .padding(16)
            .background(SpokenEnglishLiveTheme.surfaceWhite)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color.black.opacity(0.04), radius: 6, y: 3)

            // 6-Pillar Daily Checklist
            VStack(alignment: .leading, spacing: 12) {
                Text("Today's Learning Pillars")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(SpokenEnglishLiveTheme.textPrimary)

                VStack(spacing: 10) {
                    pillarCheckItem(index: 0, title: "1. Spoken Audio Practice", subtitle: "15 min daily conversational drills", icon: "waveform.circle.fill", color: SpokenEnglishLiveTheme.primaryBlue)
                    pillarCheckItem(index: 1, title: "2. AI Sentence Doctor", subtitle: "Speak a sentence & receive live corrections", icon: "sparkles", color: SpokenEnglishLiveTheme.emeraldGreen)
                    pillarCheckItem(index: 2, title: "3. Word of the Day", subtitle: "Learn 'Eloquent' in English & Hindi", icon: "text.book.closed.fill", color: SpokenEnglishLiveTheme.accentOrange)
                    pillarCheckItem(index: 3, title: "4. Pronunciation Shadowing", subtitle: "Match syllable intonation & rhythm", icon: "mic.fill", color: SpokenEnglishLiveTheme.secondaryTeal)
                    pillarCheckItem(index: 4, title: "5. Smart Translator Practice", subtitle: "Translate & listen across 15 languages", icon: "character.bubble.fill", color: Color.purple)
                    pillarCheckItem(index: 5, title: "6. 90-Day Milestone Review", subtitle: "Track week 1 foundation milestones", icon: "flag.fill", color: Color.pink)
                }
            }
            .padding(16)
            .background(SpokenEnglishLiveTheme.surfaceWhite)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color.black.opacity(0.04), radius: 6, y: 3)

            // Primary Action Button
            Button(action: {
                withAnimation { activeTab = .aiCoach }
            }) {
                HStack(spacing: 8) {
                    Text("Continue Day 2 Lesson")
                        .font(.system(size: 16, weight: .bold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(LinearGradient(
                    colors: [SpokenEnglishLiveTheme.primaryBlue, Color(hex: "1749B3")],
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: SpokenEnglishLiveTheme.primaryBlue.opacity(0.35), radius: 10, y: 5)
            }
        }
    }

    private func pillarCheckItem(index: Int, title: String, subtitle: String, icon: String, color: Color) -> some View {
        let isDone = checkedItems.contains(index)
        return Button(action: {
            if isDone {
                checkedItems.remove(index)
            } else {
                checkedItems.insert(index)
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isDone ? SpokenEnglishLiveTheme.emeraldGreen : SpokenEnglishLiveTheme.textSecondary.opacity(0.5))

                ZStack {
                    Circle()
                        .fill(color.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(SpokenEnglishLiveTheme.textPrimary)
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(SpokenEnglishLiveTheme.textSecondary)
                }

                Spacer()
            }
            .padding(10)
            .background(isDone ? SpokenEnglishLiveTheme.emeraldGreen.opacity(0.04) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Screen 2: AI Speech Coach & Sentence Correction

    private var aiCoachScreen: some View {
        VStack(spacing: 16) {
            // Coach Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(SpokenEnglishLiveTheme.emeraldGreen.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: "sparkles")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(SpokenEnglishLiveTheme.emeraldGreen)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("AI Sentence Doctor")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(SpokenEnglishLiveTheme.textPrimary)
                    Text("Real-time grammar & natural phrasing coach")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(SpokenEnglishLiveTheme.textSecondary)
                }
                Spacer()
            }
            .padding(14)
            .background(SpokenEnglishLiveTheme.surfaceWhite)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // User Speech Bubble (Incorrect/Awkward)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("YOU SAID")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(SpokenEnglishLiveTheme.crimsonDanger)
                    Spacer()
                    Image(systemName: "mic.fill")
                        .font(.system(size: 12))
                        .foregroundColor(SpokenEnglishLiveTheme.textSecondary)
                }

                Text("Yesterday, I ate food.")
                    .font(.system(size: 18, weight: .medium))
                    .strikethrough(color: SpokenEnglishLiveTheme.crimsonDanger)
                    .foregroundColor(SpokenEnglishLiveTheme.crimsonDanger)
                    .padding(.vertical, 4)

                Text("Grammatically correct, but sounds robotic and unnatural in everyday conversation.")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(SpokenEnglishLiveTheme.textSecondary)
            }
            .padding(16)
            .background(SpokenEnglishLiveTheme.crimsonDanger.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(SpokenEnglishLiveTheme.crimsonDanger.opacity(0.20), lineWidth: 1)
            )

            // AI Coach Correction Bubble (Natural English)
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 13))
                            .foregroundColor(SpokenEnglishLiveTheme.emeraldGreen)
                        Text("NATURAL NATIVE ENGLISH")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(SpokenEnglishLiveTheme.emeraldGreen)
                    }
                    Spacer()
                    Button(action: {
                        isPlayingAudio.toggle()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: isPlayingAudio ? "speaker.wave.3.fill" : "speaker.wave.2")
                            Text("Listen")
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(SpokenEnglishLiveTheme.primaryBlue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(SpokenEnglishLiveTheme.primaryBlue.opacity(0.10))
                        .clipShape(Capsule())
                    }
                }

                Text("Yesterday, I had a meal.")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(SpokenEnglishLiveTheme.emeraldGreen)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Or naturally:")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(SpokenEnglishLiveTheme.textSecondary)
                    HStack(spacing: 8) {
                        Text("\"I grabbed a bite yesterday.\"")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(SpokenEnglishLiveTheme.textPrimary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(SpokenEnglishLiveTheme.backgroundCanvas)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        Text("\"I had lunch/dinner.\"")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(SpokenEnglishLiveTheme.textPrimary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(SpokenEnglishLiveTheme.backgroundCanvas)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Why this sounds better:")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(SpokenEnglishLiveTheme.textPrimary)
                    Text("Native speakers rarely say 'ate food' because 'ate' already implies food. Using 'had a meal' or 'grabbed a bite' sounds fluent and natural.")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(SpokenEnglishLiveTheme.textSecondary)
                }
            }
            .padding(16)
            .background(SpokenEnglishLiveTheme.surfaceWhite)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color.black.opacity(0.04), radius: 6, y: 3)

            // Voice Recording Bar
            VStack(spacing: 12) {
                Text(isRecording ? "Listening... Speak your sentence now" : "Tap microphone to test another sentence")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isRecording ? SpokenEnglishLiveTheme.crimsonDanger : SpokenEnglishLiveTheme.textSecondary)

                Button(action: {
                    withAnimation { isRecording.toggle() }
                }) {
                    ZStack {
                        Circle()
                            .fill(isRecording ? SpokenEnglishLiveTheme.crimsonDanger : SpokenEnglishLiveTheme.primaryBlue)
                            .frame(width: 64, height: 64)
                            .shadow(color: (isRecording ? SpokenEnglishLiveTheme.crimsonDanger : SpokenEnglishLiveTheme.primaryBlue).opacity(0.4), radius: 10, y: 5)
                        Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.vertical, 12)

            // Practice Button
            Button(action: {
                hasPracticedCorrection = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: hasPracticedCorrection ? "checkmark.circle.fill" : "arrow.triangle.2.circlepath")
                    Text(hasPracticedCorrection ? "Practiced! +10 XP" : "I've Practiced It Out Loud")
                }
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(hasPracticedCorrection ? SpokenEnglishLiveTheme.emeraldGreen : SpokenEnglishLiveTheme.primaryBlue)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    // MARK: - Screen 3: 90-Day Visual Roadmap

    private var roadmapScreen: some View {
        VStack(spacing: 16) {
            // Roadmap Hero Card
            VStack(alignment: .leading, spacing: 6) {
                Text("90-Day Spoken English Roadmap")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(SpokenEnglishLiveTheme.textPrimary)
                Text("A systematic daily path from Beginner A1 to Confident Native-like Speaker")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(SpokenEnglishLiveTheme.textSecondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(SpokenEnglishLiveTheme.surfaceWhite)
            .clipShape(RoundedRectangle(cornerRadius: 18))

            // Month 1: Foundations (ACTIVE)
            roadmapMonthSection(
                monthNumber: 1,
                title: "Month 1: Foundations & Daily Rhythm",
                status: "ACTIVE • Day 2 / 30",
                daysCount: "Days 1 - 30",
                isCurrent: true,
                pillars: [
                    "Day 1: Sentence Starter Templates (Completed)",
                    "Day 2: Natural Food & Daily Activity Phrasing (Today)",
                    "Day 5: Present vs Continuous Spoken Audio Drills",
                    "Day 10: Eliminating Awkward Literal Translations",
                    "Day 20: Phone Call & Casual Greeting Scenarios",
                    "Day 30: Month 1 Fluency Speech Assessment"
                ]
            )

            // Month 2: Fluency & Speed (LOCKED)
            roadmapMonthSection(
                monthNumber: 2,
                title: "Month 2: Fluency, Expressions & Idioms",
                status: "LOCKED • Unlocks Day 31",
                daysCount: "Days 31 - 60",
                isCurrent: false,
                pillars: [
                    "Days 31-40: Linking Words & Natural Connectors",
                    "Days 41-50: American & British Native Phrasing",
                    "Days 51-60: Professional Meetings & Presentations"
                ]
            )

            // Month 3: Mastery & Public Speaking (LOCKED)
            roadmapMonthSection(
                monthNumber: 3,
                title: "Month 3: Mastery & Debate",
                status: "LOCKED • Unlocks Day 61",
                daysCount: "Days 61 - 90",
                isCurrent: false,
                pillars: [
                    "Days 61-75: Spontaneous Thinking & Instant Translation Exit",
                    "Days 76-90: Group Discussion & Interview Mastery"
                ]
            )
        }
    }

    private func roadmapMonthSection(
        monthNumber: Int,
        title: String,
        status: String,
        daysCount: String,
        isCurrent: Bool,
        pillars: [String]
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(isCurrent ? SpokenEnglishLiveTheme.primaryBlue : SpokenEnglishLiveTheme.dividerGray)
                        .frame(width: 34, height: 34)
                    Text("\(monthNumber)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(isCurrent ? .white : SpokenEnglishLiveTheme.textSecondary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(SpokenEnglishLiveTheme.textPrimary)
                    Text(status)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(isCurrent ? SpokenEnglishLiveTheme.primaryBlue : SpokenEnglishLiveTheme.textSecondary)
                }
                Spacer()
                Text(daysCount)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(SpokenEnglishLiveTheme.textSecondary)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                ForEach(pillars, id: \.self) { pillar in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: isCurrent && pillar.contains("Completed") ? "checkmark.circle.fill" : (isCurrent && pillar.contains("Today") ? "arrow.right.circle.fill" : "circle"))
                            .font(.system(size: 13))
                            .foregroundColor(isCurrent && pillar.contains("Completed") ? SpokenEnglishLiveTheme.emeraldGreen : (isCurrent && pillar.contains("Today") ? SpokenEnglishLiveTheme.primaryBlue : SpokenEnglishLiveTheme.textSecondary.opacity(0.4)))
                            .padding(.top, 2)
                        Text(pillar)
                            .font(.system(size: 13, weight: pillar.contains("Today") ? .bold : .regular))
                            .foregroundColor(SpokenEnglishLiveTheme.textPrimary)
                    }
                }
            }
        }
        .padding(16)
        .background(SpokenEnglishLiveTheme.surfaceWhite)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .opacity(isCurrent ? 1.0 : 0.75)
    }

    // MARK: - Screen 4: Multilingual Vocabulary

    private var vocabularyScreen: some View {
        VStack(spacing: 16) {
            // Word of the Day Hero Card
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("WORD OF THE DAY")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(SpokenEnglishLiveTheme.accentOrange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(SpokenEnglishLiveTheme.accentOrange.opacity(0.12))
                        .clipShape(Capsule())

                    Spacer()

                    Button(action: {
                        isWordBookmarked.toggle()
                    }) {
                        Image(systemName: isWordBookmarked ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 18))
                            .foregroundColor(isWordBookmarked ? SpokenEnglishLiveTheme.primaryBlue : SpokenEnglishLiveTheme.textSecondary)
                    }
                }

                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text("Eloquent")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(SpokenEnglishLiveTheme.textPrimary)

                    Text("/ˈel.ə.kwənt/")
                        .font(.system(size: 15, weight: .medium, design: .monospaced))
                        .foregroundColor(SpokenEnglishLiveTheme.textSecondary)

                    Spacer()

                    Button(action: { isPlayingAudio.toggle() }) {
                        Image(systemName: "speaker.wave.2.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(SpokenEnglishLiveTheme.primaryBlue)
                    }
                }

                // Hindi Meaning Badge (Figma Exact)
                HStack(spacing: 8) {
                    Text("हिन्दी अर्थ:")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(SpokenEnglishLiveTheme.accentOrange)
                    Text("वाक्पटु / सुवक्ता / प्रभावशाली वक्ता")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(SpokenEnglishLiveTheme.textPrimary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(SpokenEnglishLiveTheme.accentOrange.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 10))

                // Part of Speech & Definition
                VStack(alignment: .leading, spacing: 4) {
                    Text("adjective")
                        .font(.system(size: 12, weight: .semibold))
                        .italic()
                        .foregroundColor(SpokenEnglishLiveTheme.secondaryTeal)
                    Text("Fluent or persuasive in speaking or writing; expressing things clearly.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(SpokenEnglishLiveTheme.textPrimary)
                }

                Divider()

                // Context Example Sentence
                VStack(alignment: .leading, spacing: 6) {
                    Text("Example in conversation:")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(SpokenEnglishLiveTheme.textSecondary)
                    Text("\"His eloquent speech convinced the entire committee to approve the proposal.\"")
                        .font(.system(size: 14, weight: .medium))
                        .italic()
                        .foregroundColor(SpokenEnglishLiveTheme.textPrimary)
                }
            }
            .padding(18)
            .background(SpokenEnglishLiveTheme.surfaceWhite)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.black.opacity(0.04), radius: 6, y: 3)

            // Additional Curated Words for Day 2
            VStack(alignment: .leading, spacing: 12) {
                Text("Today's Spoken English Words")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(SpokenEnglishLiveTheme.textPrimary)

                vocabWordRow(word: "Articulate", hindi: "स्पष्ट रूप से व्यक्त करना", pos: "verb / adj")
                vocabWordRow(word: "Spontaneous", hindi: "स्वाभाविक / तुरंत", pos: "adjective")
                vocabWordRow(word: "Hesitation", hindi: "हिचकिचाहट", pos: "noun")
                vocabWordRow(word: "Impromptu", hindi: "बिना तैयारी के बोला गया", pos: "adjective")
            }
            .padding(16)
            .background(SpokenEnglishLiveTheme.surfaceWhite)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }

    private func vocabWordRow(word: String, hindi: String, pos: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text(word)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(SpokenEnglishLiveTheme.textPrimary)
                    Text("(\(pos))")
                        .font(.system(size: 11))
                        .italic()
                        .foregroundColor(SpokenEnglishLiveTheme.textSecondary)
                }
                Text("हिन्दी: \(hindi)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(SpokenEnglishLiveTheme.accentOrange)
            }
            Spacer()
            Button(action: {}) {
                Image(systemName: "speaker.wave.1")
                    .font(.system(size: 14))
                    .foregroundColor(SpokenEnglishLiveTheme.primaryBlue)
                    .padding(8)
                    .background(SpokenEnglishLiveTheme.primaryBlue.opacity(0.08))
                    .clipShape(Circle())
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Screen 5: 15-Language Smart Translator

    private var translatorScreen: some View {
        VStack(spacing: 16) {
            // Language Selector Bar
            HStack {
                Text("English")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(SpokenEnglishLiveTheme.primaryBlue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(SpokenEnglishLiveTheme.primaryBlue.opacity(0.10))
                    .clipShape(Capsule())

                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(SpokenEnglishLiveTheme.textSecondary)

                Menu {
                    Button("Hindi (हिन्दी)") { selectedLanguage = "Hindi (हिन्दी)" }
                    Button("Spanish (Español)") { selectedLanguage = "Spanish (Español)" }
                    Button("French (Français)") { selectedLanguage = "French (Français)" }
                    Button("German (Deutsch)") { selectedLanguage = "German (Deutsch)" }
                    Button("Japanese (日本語)") { selectedLanguage = "Japanese (日本語)" }
                } label: {
                    HStack(spacing: 4) {
                        Text(selectedLanguage)
                            .font(.system(size: 14, weight: .bold))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(SpokenEnglishLiveTheme.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(SpokenEnglishLiveTheme.surfaceWhite)
                    .clipShape(Capsule())
                }
                Spacer()
            }

            // Input Card
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("ENGLISH INPUT")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(SpokenEnglishLiveTheme.textSecondary)
                    Spacer()
                    Button(action: { sourceText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(SpokenEnglishLiveTheme.textSecondary.opacity(0.6))
                    }
                }

                TextField("Type or paste English sentence", text: $sourceText, axis: .vertical)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(SpokenEnglishLiveTheme.textPrimary)
                    .lineLimit(3)

                HStack {
                    Button(action: {}) {
                        HStack(spacing: 4) {
                            Image(systemName: "speaker.wave.2")
                            Text("Listen")
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(SpokenEnglishLiveTheme.primaryBlue)
                    }
                    Spacer()
                    Image(systemName: "mic.fill")
                        .foregroundColor(SpokenEnglishLiveTheme.primaryBlue)
                }
            }
            .padding(16)
            .background(SpokenEnglishLiveTheme.surfaceWhite)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color.black.opacity(0.04), radius: 6, y: 3)

            // Output Card (Hindi)
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("TRANSLATION (\(selectedLanguage))")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(SpokenEnglishLiveTheme.emeraldGreen)
                    Spacer()
                    Button(action: {
                        copiedToast = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            copiedToast = false
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: copiedToast ? "checkmark" : "doc.on.doc")
                            Text(copiedToast ? "Copied" : "Copy")
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(SpokenEnglishLiveTheme.emeraldGreen)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(SpokenEnglishLiveTheme.emeraldGreen.opacity(0.12))
                        .clipShape(Capsule())
                    }
                }

                Text("कल मैंने अपने परिवार के साथ भोजन किया था।")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(SpokenEnglishLiveTheme.textPrimary)

                // Phonetic Guide
                VStack(alignment: .leading, spacing: 2) {
                    Text("Phonetic Pronunciation:")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(SpokenEnglishLiveTheme.textSecondary)
                    Text("Kal maine apne parivaar ke saath bhojan kiya tha.")
                        .font(.system(size: 13, weight: .medium))
                        .italic()
                        .foregroundColor(SpokenEnglishLiveTheme.textSecondary)
                }
                .padding(10)
                .background(SpokenEnglishLiveTheme.backgroundCanvas)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                Button(action: {}) {
                    HStack(spacing: 6) {
                        Image(systemName: "speaker.wave.3.fill")
                        Text("Pronounce Translation")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(SpokenEnglishLiveTheme.emeraldGreen)
                }
            }
            .padding(16)
            .background(SpokenEnglishLiveTheme.surfaceWhite)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color.black.opacity(0.04), radius: 6, y: 3)
        }
    }

    // MARK: - Screen 6: Shadowing & Fluency Lab

    private var shadowingScreen: some View {
        VStack(spacing: 16) {
            // Reference Sentence Card
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("SHADOWING DRILL • LEVEL A1")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(SpokenEnglishLiveTheme.primaryBlue)
                    Spacer()
                    // Speed Selector
                    HStack(spacing: 4) {
                        ForEach([0.75, 1.0, 1.25], id: \.self) { speed in
                            Button(action: { selectedSpeed = speed }) {
                                Text("\(String(format: "%.2g", speed))x")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(selectedSpeed == speed ? .white : SpokenEnglishLiveTheme.textSecondary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(selectedSpeed == speed ? SpokenEnglishLiveTheme.primaryBlue : SpokenEnglishLiveTheme.dividerGray)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }

                Text("Consistency is the key to mastering spoken English.")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(SpokenEnglishLiveTheme.textPrimary)

                // Syllable Breakdown
                HStack(spacing: 6) {
                    syllableTag("Con-")
                    syllableTag("sis-")
                    syllableTag("ten-")
                    syllableTag("cy")
                    Text("is the key...")
                        .font(.system(size: 12))
                        .foregroundColor(SpokenEnglishLiveTheme.textSecondary)
                }
            }
            .padding(16)
            .background(SpokenEnglishLiveTheme.surfaceWhite)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color.black.opacity(0.04), radius: 6, y: 3)

            // Circular Fluency Score Gauge (Figma Exact 94%)
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(SpokenEnglishLiveTheme.dividerGray, lineWidth: 14)
                        .frame(width: 140, height: 140)

                    Circle()
                        .trim(from: 0, to: 0.94)
                        .stroke(
                            LinearGradient(
                                colors: [SpokenEnglishLiveTheme.emeraldGreen, SpokenEnglishLiveTheme.secondaryTeal],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 2) {
                        Text("94%")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(SpokenEnglishLiveTheme.textPrimary)
                        Text("Fluency Score")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(SpokenEnglishLiveTheme.emeraldGreen)
                    }
                }

                Text("Excellent pacing and clear syllable intonation!")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(SpokenEnglishLiveTheme.textSecondary)
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(SpokenEnglishLiveTheme.surfaceWhite)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.black.opacity(0.04), radius: 6, y: 3)

            // 6-Dimension Diagnostics
            VStack(alignment: .leading, spacing: 10) {
                Text("Pronunciation Diagnostics")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(SpokenEnglishLiveTheme.textPrimary)

                diagnosticMetric(name: "Clarity", score: 98, color: SpokenEnglishLiveTheme.emeraldGreen)
                diagnosticMetric(name: "Intonation", score: 96, color: SpokenEnglishLiveTheme.emeraldGreen)
                diagnosticMetric(name: "Pitch", score: 95, color: SpokenEnglishLiveTheme.primaryBlue)
                diagnosticMetric(name: "Stress Patterns", score: 94, color: SpokenEnglishLiveTheme.primaryBlue)
                diagnosticMetric(name: "Rhythm", score: 92, color: SpokenEnglishLiveTheme.secondaryTeal)
                diagnosticMetric(name: "Pace", score: 91, color: SpokenEnglishLiveTheme.accentOrange)
            }
            .padding(16)
            .background(SpokenEnglishLiveTheme.surfaceWhite)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }

    private func syllableTag(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(SpokenEnglishLiveTheme.primaryBlue)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(SpokenEnglishLiveTheme.primaryBlue.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func diagnosticMetric(name: String, score: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack {
                Text(name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(SpokenEnglishLiveTheme.textPrimary)
                Spacer()
                Text("\(score)%")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(color)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(SpokenEnglishLiveTheme.dividerGray).frame(height: 6)
                    Capsule().fill(color).frame(width: geo.size.width * CGFloat(score) / 100.0, height: 6)
                }
            }
            .frame(height: 6)
        }
    }

    // MARK: - Bottom Floating 6-Tab Bar

    private var bottomTabBar: some View {
        HStack(spacing: 0) {
            ForEach(SpokenEnglishScreenTab.allCases) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        activeTab = tab
                    }
                }) {
                    VStack(spacing: 3) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 16, weight: activeTab == tab ? .bold : .regular))
                            .foregroundColor(activeTab == tab ? SpokenEnglishLiveTheme.primaryBlue : SpokenEnglishLiveTheme.textSecondary)

                        Text(tab.rawValue)
                            .font(.system(size: 9, weight: activeTab == tab ? .bold : .medium))
                            .foregroundColor(activeTab == tab ? SpokenEnglishLiveTheme.primaryBlue : SpokenEnglishLiveTheme.textSecondary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 6)
        .background(
            SpokenEnglishLiveTheme.surfaceWhite
                .shadow(color: Color.black.opacity(0.08), radius: 10, y: -2)
        )
    }
}
