import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Screens discovered and generated from the Figma Online Bike Shopping App design flow.
public enum AppScreenDestination: String, CaseIterable, Identifiable {
    case home = "1. Discover (Catalog)"
    case detail = "2. Detail (Peugeot - LR01)"
    case cart = "3. Shopping Cart ($4,283.99)"
    case map = "4. Ride & Telemetry Map"
    case profile = "5. Garage & Profile"
    case orders = "6. Order History & Tracking"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .home: return "Online Bike Catalog"
        case .detail: return "PEUGEOT - LR01 Detail"
        case .cart: return "My Shopping Cart"
        case .map: return "Ride Route & Telemetry"
        case .profile: return "Cyclist Profile & Garage"
        case .orders: return "Orders & Shipments"
        }
    }

    public var icon: String {
        switch self {
        case .home: return "bicycle"
        case .detail: return "info.circle.fill"
        case .cart: return "cart.fill"
        case .map: return "map.fill"
        case .profile: return "person.fill"
        case .orders: return "doc.text.fill"
        }
    }
}

/// Color tokens extracted directly from the Figma design palette.
public enum OnlineBikeTheme {
    public static let darkMatteNavy = Color(red: 36/255, green: 44/255, blue: 59/255)      // #242C3B
    public static let darkCanvas = Color(red: 27/255, green: 34/255, blue: 50/255)         // #1B2232
    public static let electricBlue = Color(red: 30/255, green: 136/255, blue: 229/255)     // #1E88E5
    public static let cyanAccent = Color(red: 56/255, green: 182/255, blue: 255/255)       // #38B6FF
    public static let brightCyan = Color(red: 0/255, green: 240/255, blue: 255/255)        // #00F0FF
    public static let cardGlass = Color(red: 46/255, green: 56/255, blue: 77/255)          // #2E384D
    public static let cardHighlight = Color.white.opacity(0.12)
    public static let textPrimary = Color.white
    public static let textSecondary = Color(red: 140/255, green: 154/255, blue: 181/255)   // #8C9AB5
}

/// Domain model representing a bike or gear item from the Figma catalog.
public struct BikeProduct: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let category: String
    public let price: Double
    public let imageName: String
    public let tileImageName: String
    public let description: String
    public let specs: [String: String]
    public var isFavorite: Bool

    public var formattedPrice: String {
        String(format: "$ %.2f", price)
    }
}

/// Item in the shopping cart with quantity.
public struct BikeCartItem: Identifiable, Sendable {
    public let id: String
    public let product: BikeProduct
    public var quantity: Int

    public var itemTotal: Double {
        product.price * Double(quantity)
    }
}

/// Live, interactive application container faithfully rendering the Figma Online Bike Shopping App.
public struct LiveGeneratedAppView: View {
    public let result: GenerationResult
    public let onBackToGenerator: () -> Void
    public let onInspectArchitecture: () -> Void

    // Navigation & Screen State
    @State private var activeScreen: AppScreenDestination = .home
    @State private var selectedCategory: String = "All"
    @State private var selectedDetailTab: String = "Description"
    @State private var activeDetailProduct: BikeProduct

    // Cart & Financial State
    @State private var cartItems: [BikeCartItem]
    @State private var promoCode: String = "Bike30"
    @State private var isPromoApplied: Bool = true
    @State private var showCheckoutSheet: Bool = false
    @State private var toastMessage: String? = nil

    // Catalog Products matching Figma design exactly
    @State private var catalog: [BikeProduct] = [
        BikeProduct(
            id: "peugeot-lr01",
            name: "PEUGEOT - LR01",
            category: "Road Bike",
            price: 1999.99,
            imageName: "PeugeotLR01",
            tileImageName: "BikeTilePeugeot",
            description: "The LR01 uses the same design as the most iconic bikes from PEUGEOT Cycles' 130-year history and combines it with agile, dynamic performance that's perfectly suited to navigating today's cities. As well as a lugged steel frame and iconic PEUGEOT black-and-white chequer design, this city bike also features a 16-speed Shimano Claris drivetrain.",
            specs: [
                "Frame": "Lugged Steel with PEUGEOT chequer livery",
                "Drivetrain": "16-Speed Shimano Claris STI",
                "Brakes": "Promax Alloy Dual-Pivot Caliper",
                "Wheelset": "700c Double-Wall Alloy Classic",
                "Weight": "10.4 kg (Medium)"
            ],
            isFavorite: true
        ),
        BikeProduct(
            id: "smith-trade",
            name: "SMITH - Trade",
            category: "Road Helmet",
            price: 120.00,
            imageName: "SmithHelmet",
            tileImageName: "BikeTileHelmet",
            description: "The Smith Trade road cycling helmet delivers elite aerodynamic ventilation and integrated Koroyd impact protection for competitive sprints and weekend gran fondos.",
            specs: [
                "Safety": "MIPS Evolve Core + Koroyd Honeycomb",
                "Ventilation": "21 Optimized Aerodynamic Wind Ports",
                "Retention": "VaporFit Dial Adjustment System",
                "Weight": "270 grams",
                "Certifications": "CPSC & CE EN 1078 Certified"
            ],
            isFavorite: false
        ),
        BikeProduct(
            id: "pilot-chromoly",
            name: "PILOT - CHROMOLY 520",
            category: "Road Bike",
            price: 3999.99,
            imageName: "PilotChromoly",
            tileImageName: "BikeTilePilot",
            description: "Handcrafted aerospace-grade chromoly alloy road bike built for ultra-distance endurance, internal cockpit cable routing, and electronic shifting perfection.",
            specs: [
                "Frame": "Custom Double-Butted Chromoly 520 Steel",
                "Fork": "Full Carbon T800 Monocoque 1.5\" Tapered",
                "Groupset": "Shimano 105 Di2 12-Speed Wireless",
                "Brakes": "Shimano Hydraulic Flat Mount 160mm",
                "Weight": "8.9 kg"
            ],
            isFavorite: false
        ),
        BikeProduct(
            id: "specialized-e-road",
            name: "SPECIALIZED - E-Road",
            category: "Electric Bike",
            price: 4499.99,
            imageName: "HeroBikeCard",
            tileImageName: "HeroBikeCard",
            description: "Next-generation carbon monocoque e-road concept featuring 3-spoke carbon aero wheels, 500W torque-assist motor, and 120km extended range hidden battery.",
            specs: [
                "Motor": "Specialized SL 1.2 Custom 500W Mid-Drive",
                "Battery": "620Wh Integrated Aero Lithium-Ion",
                "Wheels": "Tri-Spoke Carbon Aero Disc Wheels",
                "Range": "Up to 120 km in Sport Assist",
                "Weight": "12.8 kg"
            ],
            isFavorite: true
        )
    ]

    public init(
        result: GenerationResult,
        onBackToGenerator: @escaping () -> Void,
        onInspectArchitecture: @escaping () -> Void
    ) {
        self.result = result
        self.onBackToGenerator = onBackToGenerator
        self.onInspectArchitecture = onInspectArchitecture

        let peugeot = BikeProduct(
            id: "peugeot-lr01",
            name: "PEUGEOT - LR01",
            category: "Road Bike",
            price: 1999.99,
            imageName: "PeugeotLR01",
            tileImageName: "BikeTilePeugeot",
            description: "The LR01 uses the same design as the most iconic bikes from PEUGEOT Cycles' 130-year history and combines it with agile, dynamic performance that's perfectly suited to navigating today's cities. As well as a lugged steel frame and iconic PEUGEOT black-and-white chequer design, this city bike also features a 16-speed Shimano Claris drivetrain.",
            specs: [
                "Frame": "Lugged Steel with PEUGEOT chequer livery",
                "Drivetrain": "16-Speed Shimano Claris STI",
                "Brakes": "Promax Alloy Dual-Pivot Caliper",
                "Wheelset": "700c Double-Wall Alloy Classic",
                "Weight": "10.4 kg"
            ],
            isFavorite: true
        )
        let smith = BikeProduct(
            id: "smith-trade",
            name: "SMITH - Trade",
            category: "Road Helmet",
            price: 120.00,
            imageName: "SmithHelmet",
            tileImageName: "BikeTileHelmet",
            description: "The Smith Trade road cycling helmet delivers elite aerodynamic ventilation and integrated Koroyd impact protection.",
            specs: ["Safety": "MIPS + Koroyd", "Weight": "270g"],
            isFavorite: false
        )
        let pilot = BikeProduct(
            id: "pilot-chromoly",
            name: "PILOT - CHROMOLY 520",
            category: "Road Bike",
            price: 3999.99,
            imageName: "PilotChromoly",
            tileImageName: "BikeTilePilot",
            description: "Aerospace-grade double-butted chromoly alloy endurance bike with electronic wireless shifting.",
            specs: ["Frame": "Chromoly 520", "Weight": "8.9 kg"],
            isFavorite: false
        )

        self._activeDetailProduct = State(initialValue: peugeot)
        self._cartItems = State(initialValue: [
            BikeCartItem(id: "item-1", product: peugeot, quantity: 1),
            BikeCartItem(id: "item-2", product: pilot, quantity: 1),
            BikeCartItem(id: "item-3", product: smith, quantity: 1)
        ])
    }

    // Financial Computed Totals matching Figma exact numbers ($6119.99 subtotal, 30% off -> $4,283.99 total)
    private var subtotal: Double {
        cartItems.reduce(0) { $0 + $1.itemTotal }
    }

    private var discountRate: Double {
        isPromoApplied ? 0.30 : 0.0
    }

    private var discountAmount: Double {
        subtotal * discountRate
    }

    private var deliveryFee: Double {
        0.0 // Free delivery in Figma design
    }

    private var grandTotal: Double {
        max(0, subtotal - discountAmount + deliveryFee)
    }

    private var totalCartItemCount: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Dark Background with Angled Diagonal Blue Highlight
                OnlineBikeTheme.darkCanvas
                    .ignoresSafeArea()

                angledBackgroundShape
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Developer HUD Header
                    developerHUDHeader
                        .padding(.top, 4)
                        .padding(.bottom, 6)

                    // Active Figma Screen
                    Group {
                        switch activeScreen {
                        case .home:
                            homeCatalogView
                        case .detail:
                            productDetailView
                        case .cart:
                            shoppingCartView
                        case .map:
                            rideTelemetryMapView
                        case .profile:
                            garageProfileView
                        case .orders:
                            orderTrackingView
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                // Toast Notification Overlay
                if let toast = toastMessage {
                    toastBanner(toast)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.bottom, 80)
                }
            }
            .sheet(isPresented: $showCheckoutSheet) {
                checkoutConfirmationSheet
            }
        }
    }

    // MARK: - Angled Diagonal Split Background (Figma Signature Style)

    private var angledBackgroundShape: some View {
        GeometryReader { proxy in
            Path { path in
                let w = proxy.size.width
                let h = proxy.size.height
                // Slanted diagonal slice through background
                path.move(to: CGPoint(x: w * 0.42, y: 0))
                path.addLine(to: CGPoint(x: w, y: 0))
                path.addLine(to: CGPoint(x: w, y: h * 0.65))
                path.addLine(to: CGPoint(x: w * 0.28, y: h))
                path.addLine(to: CGPoint(x: 0, y: h))
                path.addLine(to: CGPoint(x: w * 0.15, y: h * 0.40))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [
                        OnlineBikeTheme.electricBlue.opacity(0.85),
                        OnlineBikeTheme.cyanAccent.opacity(0.35),
                        Color.clear
                    ],
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
            )
        }
    }

    // MARK: - Developer HUD Banner

    private var developerHUDHeader: some View {
        VStack(spacing: 6) {
            HStack {
                Button(action: onBackToGenerator) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 11, weight: .bold))
                        Text("Pipeline")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.12), in: Capsule())
                }

                Spacer()

                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 7, height: 7)
                    Text("FIGMA LIVE: Online Bike Shopping App")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(OnlineBikeTheme.cyanAccent)
                }

                Spacer()

                Button(action: onInspectArchitecture) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.stack.3d.up.fill")
                            .font(.system(size: 11))
                        Text("Architecture")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.12), in: Capsule())
                }
            }
            .padding(.horizontal, 14)

            // Screen Flow Quick Jump
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(AppScreenDestination.allCases) { dest in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.22)) {
                                activeScreen = dest
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: dest.icon)
                                    .font(.system(size: 10))
                                Text(dest.rawValue)
                                    .font(.system(size: 11, weight: activeScreen == dest ? .bold : .medium))
                            }
                            .foregroundStyle(activeScreen == dest ? .white : OnlineBikeTheme.textSecondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                activeScreen == dest
                                ? LinearGradient(colors: [OnlineBikeTheme.cyanAccent, OnlineBikeTheme.electricBlue], startPoint: .topLeading, endPoint: .bottomTrailing)
                                : LinearGradient(colors: [Color.white.opacity(0.06), Color.white.opacity(0.02)], startPoint: .top, endPoint: .bottom),
                                in: Capsule()
                            )
                        }
                    }
                }
                .padding(.horizontal, 14)
            }
        }
    }

    // MARK: - SCREEN 1: Home / Discover Screen (Figma Center Screen)

    private var homeCatalogView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                // Top Header: Title & Search
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Choose Your Bike")
                            .font(.system(size: 26, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color.white)
                        Text("High performance racing & city bicycles")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(OnlineBikeTheme.textSecondary)
                    }

                    Spacer()

                    Button(action: { showToast("Searching catalog...") }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                LinearGradient(
                                    colors: [OnlineBikeTheme.cyanAccent, OnlineBikeTheme.electricBlue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                in: RoundedRectangle(cornerRadius: 14)
                            )
                            .shadow(color: OnlineBikeTheme.electricBlue.opacity(0.4), radius: 8, y: 4)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // 3D Hero Stacked Card: Futuristic Concept Bike (30% Off)
                heroStackedPromoCard
                    .padding(.horizontal, 16)

                // Category Filter Pills: All | Bicycle | Road | Mountain | Helmet
                categoryFilterRow
                    .padding(.horizontal, 16)

                // Staggered 2-Column Product Cards
                staggeredProductGrid
                    .padding(.horizontal, 16)
                    .padding(.bottom, 90) // clearance for floating tab bar
            }
        }
        .overlay(alignment: .bottom) {
            floatingBottomTabBar
        }
    }

    private var heroStackedPromoCard: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Card
            RoundedRectangle(cornerRadius: 26)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 45/255, green: 56/255, blue: 76/255),
                            Color(red: 26/255, green: 33/255, blue: 48/255)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 26)
                        .stroke(Color.white.opacity(0.16), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.35), radius: 14, y: 8)

            // Hero Bike Image
            HStack {
                Spacer()
                if let img = loadProjectImage(named: "HeroBikeCard") {
                    img
                        .resizable()
                        .scaledToFit()
                        .frame(height: 140)
                } else {
                    heroBikeFallbackIllustration
                        .frame(width: 170, height: 120)
                }
            }
            .padding(.trailing, 10)
            .padding(.top, 10)

            // Promo Badge & Copy
            VStack(alignment: .leading, spacing: 6) {
                Text("30% Off")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(Color.white)

                Text("Special discount for all\nroad & gravel models")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(OnlineBikeTheme.textSecondary)

                Button(action: {
                    if let first = catalog.first {
                        activeDetailProduct = first
                        withAnimation { activeScreen = .detail }
                    }
                }) {
                    Text("Explore Collection")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(
                            LinearGradient(
                                colors: [OnlineBikeTheme.cyanAccent, OnlineBikeTheme.electricBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: Capsule()
                        )
                }
                .padding(.top, 4)
            }
            .padding(18)
        }
        .frame(height: 160)
    }

    private var categoryFilterRow: some View {
        let categories = [
            ("All", "All", "square.grid.2x2.fill"),
            ("Bicycle", "Bicycle", "bicycle"),
            ("Road", "Road", "road.lanes"),
            ("Mountain", "Mountain", "mountain.2.fill"),
            ("Helmet", "Helmet", "shield.fill")
        ]

        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.0) { cat in
                    let isSelected = selectedCategory == cat.0
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            selectedCategory = cat.0
                        }
                    }) {
                        HStack(spacing: 6) {
                            if cat.0 == "All" {
                                Text("All")
                                    .font(.system(size: 13, weight: .bold))
                            } else {
                                Image(systemName: cat.2)
                                    .font(.system(size: 14))
                                Text(cat.1)
                                    .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                            }
                        }
                        .foregroundStyle(isSelected ? .white : OnlineBikeTheme.textSecondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            isSelected
                            ? LinearGradient(
                                colors: [OnlineBikeTheme.cyanAccent, OnlineBikeTheme.electricBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [Color.white.opacity(0.08), Color.white.opacity(0.03)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            in: RoundedRectangle(cornerRadius: 14)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(isSelected ? Color.white.opacity(0.4) : Color.white.opacity(0.08), lineWidth: 1)
                        )
                        .shadow(
                            color: isSelected ? OnlineBikeTheme.electricBlue.opacity(0.4) : Color.clear,
                            radius: 8,
                            y: 4
                        )
                    }
                }
            }
        }
    }

    private var staggeredProductGrid: some View {
        let filtered = catalog.filter {
            selectedCategory == "All" ? true : ($0.category.contains(selectedCategory) || (selectedCategory == "Bicycle" && $0.category.contains("Bike")))
        }

        return LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
            ForEach(filtered) { product in
                productCard(product)
            }
        }
    }

    private var filteredCatalog: [BikeProduct] {
        catalog.filter {
            selectedCategory == "All" ? true : ($0.category.contains(selectedCategory) || (selectedCategory == "Bicycle" && $0.category.contains("Bike")))
        }
    }

    private func productCard(_ product: BikeProduct) -> some View {
        Button(action: {
            activeDetailProduct = product
            withAnimation(.easeInOut(duration: 0.24)) {
                activeScreen = .detail
            }
        }) {
            VStack(alignment: .leading, spacing: 8) {
                // Heart Favorite Button
                HStack {
                    Spacer()
                    Button(action: {
                        toggleFavorite(for: product.id)
                    }) {
                        Image(systemName: product.isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(product.isFavorite ? OnlineBikeTheme.cyanAccent : .white.opacity(0.6))
                            .frame(width: 30, height: 30)
                            .background(Color.white.opacity(0.08), in: Circle())
                    }
                }

                // Product Image Container
                ZStack {
                    if let img = loadProjectImage(named: product.imageName) {
                        img
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                    } else if let tile = loadProjectImage(named: product.tileImageName) {
                        tile
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                    } else {
                        productFallbackView(product)
                            .frame(height: 100)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 105)

                // Category & Title
                VStack(alignment: .leading, spacing: 3) {
                    Text(product.category)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(OnlineBikeTheme.textSecondary)

                    Text(product.name)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white)
                        .lineLimit(1)

                    Text(product.formattedPrice)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(OnlineBikeTheme.cyanAccent)
                        .padding(.top, 2)
                }
            }
            .padding(14)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 45/255, green: 56/255, blue: 77/255).opacity(0.85),
                        Color(red: 30/255, green: 38/255, blue: 54/255).opacity(0.95)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 22)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.white.opacity(0.14), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.28), radius: 10, y: 5)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Floating Bottom Tab Bar (Figma Exact 5 Tabs)

    private var floatingBottomTabBar: some View {
        HStack(spacing: 0) {
            tabButton(destination: .home, icon: "bicycle", label: "Bikes")
            Spacer()
            tabButton(destination: .map, icon: "map.fill", label: "Map")
            Spacer()
            cartTabButton
            Spacer()
            tabButton(destination: .profile, icon: "person.fill", label: "Garage")
            Spacer()
            tabButton(destination: .orders, icon: "doc.text.fill", label: "Orders")
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 12)
        .background(
            Color(red: 25/255, green: 32/255, blue: 46/255).opacity(0.96),
            in: RoundedRectangle(cornerRadius: 28)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.4), radius: 16, y: 8)
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }

    private func tabButton(destination: AppScreenDestination, icon: String, label: String) -> some View {
        let isSelected = activeScreen == destination
        return Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                activeScreen = destination
            }
        }) {
            VStack(spacing: 3) {
                if isSelected {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 38)
                        .background(
                            LinearGradient(
                                colors: [OnlineBikeTheme.cyanAccent, OnlineBikeTheme.electricBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                        .shadow(color: OnlineBikeTheme.electricBlue.opacity(0.4), radius: 6, y: 3)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(OnlineBikeTheme.textSecondary)
                        .frame(width: 44, height: 38)
                }
            }
        }
    }

    private var cartTabButton: some View {
        let isSelected = activeScreen == .cart
        return Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                activeScreen = .cart
            }
        }) {
            ZStack(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "cart.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 38)
                        .background(
                            LinearGradient(
                                colors: [OnlineBikeTheme.cyanAccent, OnlineBikeTheme.electricBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                        .shadow(color: OnlineBikeTheme.electricBlue.opacity(0.4), radius: 6, y: 3)
                } else {
                    Image(systemName: "cart.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(OnlineBikeTheme.textSecondary)
                        .frame(width: 44, height: 38)
                }

                if totalCartItemCount > 0 {
                    Text("\(totalCartItemCount)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 16, height: 16)
                        .background(Color.red, in: Circle())
                        .offset(x: 4, y: -2)
                }
            }
        }
    }

    // MARK: - SCREEN 2: Product Detail Screen (Figma Left Screen)

    private var productDetailView: some View {
        VStack(spacing: 0) {
            // Top Navigation Bar
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        activeScreen = .home
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 42, height: 42)
                        .background(
                            LinearGradient(
                                colors: [OnlineBikeTheme.cyanAccent, OnlineBikeTheme.electricBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: RoundedRectangle(cornerRadius: 14)
                        )
                        .shadow(color: OnlineBikeTheme.electricBlue.opacity(0.4), radius: 6, y: 3)
                }

                Spacer()

                Text(activeDetailProduct.name)
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.white)
                    .tracking(0.5)

                Spacer()

                Button(action: {
                    toggleFavorite(for: activeDetailProduct.id)
                }) {
                    Image(systemName: activeDetailProduct.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(activeDetailProduct.isFavorite ? OnlineBikeTheme.cyanAccent : .white.opacity(0.7))
                        .frame(width: 42, height: 42)
                        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            // Hero Product Image Presentation with Diagonal Accent
            ZStack(alignment: .bottom) {
                // Large Product Image
                if let img = loadProjectImage(named: activeDetailProduct.imageName) {
                    img
                        .resizable()
                        .scaledToFit()
                        .frame(height: 220)
                } else if let tile = loadProjectImage(named: activeDetailProduct.tileImageName) {
                    tile
                        .resizable()
                        .scaledToFit()
                        .frame(height: 220)
                } else {
                    productFallbackView(activeDetailProduct)
                        .frame(height: 220)
                }

                // 3 Carousel Indicator Dots
                HStack(spacing: 6) {
                    Circle().fill(Color.white.opacity(0.4)).frame(width: 6, height: 6)
                    Circle().fill(Color.white).frame(width: 8, height: 8)
                    Circle().fill(Color.white.opacity(0.4)).frame(width: 6, height: 6)
                }
                .padding(.bottom, 12)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 240)

            // Bottom Modal Sheet Card
            VStack(alignment: .leading, spacing: 14) {
                // Description vs Specification Segmented Control
                HStack(spacing: 8) {
                    Button(action: { selectedDetailTab = "Description" }) {
                        Text("Description")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(selectedDetailTab == "Description" ? OnlineBikeTheme.cyanAccent : OnlineBikeTheme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                selectedDetailTab == "Description"
                                ? Color(red: 22/255, green: 28/255, blue: 40/255)
                                : Color.clear,
                                in: RoundedRectangle(cornerRadius: 12)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedDetailTab == "Description" ? Color.white.opacity(0.12) : Color.clear, lineWidth: 1)
                            )
                    }

                    Button(action: { selectedDetailTab = "Specification" }) {
                        Text("Specification")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(selectedDetailTab == "Specification" ? OnlineBikeTheme.cyanAccent : OnlineBikeTheme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                selectedDetailTab == "Specification"
                                ? Color(red: 22/255, green: 28/255, blue: 40/255)
                                : Color.clear,
                                in: RoundedRectangle(cornerRadius: 12)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedDetailTab == "Specification" ? Color.white.opacity(0.12) : Color.clear, lineWidth: 1)
                            )
                    }
                }
                .padding(4)
                .background(Color(red: 28/255, green: 35/255, blue: 48/255), in: RoundedRectangle(cornerRadius: 16))

                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(activeDetailProduct.name)
                            .font(.system(size: 17, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color.white)

                        if selectedDetailTab == "Description" {
                            Text(activeDetailProduct.description)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(OnlineBikeTheme.textSecondary)
                                .lineSpacing(5)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(activeDetailProduct.specs.sorted(by: { $0.key < $1.key }), id: \.key) { spec in
                                    HStack {
                                        Text(spec.key)
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundStyle(OnlineBikeTheme.textSecondary)
                                        Spacer()
                                        Text(spec.value)
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(Color.white)
                                    }
                                    .padding(.vertical, 4)
                                    Divider().background(Color.white.opacity(0.08))
                                }
                            }
                        }
                    }
                    .padding(.top, 4)
                }

                Spacer()

                // Sticky Bottom Bar: Price & Add to Cart
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(activeDetailProduct.formattedPrice)
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundStyle(OnlineBikeTheme.cyanAccent)
                    }

                    Spacer()

                    Button(action: {
                        addToCart(activeDetailProduct)
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "cart.badge.plus")
                                .font(.system(size: 14, weight: .bold))
                            Text("Add to Cart")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [OnlineBikeTheme.cyanAccent, OnlineBikeTheme.electricBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: RoundedRectangle(cornerRadius: 16)
                        )
                        .shadow(color: OnlineBikeTheme.electricBlue.opacity(0.4), radius: 8, y: 4)
                    }
                }
                .padding(.top, 6)
            }
            .padding(20)
            .background(
                Color(red: 32/255, green: 40/255, blue: 55/255),
                in: UnevenRoundedRectangle(topLeadingRadius: 32, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 32)
            )
            .overlay(
                UnevenRoundedRectangle(topLeadingRadius: 32, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 32)
                    .stroke(Color.white.opacity(0.14), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.35), radius: 18, y: -6)
        }
    }

    // MARK: - SCREEN 3: My Shopping Cart Screen (Figma Right Screen)

    private var shoppingCartView: some View {
        VStack(spacing: 0) {
            // Top Navigation Bar
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        activeScreen = .home
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 42, height: 42)
                        .background(
                            LinearGradient(
                                colors: [OnlineBikeTheme.cyanAccent, OnlineBikeTheme.electricBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: RoundedRectangle(cornerRadius: 14)
                        )
                        .shadow(color: OnlineBikeTheme.electricBlue.opacity(0.4), radius: 6, y: 3)
                }

                Spacer()

                Text("My Shopping Cart")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.white)

                Spacer()

                // Clear / Reset Cart
                Button(action: {
                    resetCartToFigmaPreset()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 42, height: 42)
                        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 12)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Itemized Cart List
                    VStack(spacing: 12) {
                        ForEach(cartItems) { item in
                            cartItemRow(item)
                        }
                    }

                    // Free Shipping Notice
                    Text("Your cart qualifies for free shipping")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(OnlineBikeTheme.textSecondary)
                        .padding(.top, 6)

                    // Promo Code Input Box: Bike30 -> Apply
                    HStack(spacing: 8) {
                        HStack {
                            Image(systemName: "ticket.fill")
                                .font(.system(size: 13))
                                .foregroundStyle(OnlineBikeTheme.cyanAccent)
                            TextField("Promo Code", text: $promoCode)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                                .autocorrectionDisabled()
                                #if os(iOS)
                                .textInputAutocapitalization(.characters)
                                #endif
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color(red: 26/255, green: 33/255, blue: 46/255), in: RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )

                        Button(action: {
                            if promoCode.uppercased().trimmingCharacters(in: .whitespaces) == "BIKE30" {
                                isPromoApplied = true
                                showToast("Promo 'Bike30' applied! 30% saved")
                            } else if promoCode.isEmpty {
                                isPromoApplied = false
                                showToast("Promo code removed")
                            } else {
                                showToast("Invalid coupon. Use BIKE30 for 30% off")
                            }
                        }) {
                            Text(isPromoApplied ? "Applied" : "Apply")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        colors: [OnlineBikeTheme.cyanAccent, OnlineBikeTheme.electricBlue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    in: RoundedRectangle(cornerRadius: 14)
                                )
                                .shadow(color: OnlineBikeTheme.electricBlue.opacity(0.4), radius: 6, y: 3)
                        }
                    }

                    // Order Financial Summary
                    VStack(spacing: 10) {
                        summaryLine(label: "Subtotal:", value: String(format: "$%.2f", subtotal))
                        summaryLine(label: "Delivery Fee:", value: "$0")
                        if isPromoApplied {
                            summaryLine(
                                label: "Discount (Bike30):",
                                value: String(format: "-30%% (-$%.2f)", discountAmount),
                                valueColor: OnlineBikeTheme.cyanAccent
                            )
                        }
                        Divider().background(Color.white.opacity(0.12))
                        HStack {
                            Text("Total:")
                                .font(.system(size: 16, weight: .heavy))
                                .foregroundStyle(.white)
                            Spacer()
                            Text(String(format: "$%.2f", grandTotal))
                                .font(.system(size: 24, weight: .black, design: .rounded))
                                .foregroundStyle(OnlineBikeTheme.brightCyan)
                        }
                    }
                    .padding(18)
                    .background(Color(red: 28/255, green: 35/255, blue: 48/255), in: RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )

                    // Checkout Capsule Button
                    Button(action: {
                        showCheckoutSheet = true
                    }) {
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            colors: [OnlineBikeTheme.cyanAccent, OnlineBikeTheme.electricBlue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 42, height: 42)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .heavy))
                                    .foregroundStyle(.white)
                            }

                            Spacer()

                            Text("Checkout")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)

                            Spacer()

                            // Balance spacing
                            Color.clear.frame(width: 42, height: 42)
                        }
                        .padding(6)
                        .background(
                            Color(red: 24/255, green: 30/255, blue: 42/255),
                            in: RoundedRectangle(cornerRadius: 22)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(Color.white.opacity(0.14), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.4), radius: 10, y: 5)
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func cartItemRow(_ item: BikeCartItem) -> some View {
        HStack(spacing: 14) {
            // Rounded Product Tile
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 45/255, green: 56/255, blue: 76/255),
                                Color(red: 30/255, green: 38/255, blue: 54/255)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.white.opacity(0.14), lineWidth: 1)
                    )

                if let img = loadProjectImage(named: item.product.tileImageName) {
                    img
                        .resizable()
                        .scaledToFit()
                        .padding(8)
                } else if let mainImg = loadProjectImage(named: item.product.imageName) {
                    mainImg
                        .resizable()
                        .scaledToFit()
                        .padding(8)
                } else {
                    productFallbackView(item.product)
                        .padding(8)
                }
            }
            .frame(width: 80, height: 80)

            // Info & Price
            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.name)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(item.product.formattedPrice)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(OnlineBikeTheme.cyanAccent)
            }

            Spacer()

            // Quantity Stepper: [+] 1 [-]
            HStack(spacing: 8) {
                Button(action: {
                    updateQuantity(for: item.id, delta: 1)
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 26, height: 26)
                        .background(
                            LinearGradient(
                                colors: [OnlineBikeTheme.cyanAccent, OnlineBikeTheme.electricBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: RoundedRectangle(cornerRadius: 8)
                        )
                }

                Text("\(item.quantity)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(minWidth: 16)

                Button(action: {
                    updateQuantity(for: item.id, delta: -1)
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 26, height: 26)
                        .background(Color(red: 35/255, green: 42/255, blue: 58/255), in: RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(12)
        .background(
            Color(red: 26/255, green: 33/255, blue: 46/255),
            in: RoundedRectangle(cornerRadius: 20)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }

    private func summaryLine(label: String, value: String, valueColor: Color = .white) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(OnlineBikeTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(valueColor)
        }
    }

    // MARK: - SCREEN 4: Ride & Telemetry Map (Tab 2)

    private var rideTelemetryMapView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Live Ride Telemetry")
                            .font(.system(size: 24, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Connected: PEUGEOT - LR01 Smart Sensor")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(OnlineBikeTheme.cyanAccent)
                    }
                    Spacer()
                    Circle()
                        .fill(Color.green)
                        .frame(width: 10, height: 10)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Simulated GPS Route Card
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(red: 28/255, green: 36/255, blue: 50/255))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundStyle(OnlineBikeTheme.cyanAccent)
                            Text("Sunset Coastal Route")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.white)
                            Spacer()
                            Text("14.2 km")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(OnlineBikeTheme.cyanAccent)
                        }

                        // Route line visualization
                        GeometryReader { geo in
                            Path { path in
                                let w = geo.size.width
                                let h = geo.size.height
                                path.move(to: CGPoint(x: 10, y: h * 0.7))
                                path.addCurve(
                                    to: CGPoint(x: w * 0.5, y: h * 0.3),
                                    control1: CGPoint(x: w * 0.25, y: h * 0.1),
                                    control2: CGPoint(x: w * 0.35, y: h * 0.8)
                                )
                                path.addCurve(
                                    to: CGPoint(x: w - 10, y: h * 0.4),
                                    control1: CGPoint(x: w * 0.7, y: h * 0.1),
                                    control2: CGPoint(x: w * 0.85, y: h * 0.7)
                                )
                            }
                            .stroke(
                                LinearGradient(
                                    colors: [OnlineBikeTheme.cyanAccent, OnlineBikeTheme.electricBlue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                        }
                        .frame(height: 100)

                        HStack {
                            Text("Elevation Gain: 340m")
                                .font(.system(size: 11))
                                .foregroundStyle(OnlineBikeTheme.textSecondary)
                            Spacer()
                            Text("Grade: +4.2%")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color.orange)
                        }
                    }
                    .padding(18)
                }
                .frame(height: 190)
                .padding(.horizontal, 16)

                // Live Sensor Metrics Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    metricCard(title: "Speed", value: "28.4", unit: "km/h", icon: "speedometer")
                    metricCard(title: "Cadence", value: "86", unit: "rpm", icon: "arrow.triangle.2.circlepath")
                    metricCard(title: "Power Output", value: "245", unit: "Watts", icon: "bolt.fill")
                    metricCard(title: "Battery Assist", value: "92%", unit: "Eco Mode", icon: "battery.100.bolt")
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 90)
            }
        }
        .overlay(alignment: .bottom) {
            floatingBottomTabBar
        }
    }

    private func metricCard(title: String, value: String, unit: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(OnlineBikeTheme.cyanAccent)
                Spacer()
                Text(unit)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(OnlineBikeTheme.textSecondary)
            }
            Text(value)
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(OnlineBikeTheme.textSecondary)
        }
        .padding(14)
        .background(Color(red: 28/255, green: 35/255, blue: 48/255), in: RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }

    // MARK: - SCREEN 5: Garage & Profile (Tab 4)

    private var garageProfileView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // User Profile Header
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [OnlineBikeTheme.cyanAccent, OnlineBikeTheme.electricBlue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 58, height: 58)
                        Text("SP")
                            .font(.system(size: 20, weight: .black))
                            .foregroundStyle(.white)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Sourasith Phomhome")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                        Text("Pro Cyclist & UI Designer")
                            .font(.system(size: 12))
                            .foregroundStyle(OnlineBikeTheme.textSecondary)
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(Color.yellow)
                            Text("Club Rider Level 4")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(OnlineBikeTheme.cyanAccent)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // My Garage Section
                Text("My Garage (2 Registered)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)

                VStack(spacing: 12) {
                    garageCard(
                        name: "PEUGEOT - LR01",
                        serial: "SN: PG-2026-9812",
                        status: "Active • In Service",
                        image: "BikeTilePeugeot"
                    )
                    garageCard(
                        name: "SMITH - Trade Helmet",
                        serial: "SN: SM-MIPS-4421",
                        status: "Inspected • Optimal",
                        image: "BikeTileHelmet"
                    )
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 90)
            }
        }
        .overlay(alignment: .bottom) {
            floatingBottomTabBar
        }
    }

    private func garageCard(name: String, serial: String, status: String, image: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(red: 35/255, green: 43/255, blue: 58/255))
                if let img = loadProjectImage(named: image) {
                    img
                        .resizable()
                        .scaledToFit()
                        .padding(6)
                }
            }
            .frame(width: 60, height: 60)

            VStack(alignment: .leading, spacing: 3) {
                Text(name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                Text(serial)
                    .font(.system(size: 11))
                    .foregroundStyle(OnlineBikeTheme.textSecondary)
                Text(status)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.green)
            }
            Spacer()
        }
        .padding(12)
        .background(Color(red: 28/255, green: 35/255, blue: 48/255), in: RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }

    // MARK: - SCREEN 6: Order History & Tracking (Tab 5)

    private var orderTrackingView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Order History & Delivery")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                VStack(spacing: 14) {
                    orderCard(
                        orderId: "BK-8921-X",
                        date: "14 Oct 2026",
                        items: "PEUGEOT - LR01",
                        total: "$1,999.99",
                        status: "Out for Delivery",
                        statusColor: OnlineBikeTheme.cyanAccent
                    )
                    orderCard(
                        orderId: "BK-7840-A",
                        date: "02 Oct 2026",
                        items: "SMITH - Trade Helmet, Cycling Gloves",
                        total: "$180.00",
                        status: "Delivered",
                        statusColor: Color.green
                    )
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 90)
            }
        }
        .overlay(alignment: .bottom) {
            floatingBottomTabBar
        }
    }

    private func orderCard(orderId: String, date: String, items: String, total: String, status: String, statusColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Order #\(orderId)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                Text(date)
                    .font(.system(size: 12))
                    .foregroundStyle(OnlineBikeTheme.textSecondary)
            }

            Text(items)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.85))

            HStack {
                Text(total)
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(OnlineBikeTheme.cyanAccent)
                Spacer()
                Text(status)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(statusColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.14), in: Capsule())
            }
        }
        .padding(16)
        .background(Color(red: 28/255, green: 35/255, blue: 48/255), in: RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }

    // MARK: - Checkout Confirmation Modal Sheet

    private var checkoutConfirmationSheet: some View {
        NavigationStack {
            ZStack {
                OnlineBikeTheme.darkMatteNavy.ignoresSafeArea()

                VStack(spacing: 20) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [OnlineBikeTheme.cyanAccent, OnlineBikeTheme.electricBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .padding(.top, 20)

                    Text("Ready for Delivery!")
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Your cart total with 30% discount applied is:")
                        .font(.system(size: 13))
                        .foregroundStyle(OnlineBikeTheme.textSecondary)

                    Text(String(format: "$%.2f", grandTotal))
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(OnlineBikeTheme.brightCyan)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Delivery Address:")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(OnlineBikeTheme.textSecondary)
                            Spacer()
                            Text("742 Evergreen Terrace")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        Divider().background(Color.white.opacity(0.1))
                        HStack {
                            Text("Estimated Arrival:")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(OnlineBikeTheme.textSecondary)
                            Spacer()
                            Text("Tomorrow, 2:00 PM")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Color.green)
                        }
                    }
                    .padding(16)
                    .background(Color(red: 24/255, green: 30/255, blue: 42/255), in: RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 20)

                    Button(action: {
                        showCheckoutSheet = false
                        showToast("Order Placed! Thank you for your purchase.")
                        withAnimation {
                            activeScreen = .orders
                        }
                    }) {
                        Text("Place Order & Pay")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [OnlineBikeTheme.cyanAccent, OnlineBikeTheme.electricBlue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                in: RoundedRectangle(cornerRadius: 16)
                            )
                            .shadow(color: OnlineBikeTheme.electricBlue.opacity(0.4), radius: 8, y: 4)
                    }
                    .padding(.horizontal, 20)

                    Button("Keep Shopping") {
                        showCheckoutSheet = false
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(OnlineBikeTheme.textSecondary)
                }
                .padding()
            }
        }
    }

    // MARK: - Actions & Helpers

    private func addToCart(_ product: BikeProduct) {
        if let idx = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            cartItems[idx].quantity += 1
        } else {
            cartItems.append(BikeCartItem(id: "item-\(cartItems.count + 1)", product: product, quantity: 1))
        }
        showToast("Added \(product.name) to Cart")
    }

    private func updateQuantity(for itemId: String, delta: Int) {
        guard let idx = cartItems.firstIndex(where: { $0.id == itemId }) else { return }
        cartItems[idx].quantity += delta
        if cartItems[idx].quantity <= 0 {
            cartItems.remove(at: idx)
        }
    }

    private func toggleFavorite(for productId: String) {
        if let idx = catalog.firstIndex(where: { $0.id == productId }) {
            catalog[idx].isFavorite.toggle()
            if activeDetailProduct.id == productId {
                activeDetailProduct.isFavorite = catalog[idx].isFavorite
            }
            showToast(catalog[idx].isFavorite ? "Added to Wishlist" : "Removed from Wishlist")
        }
    }

    private func resetCartToFigmaPreset() {
        let peugeot = catalog.first(where: { $0.id == "peugeot-lr01" }) ?? catalog[0]
        let pilot = catalog.first(where: { $0.id == "pilot-chromoly" }) ?? catalog[0]
        let smith = catalog.first(where: { $0.id == "smith-trade" }) ?? catalog[0]
        cartItems = [
            BikeCartItem(id: "item-1", product: peugeot, quantity: 1),
            BikeCartItem(id: "item-2", product: pilot, quantity: 1),
            BikeCartItem(id: "item-3", product: smith, quantity: 1)
        ]
        isPromoApplied = true
        promoCode = "Bike30"
        showToast("Cart restored to Figma preset: $4,283.99")
    }

    private func showToast(_ msg: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            toastMessage = msg
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.3)) {
                if toastMessage == msg {
                    toastMessage = nil
                }
            }
        }
    }

    private func toastBanner(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkles")
                .foregroundStyle(OnlineBikeTheme.cyanAccent)
            Text(text)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Color(red: 20/255, green: 26/255, blue: 38/255).opacity(0.96),
            in: Capsule()
        )
        .overlay(
            Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.35), radius: 10, y: 5)
    }

    // Helper to load image from bundle or assets
    private func loadProjectImage(named: String) -> Image? {
        #if canImport(UIKit)
        if let img = UIImage(named: named) {
            return Image(uiImage: img)
        }
        let localPath = "/tmp/bike_assets/\(named.lowercased()).png"
        if let img = UIImage(contentsOfFile: localPath) {
            return Image(uiImage: img)
        }
        #elseif canImport(AppKit)
        if let img = NSImage(named: named) {
            return Image(nsImage: img)
        }
        let localPath = "/tmp/bike_assets/\(named.lowercased()).png"
        if let img = NSImage(contentsOfFile: localPath) {
            return Image(nsImage: img)
        }
        #endif
        return nil
    }

    // High quality vector fallbacks for items when running headless or in tests
    private func productFallbackView(_ product: BikeProduct) -> some View {
        VStack(spacing: 4) {
            if product.category.contains("Helmet") {
                Image(systemName: "shield.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white.opacity(0.8), Color.gray],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            } else {
                Image(systemName: "bicycle")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [OnlineBikeTheme.cyanAccent, OnlineBikeTheme.electricBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
    }

    private var heroBikeFallbackIllustration: some View {
        Image(systemName: "bicycle")
            .font(.system(size: 64, weight: .light))
            .foregroundStyle(
                LinearGradient(
                    colors: [OnlineBikeTheme.cyanAccent, Color.white],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }
}

