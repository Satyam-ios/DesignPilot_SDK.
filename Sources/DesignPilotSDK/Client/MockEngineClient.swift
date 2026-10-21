import Foundation

/// High-fidelity client implementation used for previews, tests, and standalone demo exploration.
public struct MockEngineClient: EngineClientProtocol {
    public init() {}

    public func checkHealth() async throws -> EngineHealth {
        return EngineHealth(
            isAlive: true,
            version: "1.0.0-mock",
            xcodeAvailable: true,
            activeProject: "CheckDesignPilotWork.xcodeproj"
        )
    }

    public func validateAccess(url: FigmaURL, token: String?) async throws -> Bool {
        try await Task.sleep(nanoseconds: 300_000_000)
        if url.fileKey.contains("invalid") || url.fileKey.count < 5 {
            throw DesignPilotError.figmaAccessDenied(reason: "Resource not found or invalid file key.")
        }
        return true
    }

    public func generate(
        request: GenerationRequest,
        onProgress: @Sendable @escaping (PipelineStage, Double, String) -> Void
    ) async throws -> GenerationResult {
        let isPDF = request.source.isPDF
        let urlStr = request.source.figmaURL?.rawString.lowercased() ?? ""
        let docTitle = request.source.figmaURL?.documentTitle?.lowercased() ?? ""
        let isBike = urlStr.contains("bike") || docTitle.contains("bike")
        let isSpoken = !isBike

        // Stage 1: Validating URL or Document
        onProgress(
            .validatingURL,
            0.10,
            isPDF ? "Verifying design document structure..." :
            "Verifying Figma access and permissions..."
        )
        try await Task.sleep(nanoseconds: 200_000_000)

        // Stage 2: Reading Design Hierarchy
        onProgress(
            .fetchingDesign,
            0.22,
            isSpoken ? "Retrieved 32 AutoLayout frames, 6 primary screens, and 24 vector assets" : "Retrieved 32 AutoLayout frames, 6 primary screens, and 18 vector assets"
        )
        try await Task.sleep(nanoseconds: 200_000_000)

        // Stage 3: Discovering Screens & Reusable Components
        onProgress(
            .discoveringComponents,
            0.35,
            isSpoken ? "Identified 6 screens: Daily Target, AI Speech Coach, 90-Day Roadmap, Multilingual Vocab, Smart Translator, Shadowing Lab" : "Identified 6 screens: Catalog, Product Detail, Shopping Cart, GPS Route, Garage, Orders"
        )
        try await Task.sleep(nanoseconds: 200_000_000)

        // Stage 4: Planning Architecture
        onProgress(
            .planningArchitecture,
            0.48,
            isSpoken ? "Formulating modular MVVM architecture, SpokenEnglishRouter coordinator, and Services" : "Formulating modular MVVM architecture, BikeAppRouter coordinator, and Services"
        )
        try await Task.sleep(nanoseconds: 200_000_000)

        // Stage 5: Synthesizing Source Files
        onProgress(.synthesizingCode, 0.62, "Synthesizing views, view models, domain models, and service interfaces...")
        try await Task.sleep(nanoseconds: 250_000_000)

        // Stage 6: Integrating Navigation
        onProgress(.integratingNavigation, 0.74, "Wiring type-safe routes, coordinators, and transitions between screens...")
        try await Task.sleep(nanoseconds: 200_000_000)

        // Stage 7: Building Application
        onProgress(.buildingApp, 0.84, "Compiling generated application in Xcode / Swift toolchain...")
        try await Task.sleep(nanoseconds: 200_000_000)

        // Stage 8: Analyzing Build Diagnostics
        onProgress(.fixingBuildErrors, 0.90, "Auditing compiler diagnostics: 0 errors detected (clean build)")
        try await Task.sleep(nanoseconds: 150_000_000)

        // Stage 9: Running Automated Tests
        onProgress(
            .runningTests,
            0.95,
            isSpoken ? "Executed 6 unit tests for SpokenEnglishViewModel & Streak/Scoring algorithms (100% passed)" : "Executed 4 unit tests for ViewModel & Cart calculations (100% passed)"
        )
        try await Task.sleep(nanoseconds: 150_000_000)

        // Stage 10: Visual Validation
        onProgress(
            .visualValidation,
            0.98,
            isSpoken ? "Simulating layout on iPhone 16 Pro... (99.8% structural match to Figma design)" : "Simulating layout on iPhone 16 Pro... (99.4% structural match to Figma design)"
        )
        try await Task.sleep(nanoseconds: 150_000_000)

        return Self.synthesizeResult(for: request)
    }

    /// Provides immediate access to the synthesized generation result matching the configured Figma URL.
    public static func defaultPresetResult() -> GenerationResult {
        let currentURL = FigmaAppConfiguration.figmaURL
        let parsed = try? FigmaURL.parse(currentURL)
        let source: DesignSource
        if let p = parsed {
            source = .figmaURL(p)
        } else {
            let isBike = currentURL.lowercased().contains("bike")
            source = .figmaURL(FigmaURL(
                rawString: currentURL,
                fileKey: "z3bsh0M4MFRN7HvwWuYT7e",
                documentTitle: isBike ? "OnlineBikeShopping" : "Spoken_english",
                nodeId: "0:1"
            ))
        }
        let isUIKit = (FigmaAppConfiguration.uiFramework == .uiKit) || (FigmaAppConfiguration.uiFramework == .automatic && ProjectLocator.isHostProjectUIKit())
        let req = GenerationRequest(
            source: source,
            preferredFramework: isUIKit ? .uiKit : .swiftUI,
            targetDirectory: "Views/Generated",
            visualAcceptanceThreshold: 0.95,
            maxVisualIterations: 3
        )
        return synthesizeResult(for: req)
    }

    private static func synthesizeResult(for request: GenerationRequest) -> GenerationResult {
        let urlStr = request.source.figmaURL?.rawString.lowercased() ?? ""
        let docTitle = request.source.figmaURL?.documentTitle?.lowercased() ?? ""
        let isBike = urlStr.contains("bike") || docTitle.contains("bike")
        let isSpoken = !isBike

        if isSpoken {
            let output = SpokenEnglishArchitectureGenerator().generate(
                targetDirectory: request.targetDirectory,
                preferredFramework: request.preferredFramework
            )
            let visualDiff = VisualDiffReport(
                similarityScore: 0.998,
                acceptanceThreshold: request.visualAcceptanceThreshold,
                iterationCount: 1,
                testedDevices: ["iPhone 16 Pro", "iPhone 15 Pro Max"],
                discrepancies: []
            )
            let buildReport = BuildReport(
                isSuccess: true,
                durationSeconds: 1.1,
                compilerWarnings: [],
                compilerErrors: [],
                fixedErrorsCount: 0,
                targetEnvironment: "Apple Swift 6.0 (iOS 16.0+)",
                rawLog: "Build succeeded cleanly: 0 compiler errors."
            )
            let testReport = TestReport(
                totalTests: 6,
                passedTests: 6,
                failedTests: 0,
                durationSeconds: 0.32,
                testSuites: ["SpokenEnglishViewModelTests", "PronunciationScoreTests"],
                isSuccess: true
            )
            return GenerationResult(
                source: request.source,
                generatedFiles: output.files,
                tokens: output.tokens,
                visualDiff: visualDiff,
                screenName: "SpokenEnglishHome",
                architectureSummary: output.summary,
                buildReport: buildReport,
                testReport: testReport
            )
        }

        let screenTitle = "OnlineBikeCatalog"
        let sanitizedName = screenTitle

        let generatedSwiftUI = """
        //
        //  OnlineBikeCatalogView.swift
        //  Generated by DesignPilot SDK v1.0
        //  Figma Node: \(request.figmaURL?.nodeId ?? "0:1")
        //  Source: Online Bike Shopping App (Sourasith Phomhome)
        //

        import SwiftUI

        public struct OnlineBikeCatalogView: View {
            @State private var selectedCategory: String = "All"
            @State private var selectedTab: Int = 0
            @State private var isDetailPresented: Bool = false
            @State private var isCartPresented: Bool = false

            private let categories = ["All", "Bicycle", "Road", "Mountain", "Helmet"]

            public init() {}

            public var body: some View {
                ZStack(alignment: .bottom) {
                    Color(hex: "242C3B").ignoresSafeArea()

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20) {
                            headerBar
                            heroDiscountCard
                            categoryFilterPills
                            bikeProductsGrid
                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                    }

                    floatingTabBar
                }
                .navigationTitle("")
                .navigationBarHidden(true)
            }

            private var headerBar: some View {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Choose Your Bike")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button(action: {}) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "38B6FF"), Color(hex: "00F0FF")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 44, height: 44)
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
            }

            private var heroDiscountCard: some View {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "343E54"), Color(hex: "1F2633")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.2), Color.white.opacity(0.02)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )

                    VStack(alignment: .leading, spacing: 8) {
                        Text("30% Off")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.white)

                        Text("Futuristic White Carbon E-Bike")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "A0ABC0"))
                            .frame(maxWidth: 160, alignment: .leading)
                    }
                    .padding(24)
                }
                .frame(height: 160)
            }

            private var categoryFilterPills: some View {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \\.self) { cat in
                            Button(action: { selectedCategory = cat }) {
                                Text(cat)
                                    .font(.system(size: 14, weight: .semibold))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(
                                        selectedCategory == cat ?
                                        LinearGradient(
                                            colors: [Color(hex: "38B6FF"), Color(hex: "00F0FF")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ) :
                                        LinearGradient(
                                            colors: [Color(hex: "2B3445"), Color(hex: "2B3445")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }

            private var bikeProductsGrid: some View {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                    bikeCard(title: "PEUGEOT - LR01", subtitle: "Road Bike", price: "$ 1,999.99")
                    bikeCard(title: "SMITH - Trade", subtitle: "Helmet", price: "$ 120.00")
                    bikeCard(title: "PILOT - CHROMOLY 520", subtitle: "Mountain Bike", price: "$ 3,999.99")
                    bikeCard(title: "SPECIALIZED - Vado", subtitle: "Urban E-Bike", price: "$ 4,000.00")
                }
            }

            private func bikeCard(title: String, subtitle: String, price: String) -> some View {
                VStack(alignment: .leading, spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "1B2232"))
                            .frame(height: 120)
                        Image(systemName: "bicycle")
                            .font(.system(size: 48))
                            .foregroundColor(Color(hex: "38B6FF"))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(subtitle)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "A0ABC0"))
                        Text(title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text(price)
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(Color(hex: "00F0FF"))
                    }
                }
                .padding(14)
                .background(Color(hex: "242C3B"))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }

            private var floatingTabBar: some View {
                HStack(spacing: 36) {
                    tabItem(icon: "bicycle", index: 0)
                    tabItem(icon: "map.fill", index: 1)
                    tabItem(icon: "cart.fill", index: 2, badge: "3")
                    tabItem(icon: "person.crop.circle.fill", index: 3)
                    tabItem(icon: "shippingbox.fill", index: 4)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(Color(hex: "1B2232").opacity(0.95))
                .clipShape(Capsule())
                .padding(.bottom, 16)
            }

            private func tabItem(icon: String, index: Int, badge: String? = nil) -> some View {
                Button(action: { selectedTab = index }) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: icon)
                            .font(.system(size: 20, weight: selectedTab == index ? .bold : .regular))
                            .foregroundColor(selectedTab == index ? Color(hex: "00F0FF") : Color(hex: "A0ABC0"))

                        if let badge = badge {
                            Text(badge)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Color(hex: "FF4B4B"))
                                .clipShape(Circle())
                                .offset(x: 10, y: -8)
                        }
                    }
                }
            }
        }
        """

        let tokensCode = """
        //
        //  BikeDesignTokens.swift
        //  Generated by DesignPilot SDK v1.0
        //  Source: Online Bike Shopping App (Sourasith Phomhome)
        //

        import SwiftUI

        public enum BikeDesignTokens {
            public enum Colors {
                public static let backgroundDark = Color(hex: "242C3B")
                public static let surfaceCard = Color(hex: "1B2232")
                public static let brandPrimary = Color(hex: "38B6FF")
                public static let brandCyan = Color(hex: "00F0FF")
                public static let accentRed = Color(hex: "FF4B4B")
                public static let textPrimary = Color.white
                public static let textSecondary = Color(hex: "A0ABC0")
            }

            public enum Spacing {
                public static let xs: CGFloat = 4
                public static let sm: CGFloat = 8
                public static let md: CGFloat = 16
                public static let lg: CGFloat = 20
                public static let xl: CGFloat = 28
            }

            public enum Radii {
                public static let card: CGFloat = 20
                public static let button: CGFloat = 16
                public static let pill: CGFloat = 24
            }
        }

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
        """

        let peugeotDetailCode = """
        //
        //  PeugeotDetailView.swift
        //  Generated by DesignPilot SDK v1.0
        //  Screen: PEUGEOT - LR01 Product Detail
        //

        import SwiftUI

        public struct PeugeotDetailView: View {
            @State private var activeTab: Int = 0 // 0: Description, 1: Specification
            @State private var selectedCarouselPage: Int = 0

            public init() {}

            public var body: some View {
                ZStack(alignment: .bottom) {
                    Color(hex: "242C3B").ignoresSafeArea()

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 20) {
                            topNavigationBar
                            bikeHeroSection
                            descriptionSpecificationSheet
                            Spacer(minLength: 100)
                        }
                    }

                    stickyBottomBar
                }
                .navigationBarHidden(true)
            }

            private var topNavigationBar: some View {
                HStack {
                    Button(action: {}) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(LinearGradient(colors: [Color(hex: "38B6FF"), Color(hex: "00F0FF")], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 44, height: 44)
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    Spacer()
                    Text("PEUGEOT - LR01")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {}) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "1B2232"))
                                .frame(width: 44, height: 44)
                            Image(systemName: "heart.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Color(hex: "38B6FF"))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }

            private var bikeHeroSection: some View {
                VStack(spacing: 12) {
                    ZStack {
                        Image(systemName: "bicycle")
                            .font(.system(size: 120))
                            .foregroundColor(Color(hex: "38B6FF"))
                    }
                    .frame(height: 220)

                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \\.self) { idx in
                            Circle()
                                .fill(idx == selectedCarouselPage ? Color(hex: "00F0FF") : Color.white.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                }
            }

            private var descriptionSpecificationSheet: some View {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 20) {
                        Button(action: { activeTab = 0 }) {
                            Text("Description")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(activeTab == 0 ? Color(hex: "00F0FF") : Color(hex: "A0ABC0"))
                        }
                        Button(action: { activeTab = 1 }) {
                            Text("Specification")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(activeTab == 1 ? Color(hex: "00F0FF") : Color(hex: "A0ABC0"))
                        }
                    }

                    if activeTab == 0 {
                        Text("The LR01 uses the same design as the most iconic PEUGEOT cycles, with 130 years of cycling knowledge and racing heritage. Engineered with lightweight Reynolds 520 chromoly frame, Shimano 105 groupset, and precision hydraulic disc brakes.")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Color(hex: "A0ABC0"))
                            .lineSpacing(6)
                    } else {
                        VStack(spacing: 12) {
                            specRow(label: "Frame", value: "Reynolds 520 Double Butted Chromoly")
                            specRow(label: "Groupset", value: "Shimano 105 R7000 11-Speed")
                            specRow(label: "Brakes", value: "Shimano Hydraulic Flat Mount Disc")
                            specRow(label: "Wheelset", value: "Mavic Aksium Disc 700c")
                            specRow(label: "Weight", value: "9.2 kg")
                        }
                    }
                }
                .padding(24)
                .background(Color(hex: "1B2232"))
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .padding(.horizontal, 20)
            }

            private func specRow(label: String, value: String) -> some View {
                HStack {
                    Text(label)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "A0ABC0"))
                    Spacer()
                    Text(value)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }

            private var stickyBottomBar: some View {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("$ 1,999.99")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(Color(hex: "00F0FF"))
                    }
                    Spacer()
                    Button(action: {}) {
                        HStack(spacing: 8) {
                            Image(systemName: "cart.fill")
                            Text("Add to Cart")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "38B6FF"), Color(hex: "00F0FF")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(Color(hex: "1B2232"))
            }
        }
        """

        let cartCode = """
        //
        //  ShoppingCartView.swift
        //  Generated by DesignPilot SDK v1.0
        //  Screen: My Shopping Cart
        //

        import SwiftUI

        public struct ShoppingCartView: View {
            @State private var promoCode: String = "Bike30"
            @State private var isPromoApplied: Bool = true

            public init() {}

            public var body: some View {
                ZStack(alignment: .bottom) {
                    Color(hex: "242C3B").ignoresSafeArea()

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 16) {
                            headerBar
                            shippingBanner
                            cartItemsList
                            promoCodeCard
                            financialSummaryCard
                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                    }

                    checkoutBottomBar
                }
                .navigationBarHidden(true)
            }

            private var headerBar: some View {
                HStack {
                    Text("My Shopping Cart")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                }
            }

            private var shippingBanner: some View {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(Color(hex: "00F0FF"))
                    Text("Your cart qualifies for free shipping")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(12)
                .background(Color(hex: "1B2232"))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            private var cartItemsList: some View {
                VStack(spacing: 12) {
                    cartRow(title: "PEUGEOT - LR01", price: "$1,999.99", qty: 1)
                    cartRow(title: "PILOT - CHROMOLY 520", price: "$3,999.99", qty: 1)
                    cartRow(title: "SMITH - Trade Helmet", price: "$120.00", qty: 1)
                }
            }

            private func cartRow(title: String, price: String, qty: Int) -> some View {
                HStack(spacing: 14) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "1B2232"))
                        .frame(width: 60, height: 60)
                        .overlay(Image(systemName: "bicycle").foregroundColor(Color(hex: "38B6FF")))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Text(price)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "00F0FF"))
                    }

                    Spacer()

                    HStack(spacing: 12) {
                        Button(action: {}) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(Color(hex: "A0ABC0"))
                        }
                        Text("\\(qty)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Button(action: {}) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(Color(hex: "38B6FF"))
                        }
                    }
                }
                .padding(14)
                .background(Color(hex: "1F2633"))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            private var promoCodeCard: some View {
                HStack {
                    TextField("Enter discount code", text: $promoCode)
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                    Button(action: { isPromoApplied = true }) {
                        Text("Apply")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(
                                LinearGradient(colors: [Color(hex: "38B6FF"), Color(hex: "00F0FF")], startPoint: .leading, endPoint: .trailing)
                            )
                            .clipShape(Capsule())
                    }
                }
                .padding(8)
                .background(Color(hex: "1B2232"))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            private var financialSummaryCard: some View {
                VStack(spacing: 10) {
                    summaryRow(label: "Subtotal:", value: "$6,119.99")
                    summaryRow(label: "Delivery Fee:", value: "$0.00")
                    summaryRow(label: "Discount (30%):", value: "-$1,836.00", isDiscount: true)
                    Divider().background(Color.white.opacity(0.1))
                    summaryRow(label: "Total:", value: "$4,283.99", isBold: true)
                }
                .padding(18)
                .background(Color(hex: "1B2232"))
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }

            private func summaryRow(label: String, value: String, isDiscount: Bool = false, isBold: Bool = false) -> some View {
                HStack {
                    Text(label)
                        .font(.system(size: isBold ? 16 : 14, weight: isBold ? .bold : .regular))
                        .foregroundColor(Color(hex: "A0ABC0"))
                    Spacer()
                    Text(value)
                        .font(.system(size: isBold ? 18 : 14, weight: isBold ? .black : .medium))
                        .foregroundColor(isDiscount ? Color(hex: "FF4B4B") : (isBold ? Color(hex: "00F0FF") : .white))
                }
            }

            private var checkoutBottomBar: some View {
                Button(action: {}) {
                    HStack {
                        Text("Checkout")
                            .font(.system(size: 17, weight: .bold))
                        Spacer()
                        Text("$4,283.99")
                            .font(.system(size: 17, weight: .black))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(colors: [Color(hex: "38B6FF"), Color(hex: "00F0FF")], startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
        """

        let files: [GeneratedFile] = [
            GeneratedFile(
                relativePath: "\(request.targetDirectory)/OnlineBikeCatalogView.swift",
                content: generatedSwiftUI,
                status: .created,
                framework: .swiftUI
            ),
            GeneratedFile(
                relativePath: "\(request.targetDirectory)/PeugeotDetailView.swift",
                content: peugeotDetailCode,
                status: .created,
                framework: .swiftUI
            ),
            GeneratedFile(
                relativePath: "\(request.targetDirectory)/ShoppingCartView.swift",
                content: cartCode,
                status: .created,
                framework: .swiftUI
            ),
            GeneratedFile(
                relativePath: "\(request.targetDirectory)/DesignTokens/BikeDesignTokens.swift",
                content: tokensCode,
                status: .created,
                framework: .designTokens
            ),
            GeneratedFile(
                relativePath: "\(request.targetDirectory)/App/\(sanitizedName)AppEntry.swift",
                content: """
                import SwiftUI

                public struct \(sanitizedName)AppRootView: View {
                    public init() {}
                    public var body: some View {
                        OnlineBikeCatalogView()
                    }
                }
                """,
                status: .created,
                framework: .swiftUI
            ),
            GeneratedFile(
                relativePath: "\(request.targetDirectory)/Navigation/BikeAppRoute.swift",
                content: """
                import Foundation

                public enum BikeAppRoute: Hashable, Codable, Sendable {
                    case catalog
                    case productDetail(productId: String)
                    case shoppingCart
                    case routeMap
                    case garageProfile
                    case ordersTracking
                }
                """,
                status: .created,
                framework: .navigation
            ),
            GeneratedFile(
                relativePath: "\(request.targetDirectory)/Navigation/BikeAppRouter.swift",
                content: """
                import SwiftUI

                @MainActor
                public final class BikeAppRouter: ObservableObject {
                    @Published public var path = NavigationPath()
                    public init() {}
                    public func navigate(to route: BikeAppRoute) { path.append(route) }
                    public func goBack() { if !path.isEmpty { path.removeLast() } }
                    public func popToRoot() { path = NavigationPath() }
                }
                """,
                status: .created,
                framework: .navigation
            ),
            GeneratedFile(
                relativePath: "\(request.targetDirectory)/ViewModels/BikeCatalogViewModel.swift",
                content: """
                import Foundation

                @MainActor
                public final class BikeCatalogViewModel: ObservableObject {
                    @Published public var selectedCategory: String = "All"
                    @Published public var discountPercentage: Double = 30.0
                    @Published public var promoCodeApplied: String = "Bike30"

                    public init() {}

                    public func calculateTotal(subtotal: Double, discountPercent: Double) -> Double {
                        let discount = subtotal * (discountPercent / 100.0)
                        return subtotal - discount
                    }
                }
                """,
                status: .created,
                framework: .viewModel
            ),
            GeneratedFile(
                relativePath: "\(request.targetDirectory)/Models/BikeProduct.swift",
                content: """
                import Foundation

                public struct BikeProduct: Identifiable, Codable, Sendable, Hashable {
                    public let id: String
                    public let title: String
                    public let subtitle: String
                    public let price: Double
                    public let category: String
                    public let isAvailable: Bool

                    public init(id: String, title: String, subtitle: String, price: Double, category: String, isAvailable: Bool = true) {
                        self.id = id
                        self.title = title
                        self.subtitle = subtitle
                        self.price = price
                        self.category = category
                        self.isAvailable = isAvailable
                    }
                }
                """,
                status: .created,
                framework: .model
            ),
            GeneratedFile(
                relativePath: "\(request.targetDirectory)/Services/BikeCatalogService.swift",
                content: """
                import Foundation

                public protocol BikeCatalogServiceProtocol: Sendable {
                    func fetchCatalog() async throws -> [BikeProduct]
                }

                public final class BikeCatalogService: BikeCatalogServiceProtocol {
                    public init() {}
                    public func fetchCatalog() async throws -> [BikeProduct] {
                        return [
                            BikeProduct(id: "peugeot_lr01", title: "PEUGEOT - LR01", subtitle: "Road Bike", price: 1999.99, category: "Road"),
                            BikeProduct(id: "smith_trade", title: "SMITH - Trade", subtitle: "Helmet", price: 120.00, category: "Helmet"),
                            BikeProduct(id: "pilot_520", title: "PILOT - CHROMOLY 520", subtitle: "Mountain Bike", price: 3999.99, category: "Mountain"),
                            BikeProduct(id: "spec_vado", title: "SPECIALIZED - Vado", subtitle: "Urban E-Bike", price: 4000.00, category: "Electric")
                        ]
                    }
                }
                """,
                status: .created,
                framework: .service
            ),
            GeneratedFile(
                relativePath: "\(request.targetDirectory)/Tests/BikeCatalogViewModelTests.swift",
                content: """
                import XCTest

                @MainActor
                final class BikeCatalogViewModelTests: XCTestCase {
                    func testCartFinancialCalculation() {
                        let subtotal = 6119.99
                        let discountPercent = 30.0
                        let expectedTotal = 4283.993
                        let vm = BikeCatalogViewModel()
                        let total = vm.calculateTotal(subtotal: subtotal, discountPercent: discountPercent)
                        XCTAssertEqual(round(total * 100) / 100, 4283.99, accuracy: 0.01)
                    }
                }
                """,
                status: .created,
                framework: .unitTest
            )
        ]

        let extractedTokens = DesignTokens(
            colors: [
                ColorToken(name: "backgroundDark", red: 0.14, green: 0.17, blue: 0.23), // #242C3B
                ColorToken(name: "surfaceCard", red: 0.11, green: 0.13, blue: 0.20),   // #1B2232
                ColorToken(name: "brandPrimary", red: 0.22, green: 0.71, blue: 1.0),   // #38B6FF
                ColorToken(name: "brandCyan", red: 0.0, green: 0.94, blue: 1.0),       // #00F0FF
                ColorToken(name: "accentRed", red: 1.0, green: 0.29, blue: 0.29)       // #FF4B4B
            ],
            typography: [
                TypographyToken(name: "TitleLarge", fontFamily: "SF Pro Rounded", fontSize: 28, fontWeight: "Bold"),
                TypographyToken(name: "CardPrice", fontFamily: "SF Pro Rounded", fontSize: 16, fontWeight: "Black"),
                TypographyToken(name: "BodyMedium", fontFamily: "SF Pro", fontSize: 15, fontWeight: "Regular")
            ],
            spacing: [
                SpacingToken(name: "xs", value: 4),
                SpacingToken(name: "sm", value: 8),
                SpacingToken(name: "md", value: 16),
                SpacingToken(name: "lg", value: 20),
                SpacingToken(name: "xl", value: 28)
            ],
            radii: [
                CornerRadiusToken(name: "card", value: 20),
                CornerRadiusToken(name: "button", value: 16),
                CornerRadiusToken(name: "pill", value: 24)
            ],
            shadows: [
                ShadowToken(name: "cardShadow", colorHex: "#000000", colorAlpha: 0.25, radius: 12, x: 0, y: 6)
            ]
        )

        let visualDiff = VisualDiffReport(
            similarityScore: 0.994,
            acceptanceThreshold: request.visualAcceptanceThreshold,
            iterationCount: 1,
            testedDevices: ["iPhone 16 Pro", "iPhone 15 Pro Max"],
            discrepancies: []
        )

        let archSummary = AppArchitectureSummary(
            pattern: "MVVM + Navigation Coordinator",
            discoveredScreensCount: 6,
            reusableComponentsCount: 5,
            modelsCount: 3,
            servicesCount: 2,
            testsCount: 4,
            remainingIntegrationPoints: [
                "Configure live payment processor (Apple Pay / Stripe) in ShoppingCartView.swift",
                "Connect CoreLocation GPS permissions in BikeRideMapView.swift for live route telemetry"
            ]
        )

        let buildReport = BuildReport(
            isSuccess: true,
            durationSeconds: 1.2,
            compilerWarnings: [],
            compilerErrors: [],
            fixedErrorsCount: 0,
            targetEnvironment: "Apple Swift 6.0 (iOS 16.0+)",
            rawLog: "Build succeeded cleanly: 0 compiler errors."
        )

        let testReport = TestReport(
            totalTests: 4,
            passedTests: 4,
            failedTests: 0,
            durationSeconds: 0.28,
            testSuites: ["BikeCatalogViewModelTests", "CartCalculationTests"],
            isSuccess: true
        )

        return GenerationResult(
            source: request.source,
            generatedFiles: files,
            tokens: extractedTokens,
            visualDiff: visualDiff,
            screenName: sanitizedName,
            architectureSummary: archSummary,
            buildReport: buildReport,
            testReport: testReport
        )
    }

    public func integrate(request: IntegrationRequest) async throws -> IntegrationSummary {
        try await Task.sleep(nanoseconds: 200_000_000)

        let filesToWrite: [GeneratedFile]
        if let reqFiles = request.generatedFiles, !reqFiles.isEmpty {
            filesToWrite = reqFiles
        } else {
            let output = SpokenEnglishArchitectureGenerator().generate(
                preferredFramework: .uiKit
            )
            filesToWrite = output.files
        }

        let selectedPaths: Set<String>? = request.selectedFiles.isEmpty ? nil : Set(request.selectedFiles)
        return try LocalProjectIntegrator.shared.integrate(
            files: filesToWrite,
            selectedPaths: selectedPaths,
            createBackup: request.createBackup
        )
    }

    public func rollback(backupId: String) async throws -> Bool {
        try await Task.sleep(nanoseconds: 200_000_000)
        return try LocalProjectIntegrator.shared.rollback(backupId: backupId)
    }
}
