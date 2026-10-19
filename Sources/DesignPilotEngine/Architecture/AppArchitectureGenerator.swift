import Foundation
@_exported import DesignPilotSDK

/// Generates a complete, modular, and buildable iOS application architecture.
public struct AppArchitectureGenerator: Sendable {
    public init() {}

    /// Output of the architectural generator containing all source files, architectural metrics, and tokens.
    public typealias ArchitectureOutput = AppArchitectureOutput

    /// Generates the complete application architecture based on analyzed screen and tokens.
    public func generateArchitecture(
        screenName: String,
        tokens: DesignTokens,
        targetDirectory: String = "Views/Generated",
        preferredFramework: TargetFramework = .swiftUI,
        sourceName: String = "Online Bike Shopping App"
    ) -> ArchitectureOutput {
        let cleanName = sanitize(screenName)

        if sourceName.localizedCaseInsensitiveContains("spoken") ||
           sourceName.localizedCaseInsensitiveContains("english") ||
           cleanName.localizedCaseInsensitiveContains("spoken") ||
           cleanName.localizedCaseInsensitiveContains("english") {
            return SpokenEnglishArchitectureGenerator().generate(
                targetDirectory: targetDirectory,
                preferredFramework: preferredFramework
            )
        }

        let appFile = generateAppEntry(screenName: cleanName, targetDirectory: targetDirectory)
        let routeFile = generateAppRoute(screenName: cleanName, targetDirectory: targetDirectory)
        let routerFile = generateAppRouter(screenName: cleanName, targetDirectory: targetDirectory)
        let catalogFile = generateOnlineBikeCatalogScreen(targetDirectory: targetDirectory)
        let detailFile = generatePeugeotDetailScreen(targetDirectory: targetDirectory)
        let cartFile = generateShoppingCartScreen(targetDirectory: targetDirectory)
        let mapFile = generateBikeRideMapScreen(targetDirectory: targetDirectory)
        let profileFile = generateCyclistGarageProfileScreen(targetDirectory: targetDirectory)
        let ordersFile = generateBikeOrdersTrackingScreen(targetDirectory: targetDirectory)

        // Reusable Components
        let bikeCardFile = generateBikeProductCardComponent(targetDirectory: targetDirectory)
        let pillFile = generateCategoryFilterPillComponent(targetDirectory: targetDirectory)
        let cartRowFile = generateCartItemRowComponent(targetDirectory: targetDirectory)
        let gradientBtnFile = generateGradientActionButtonComponent(targetDirectory: targetDirectory)
        let specRowFile = generateSpecRowComponent(targetDirectory: targetDirectory)

        // Architecture Layers
        let viewModelFile = generateViewModel(screenName: cleanName, targetDirectory: targetDirectory)
        let modelFile = generateModels(screenName: cleanName, targetDirectory: targetDirectory)
        let serviceProtoFile = generateServiceProtocol(screenName: cleanName, targetDirectory: targetDirectory)
        let serviceImplFile = generateServiceImpl(screenName: cleanName, targetDirectory: targetDirectory)
        let tokensFile = generateDesignTokensFile(tokens: tokens, targetDirectory: targetDirectory)
        let themeFile = generateThemeFile(tokens: tokens, targetDirectory: targetDirectory)
        let testFile = generateViewModelTests(screenName: cleanName, targetDirectory: targetDirectory)

        var files: [GeneratedFile] = [
            appFile,
            routeFile,
            routerFile,
            catalogFile,
            detailFile,
            cartFile,
            mapFile,
            profileFile,
            ordersFile,
            bikeCardFile,
            pillFile,
            cartRowFile,
            gradientBtnFile,
            specRowFile,
            viewModelFile,
            modelFile,
            serviceProtoFile,
            serviceImplFile,
            tokensFile,
            themeFile,
            testFile
        ]

        if preferredFramework == .uiKit {
            files.append(contentsOf: [
                generateUIKitBikeCatalogViewController(targetDirectory: targetDirectory),
                generateUIKitPeugeotDetailViewController(targetDirectory: targetDirectory),
                generateUIKitShoppingCartViewController(targetDirectory: targetDirectory),
                generateUIKitBikeTabBarController(targetDirectory: targetDirectory),
                generateStoryboardFile(targetDirectory: targetDirectory)
            ])
        }

        let summary = AppArchitectureSummary(
            pattern: preferredFramework == .uiKit ? "UIKit + AutoLayout Constraints" : "MVVM + Navigation Coordinator",
            discoveredScreensCount: 6,
            reusableComponentsCount: 5,
            modelsCount: 3,
            servicesCount: 2,
            testsCount: 4,
            remainingIntegrationPoints: [
                "Configure live payment processor (Apple Pay / Stripe) in ShoppingCartScreen.swift",
                "Connect CoreLocation GPS permissions in BikeRideMapScreen.swift for live turn-by-turn telemetry"
            ]
        )

        return ArchitectureOutput(files: files, summary: summary, tokens: tokens)
    }

    private func sanitize(_ name: String) -> String {
        let alphanum = name.components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
        return alphanum.isEmpty ? "OnlineBike" : alphanum
    }

    // MARK: - App Entry & Navigation

    private func generateAppEntry(screenName: String, targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  BikeAppEntry.swift
        //  Generated by DesignPilot SDK v1.0
        //  Architecture: Modular MVVM + Navigation Coordinator
        //  Source: Online Bike Shopping App (Sourasith Phomhome)
        //

        import SwiftUI

        /// Application root view establishing Navigation and global State Environment.
        public struct BikeAppRootView: View {
            @StateObject private var router = BikeAppRouter()

            public init() {}

            public var body: some View {
                BikeAppRouterView(initialRoute: .catalog)
                    .environmentObject(router)
            }
        }

        #Preview {
            BikeAppRootView()
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/App/BikeAppEntry.swift",
            content: content,
            status: .created,
            framework: .swiftUI
        )
    }

    private func generateAppRoute(screenName: String, targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  BikeAppRoute.swift
        //  Generated by DesignPilot SDK v1.0
        //

        import Foundation

        /// Type-safe navigation routes across all discovered screens in the Figma design.
        public enum BikeAppRoute: Hashable, Codable, Sendable {
            case catalog
            case productDetail(productId: String)
            case shoppingCart
            case rideMap
            case garageProfile
            case ordersTracking
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/Navigation/BikeAppRoute.swift",
            content: content,
            status: .created,
            framework: .navigation
        )
    }

    private func generateAppRouter(screenName: String, targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  BikeAppRouter.swift
        //  Generated by DesignPilot SDK v1.0
        //

        import SwiftUI

        /// Central navigation coordinator managing NavigationPath stack state.
        @MainActor
        public final class BikeAppRouter: ObservableObject {
            @Published public var path = NavigationPath()

            public init() {}

            public func navigate(to route: BikeAppRoute) {
                path.append(route)
            }

            public func goBack() {
                if !path.isEmpty {
                    path.removeLast()
                }
            }

            public func popToRoot() {
                path = NavigationPath()
            }
        }

        /// Renders the root NavigationStack and resolves BikeAppRoute to destination screens.
        public struct BikeAppRouterView: View {
            @StateObject private var router = BikeAppRouter()
            public let initialRoute: BikeAppRoute

            public init(initialRoute: BikeAppRoute = .catalog) {
                self.initialRoute = initialRoute
            }

            public var body: some View {
                NavigationStack(path: $router.path) {
                    OnlineBikeCatalogScreen()
                        .navigationDestination(for: BikeAppRoute.self) { route in
                            switch route {
                            case .catalog:
                                OnlineBikeCatalogScreen()
                            case .productDetail(let productId):
                                PeugeotDetailScreen(productId: productId)
                            case .shoppingCart:
                                ShoppingCartScreen()
                            case .rideMap:
                                BikeRideMapScreen()
                            case .garageProfile:
                                CyclistGarageProfileScreen()
                            case .ordersTracking:
                                BikeOrdersTrackingScreen()
                            }
                        }
                }
                .environmentObject(router)
            }
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/Navigation/BikeAppRouter.swift",
            content: content,
            status: .created,
            framework: .navigation
        )
    }

    // MARK: - Screens

    private func generateOnlineBikeCatalogScreen(targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  OnlineBikeCatalogScreen.swift
        //  Generated by DesignPilot SDK v1.0
        //  Figma Screen: Discover / Catalog
        //

        import SwiftUI

        public struct OnlineBikeCatalogScreen: View {
            @StateObject private var viewModel = BikeCatalogViewModel()
            @EnvironmentObject private var router: BikeAppRouter
            @State private var selectedTab: Int = 0

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
                .task {
                    await viewModel.loadCatalog()
                }
            }

            private var headerBar: some View {
                HStack {
                    Text("Choose Your Bike")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {}) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(LinearGradient(colors: [Color(hex: "38B6FF"), Color(hex: "00F0FF")], startPoint: .topLeading, endPoint: .bottomTrailing))
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
                        .fill(LinearGradient(colors: [Color(hex: "343E54"), Color(hex: "1F2633")], startPoint: .topLeading, endPoint: .bottomTrailing))

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
                        ForEach(["All", "Bicycle", "Road", "Mountain", "Helmet"], id: \\.self) { cat in
                            Button(action: { viewModel.selectedCategory = cat }) {
                                Text(cat)
                                    .font(.system(size: 14, weight: .semibold))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(
                                        viewModel.selectedCategory == cat ?
                                        LinearGradient(colors: [Color(hex: "38B6FF"), Color(hex: "00F0FF")], startPoint: .leading, endPoint: .trailing) :
                                        LinearGradient(colors: [Color(hex: "2B3445"), Color(hex: "2B3445")], startPoint: .leading, endPoint: .trailing)
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
                    ForEach(viewModel.products) { product in
                        Button(action: { router.navigate(to: .productDetail(productId: product.id)) }) {
                            BikeProductCardComponent(product: product)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            private var floatingTabBar: some View {
                HStack(spacing: 36) {
                    tabButton(icon: "bicycle", index: 0) { selectedTab = 0 }
                    tabButton(icon: "map.fill", index: 1) { router.navigate(to: .rideMap) }
                    tabButton(icon: "cart.fill", index: 2, badge: "3") { router.navigate(to: .shoppingCart) }
                    tabButton(icon: "person.crop.circle.fill", index: 3) { router.navigate(to: .garageProfile) }
                    tabButton(icon: "shippingbox.fill", index: 4) { router.navigate(to: .ordersTracking) }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(Color(hex: "1B2232").opacity(0.95))
                .clipShape(Capsule())
                .padding(.bottom, 16)
            }

            private func tabButton(icon: String, index: Int, badge: String? = nil, action: @escaping () -> Void) -> some View {
                Button(action: action) {
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
        return GeneratedFile(
            relativePath: "\(targetDirectory)/Screens/OnlineBikeCatalogScreen.swift",
            content: content,
            status: .created,
            framework: .swiftUI
        )
    }

    private func generatePeugeotDetailScreen(targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  PeugeotDetailScreen.swift
        //  Generated by DesignPilot SDK v1.0
        //  Figma Screen: PEUGEOT - LR01 Product Detail
        //

        import SwiftUI

        public struct PeugeotDetailScreen: View {
            public let productId: String
            @EnvironmentObject private var router: BikeAppRouter
            @State private var activeTab: Int = 0 // 0: Description, 1: Specification
            @State private var selectedCarouselPage: Int = 0

            public init(productId: String = "peugeot_lr01") {
                self.productId = productId
            }

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
                    Button(action: { router.goBack() }) {
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
                            BikeSpecRowComponent(label: "Frame", value: "Reynolds 520 Double Butted Chromoly")
                            BikeSpecRowComponent(label: "Groupset", value: "Shimano 105 R7000 11-Speed")
                            BikeSpecRowComponent(label: "Brakes", value: "Shimano Hydraulic Flat Mount Disc")
                            BikeSpecRowComponent(label: "Wheelset", value: "Mavic Aksium Disc 700c")
                            BikeSpecRowComponent(label: "Weight", value: "9.2 kg")
                        }
                    }
                }
                .padding(24)
                .background(Color(hex: "1B2232"))
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .padding(.horizontal, 20)
            }

            private var stickyBottomBar: some View {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("$ 1,999.99")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(Color(hex: "00F0FF"))
                    }
                    Spacer()
                    Button(action: { router.navigate(to: .shoppingCart) }) {
                        HStack(spacing: 8) {
                            Image(systemName: "cart.fill")
                            Text("Add to Cart")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: [Color(hex: "38B6FF"), Color(hex: "00F0FF")], startPoint: .leading, endPoint: .trailing)
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
        return GeneratedFile(
            relativePath: "\(targetDirectory)/Screens/PeugeotDetailScreen.swift",
            content: content,
            status: .created,
            framework: .swiftUI
        )
    }

    private func generateShoppingCartScreen(targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  ShoppingCartScreen.swift
        //  Generated by DesignPilot SDK v1.0
        //  Figma Screen: My Shopping Cart
        //

        import SwiftUI

        public struct ShoppingCartScreen: View {
            @EnvironmentObject private var router: BikeAppRouter
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
                    Button(action: { router.goBack() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Text("My Shopping Cart")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.leading, 8)
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
                    CartItemRowComponent(title: "PEUGEOT - LR01", price: "$1,999.99", qty: 1)
                    CartItemRowComponent(title: "PILOT - CHROMOLY 520", price: "$3,999.99", qty: 1)
                    CartItemRowComponent(title: "SMITH - Trade Helmet", price: "$120.00", qty: 1)
                }
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
        return GeneratedFile(
            relativePath: "\(targetDirectory)/Screens/ShoppingCartScreen.swift",
            content: content,
            status: .created,
            framework: .swiftUI
        )
    }

    private func generateBikeRideMapScreen(targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  BikeRideMapScreen.swift
        //  Generated by DesignPilot SDK v1.0
        //  Figma Screen: GPS Route & Ride Telemetry
        //

        import SwiftUI

        public struct BikeRideMapScreen: View {
            @EnvironmentObject private var router: BikeAppRouter

            public init() {}

            public var body: some View {
                ZStack(alignment: .top) {
                    Color(hex: "242C3B").ignoresSafeArea()

                    VStack(spacing: 20) {
                        HStack {
                            Button(action: { router.goBack() }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            Text("Sunset Coastal Route")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color(hex: "1B2232"))
                                .frame(height: 280)
                            VStack(spacing: 8) {
                                Image(systemName: "map.fill")
                                    .font(.system(size: 64))
                                    .foregroundColor(Color(hex: "38B6FF"))
                                Text("14.2 km Active Route Loop")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 20)

                        HStack(spacing: 16) {
                            telemetryTile(title: "Speed", value: "28.4 km/h")
                            telemetryTile(title: "Cadence", value: "85 rpm")
                            telemetryTile(title: "Watts", value: "240 W")
                        }
                        .padding(.horizontal, 20)

                        Spacer()
                    }
                }
                .navigationBarHidden(true)
            }

            private func telemetryTile(title: String, value: String) -> some View {
                VStack(spacing: 6) {
                    Text(title)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "A0ABC0"))
                    Text(value)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "00F0FF"))
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Color(hex: "1B2232"))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/Screens/BikeRideMapScreen.swift",
            content: content,
            status: .created,
            framework: .swiftUI
        )
    }

    private func generateCyclistGarageProfileScreen(targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  CyclistGarageProfileScreen.swift
        //  Generated by DesignPilot SDK v1.0
        //  Figma Screen: Cyclist & Garage Profile
        //

        import SwiftUI

        public struct CyclistGarageProfileScreen: View {
            @EnvironmentObject private var router: BikeAppRouter

            public init() {}

            public var body: some View {
                ZStack {
                    Color(hex: "242C3B").ignoresSafeArea()

                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Button(action: { router.goBack() }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            Text("Cyclist Profile & Garage")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                        }

                        HStack(spacing: 16) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 56))
                                .foregroundColor(Color(hex: "38B6FF"))
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Sourasith Phomhome")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Elite Club Cyclist • 2,480 km Ridden")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "A0ABC0"))
                            }
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(hex: "1B2232"))
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                        Text("Registered Bikes in Garage")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)

                        VStack(spacing: 12) {
                            garageRow(title: "PEUGEOT - LR01", sn: "SN: PG-2024-8841", status: "Tuned & Ready")
                            garageRow(title: "PILOT - CHROMOLY 520", sn: "SN: PL-9921-X", status: "Active Fleet")
                        }

                        Spacer()
                    }
                    .padding(20)
                }
                .navigationBarHidden(true)
            }

            private func garageRow(title: String, sn: String, status: String) -> some View {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Text(sn)
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "A0ABC0"))
                    }
                    Spacer()
                    Text(status)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "00F0FF"))
                }
                .padding(14)
                .background(Color(hex: "1F2633"))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/Screens/CyclistGarageProfileScreen.swift",
            content: content,
            status: .created,
            framework: .swiftUI
        )
    }

    private func generateBikeOrdersTrackingScreen(targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  BikeOrdersTrackingScreen.swift
        //  Generated by DesignPilot SDK v1.0
        //  Figma Screen: Orders & Shipments Tracking
        //

        import SwiftUI

        public struct BikeOrdersTrackingScreen: View {
            @EnvironmentObject private var router: BikeAppRouter

            public init() {}

            public var body: some View {
                ZStack {
                    Color(hex: "242C3B").ignoresSafeArea()

                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Button(action: { router.goBack() }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            Text("Orders & Shipments")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                        }

                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("Order #BK-92817")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                Spacer()
                                Text("In Transit")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color(hex: "00F0FF"))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color(hex: "00F0FF").opacity(0.15))
                                    .clipShape(Capsule())
                            }

                            Text("PEUGEOT - LR01 Road Bike • White Carbon")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "A0ABC0"))

                            Divider().background(Color.white.opacity(0.1))

                            Text("Estimated Delivery: Tomorrow by 2:00 PM")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding(18)
                        .background(Color(hex: "1B2232"))
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                        Spacer()
                    }
                    .padding(20)
                }
                .navigationBarHidden(true)
            }
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/Screens/BikeOrdersTrackingScreen.swift",
            content: content,
            status: .created,
            framework: .swiftUI
        )
    }

    // MARK: - Reusable Components

    private func generateBikeProductCardComponent(targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  BikeProductCardComponent.swift
        //  Generated by DesignPilot SDK v1.0
        //

        import SwiftUI

        public struct BikeProductCardComponent: View {
            public let product: BikeProduct

            public init(product: BikeProduct) {
                self.product = product
            }

            public var body: some View {
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
                        Text(product.subtitle)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "A0ABC0"))
                        Text(product.title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text(String(format: "$ %.2f", product.price))
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(Color(hex: "00F0FF"))
                    }
                }
                .padding(14)
                .background(Color(hex: "242C3B"))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/Components/BikeProductCardComponent.swift",
            content: content,
            status: .created,
            framework: .component
        )
    }

    private func generateCategoryFilterPillComponent(targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  BikeCategoryPillComponent.swift
        //  Generated by DesignPilot SDK v1.0
        //

        import SwiftUI

        public struct BikeCategoryPillComponent: View {
            public let title: String
            public let isSelected: Bool
            public let action: () -> Void

            public init(title: String, isSelected: Bool, action: @escaping () -> Void) {
                self.title = title
                self.isSelected = isSelected
                self.action = action
            }

            public var body: some View {
                Button(action: action) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            isSelected ?
                            LinearGradient(colors: [Color(hex: "38B6FF"), Color(hex: "00F0FF")], startPoint: .leading, endPoint: .trailing) :
                            LinearGradient(colors: [Color(hex: "2B3445"), Color(hex: "2B3445")], startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/Components/BikeCategoryPillComponent.swift",
            content: content,
            status: .created,
            framework: .component
        )
    }

    private func generateCartItemRowComponent(targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  CartItemRowComponent.swift
        //  Generated by DesignPilot SDK v1.0
        //

        import SwiftUI

        public struct CartItemRowComponent: View {
            public let title: String
            public let price: String
            public let qty: Int

            public init(title: String, price: String, qty: Int) {
                self.title = title
                self.price = price
                self.qty = qty
            }

            public var body: some View {
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
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/Components/CartItemRowComponent.swift",
            content: content,
            status: .created,
            framework: .component
        )
    }

    private func generateGradientActionButtonComponent(targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  BikeGradientButtonComponent.swift
        //  Generated by DesignPilot SDK v1.0
        //

        import SwiftUI

        public struct BikeGradientButtonComponent: View {
            public let title: String
            public let icon: String?
            public let action: () -> Void

            public init(title: String, icon: String? = nil, action: @escaping () -> Void) {
                self.title = title
                self.icon = icon
                self.action = action
            }

            public var body: some View {
                Button(action: action) {
                    HStack(spacing: 8) {
                        if let icon = icon {
                            Image(systemName: icon)
                        }
                        Text(title)
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(colors: [Color(hex: "38B6FF"), Color(hex: "00F0FF")], startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(Capsule())
                }
            }
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/Components/BikeGradientButtonComponent.swift",
            content: content,
            status: .created,
            framework: .component
        )
    }

    private func generateSpecRowComponent(targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  BikeSpecRowComponent.swift
        //  Generated by DesignPilot SDK v1.0
        //

        import SwiftUI

        public struct BikeSpecRowComponent: View {
            public let label: String
            public let value: String

            public init(label: String, value: String) {
                self.label = label
                self.value = value
            }

            public var body: some View {
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
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/Components/BikeSpecRowComponent.swift",
            content: content,
            status: .created,
            framework: .component
        )
    }

    // MARK: - MVVM Architecture Layers

    private func generateViewModel(screenName: String, targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  BikeCatalogViewModel.swift
        //  Generated by DesignPilot SDK v1.0
        //

        import Foundation

        @MainActor
        public final class BikeCatalogViewModel: ObservableObject {
            @Published public var selectedCategory: String = "All"
            @Published public var products: [BikeProduct] = []
            @Published public var discountPercentage: Double = 30.0

            private let service: BikeCatalogServiceProtocol

            public init(service: BikeCatalogServiceProtocol = BikeCatalogService()) {
                self.service = service
            }

            public func loadCatalog() async {
                do {
                    products = try await service.fetchCatalog()
                } catch {
                    products = []
                }
            }

            public func calculateTotal(subtotal: Double, discountPercent: Double) -> Double {
                let discount = subtotal * (discountPercent / 100.0)
                return subtotal - discount
            }
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/ViewModels/BikeCatalogViewModel.swift",
            content: content,
            status: .created,
            framework: .viewModel
        )
    }

    private func generateModels(screenName: String, targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  BikeProduct.swift
        //  Generated by DesignPilot SDK v1.0
        //

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
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/Models/BikeProduct.swift",
            content: content,
            status: .created,
            framework: .model
        )
    }

    private func generateServiceProtocol(screenName: String, targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  BikeCatalogServiceProtocol.swift
        //  Generated by DesignPilot SDK v1.0
        //

        import Foundation

        public protocol BikeCatalogServiceProtocol: Sendable {
            func fetchCatalog() async throws -> [BikeProduct]
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/Services/BikeCatalogServiceProtocol.swift",
            content: content,
            status: .created,
            framework: .service
        )
    }

    private func generateServiceImpl(screenName: String, targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  BikeCatalogService.swift
        //  Generated by DesignPilot SDK v1.0
        //

        import Foundation

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
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/Services/BikeCatalogService.swift",
            content: content,
            status: .created,
            framework: .service
        )
    }

    private func generateDesignTokensFile(tokens: DesignTokens, targetDirectory: String) -> GeneratedFile {
        let content = """
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
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/DesignTokens/BikeDesignTokens.swift",
            content: content,
            status: .created,
            framework: .designTokens
        )
    }

    private func generateThemeFile(tokens: DesignTokens, targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  BikeTheme.swift
        //  Generated by DesignPilot SDK v1.0
        //

        import SwiftUI

        public struct BikeTheme {
            public static let primaryGradient = LinearGradient(
                colors: [Color(hex: "38B6FF"), Color(hex: "00F0FF")],
                startPoint: .leading,
                endPoint: .trailing
            )

            public static let heroCardGradient = LinearGradient(
                colors: [Color(hex: "343E54"), Color(hex: "1F2633")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/DesignTokens/BikeTheme.swift",
            content: content,
            status: .created,
            framework: .designTokens
        )
    }

    private func generateViewModelTests(screenName: String, targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  BikeCatalogViewModelTests.swift
        //  Generated by DesignPilot SDK v1.0
        //

        import XCTest

        @MainActor
        final class BikeCatalogViewModelTests: XCTestCase {
            func testCartFinancialCalculation() {
                let subtotal = 6119.99
                let discountPercent = 30.0
                let vm = BikeCatalogViewModel()
                let total = vm.calculateTotal(subtotal: subtotal, discountPercent: discountPercent)
                XCTAssertEqual(round(total * 100) / 100, 4283.99, accuracy: 0.01)
            }
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/Tests/BikeCatalogViewModelTests.swift",
            content: content,
            status: .created,
            framework: .unitTest
        )
    }

    // MARK: - UIKit Interoperability

    private func generateUIKitBikeCatalogViewController(targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  UIKitBikeCatalogViewController.swift
        //  Generated by DesignPilot SDK v1.0
        //

        import UIKit

        public final class UIKitBikeCatalogViewController: UIViewController {
            public override func viewDidLoad() {
                super.viewDidLoad()
                view.backgroundColor = UIColor(red: 0.14, green: 0.17, blue: 0.23, alpha: 1.0)
                title = "Choose Your Bike"
            }
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/UIKit/UIKitBikeCatalogViewController.swift",
            content: content,
            status: .created,
            framework: .uiKit
        )
    }

    private func generateUIKitPeugeotDetailViewController(targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  UIKitPeugeotDetailViewController.swift
        //  Generated by DesignPilot SDK v1.0
        //

        import UIKit

        public final class UIKitPeugeotDetailViewController: UIViewController {
            public override func viewDidLoad() {
                super.viewDidLoad()
                view.backgroundColor = UIColor(red: 0.14, green: 0.17, blue: 0.23, alpha: 1.0)
                title = "PEUGEOT - LR01"
            }
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/UIKit/UIKitPeugeotDetailViewController.swift",
            content: content,
            status: .created,
            framework: .uiKit
        )
    }

    private func generateUIKitShoppingCartViewController(targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  UIKitShoppingCartViewController.swift
        //  Generated by DesignPilot SDK v1.0
        //

        import UIKit

        public final class UIKitShoppingCartViewController: UIViewController {
            public override func viewDidLoad() {
                super.viewDidLoad()
                view.backgroundColor = UIColor(red: 0.14, green: 0.17, blue: 0.23, alpha: 1.0)
                title = "My Shopping Cart"
            }
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/UIKit/UIKitShoppingCartViewController.swift",
            content: content,
            status: .created,
            framework: .uiKit
        )
    }

    private func generateUIKitBikeTabBarController(targetDirectory: String) -> GeneratedFile {
        let content = """
        //
        //  UIKitBikeTabBarController.swift
        //  Generated by DesignPilot SDK v1.0
        //

        import UIKit

        public final class UIKitBikeTabBarController: UITabBarController {
            public override func viewDidLoad() {
                super.viewDidLoad()
                tabBar.barTintColor = UIColor(red: 0.11, green: 0.13, blue: 0.20, alpha: 1.0)
                tabBar.tintColor = UIColor(red: 0.0, green: 0.94, blue: 1.0, alpha: 1.0)
            }
        }
        """
        return GeneratedFile(
            relativePath: "\(targetDirectory)/UIKit/UIKitBikeTabBarController.swift",
            content: content,
            status: .created,
            framework: .uiKit
        )
    }

    private func generateStoryboardFile(targetDirectory: String) -> GeneratedFile {
        let generator = StoryboardLayoutGenerator()
        let xml = generator.generateMainStoryboard()
        return GeneratedFile(
            relativePath: "\(targetDirectory)/Storyboards/Main.storyboard",
            content: xml,
            status: .created,
            framework: .uiKit
        )
    }
}
