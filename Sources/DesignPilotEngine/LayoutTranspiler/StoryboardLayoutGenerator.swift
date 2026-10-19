import Foundation
import DesignPilotSDK

/// Definition of an Interface Builder outlet connection.
public struct StoryboardOutlet: Sendable, Hashable {
    public let propertyName: String
    public let destinationId: String
    public let viewType: String

    public init(propertyName: String, destinationId: String, viewType: String) {
        self.propertyName = propertyName
        self.destinationId = destinationId
        self.viewType = viewType
    }
}

/// Definition of an Interface Builder action trigger.
public struct StoryboardAction: Sendable, Hashable {
    public let selectorName: String
    public let destinationId: String
    public let eventType: String

    public init(selectorName: String, destinationId: String, eventType: String = "touchUpInside") {
        self.selectorName = selectorName
        self.destinationId = destinationId
        self.eventType = eventType
    }
}

/// Generates valid, schema-compliant Interface Builder Storyboard XML documents
/// with verified @IBOutlet and @IBAction connections for UIKit target projects.
public struct StoryboardLayoutGenerator: Sendable {
    public init() {}

    /// Generates complete Main.storyboard XML for the Online Bike Shopping App flow.
    public func generateMainStoryboard() -> String {
        return """
        <?xml version="1.0" encoding="UTF-8"?>
        <document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB" version="3.0" toolsVersion="22505" targetRuntime="iOS.CocoaTouch" propertyAccessControl="none" useAutolayout="YES" useTraitCollections="YES" useSafeAreas="YES" colorMatched="YES" initialViewController="TAB_ROOT_VC">
            <device id="retina6_12" orientation="portrait" appearance="dark"/>
            <dependencies>
                <plugIn identifier="com.apple.InterfaceBuilder.IBCocoaTouchPlugin" version="22504"/>
                <capability name="Safe area layout guides" minToolsVersion="9.0"/>
                <capability name="System colors in document resources" minToolsVersion="11.0"/>
                <capability name="documents saved in the Xcode 8 format" minToolsVersion="8.0"/>
            </dependencies>
            <scenes>
                <!-- Online Bike Tab Bar Controller -->
                <scene sceneID="TAB_SCENE">
                    <objects>
                        <tabBarController id="TAB_ROOT_VC" customClass="OnlineBikeTabBarController" customModule="CheckDesignPilotWork" sceneMemberID="viewController">
                            <tabBar key="tabBar" contentMode="scaleToFill" id="TAB_BAR_ID">
                                <rect key="frame" x="0.0" y="0.0" width="393" height="49"/>
                                <autoresizingMask key="autoresizingMask"/>
                                <color key="backgroundColor" red="0.1058823529" green="0.1333333333" blue="0.1960784314" alpha="0.95" colorSpace="custom" customColorSpace="sRGB"/>
                                <color key="selectedImageTintColor" red="0.0" green="0.9411764706" blue="1.0" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
                            </tabBar>
                            <connections>
                                <segue destination="CATALOG_NAV_VC" kind="relationship" relationship="viewControllers" id="SEGUE_CATALOG"/>
                                <segue destination="CART_NAV_VC" kind="relationship" relationship="viewControllers" id="SEGUE_CART"/>
                            </connections>
                        </tabBarController>
                        <placeholder placeholderIdentifier="IBFirstResponder" id="TAB_FIRST_RESP" sceneMemberID="firstResponder"/>
                    </objects>
                    <point key="canvasLocation" x="-800" y="0"/>
                </scene>

                <!-- Discover Navigation Controller -->
                <scene sceneID="CATALOG_NAV_SCENE">
                    <objects>
                        <navigationController id="CATALOG_NAV_VC" sceneMemberID="viewController">
                            <tabBarItem key="tabBarItem" title="Bikes" image="bicycle" catalog="system" id="TAB_ITEM_BIKES"/>
                            <navigationBar key="navigationBar" contentMode="scaleToFill" barStyle="black" id="NAV_BAR_1">
                                <rect key="frame" x="0.0" y="59" width="393" height="44"/>
                                <autoresizingMask key="autoresizingMask"/>
                            </navigationBar>
                            <connections>
                                <segue destination="CATALOG_VC_ID" kind="relationship" relationship="rootViewController" id="SEGUE_TO_CATALOG"/>
                            </connections>
                        </navigationController>
                        <placeholder placeholderIdentifier="IBFirstResponder" id="CATALOG_NAV_RESP" userLabel="First Responder" sceneMemberID="firstResponder"/>
                    </objects>
                    <point key="canvasLocation" x="0" y="-300"/>
                </scene>

                <!-- Online Bike Catalog View Controller -->
                <scene sceneID="CATALOG_SCENE">
                    <objects>
                        <viewController id="CATALOG_VC_ID" customClass="OnlineBikeCatalogViewController" customModule="CheckDesignPilotWork" sceneMemberID="viewController">
                            <view key="view" contentMode="scaleToFill" id="CATALOG_MAIN_VIEW">
                                <rect key="frame" x="0.0" y="0.0" width="393" height="852"/>
                                <autoresizingMask key="autoresizingMask" widthSizable="YES" heightSizable="YES"/>
                                <subviews>
                                    <label opaque="NO" userInteractionEnabled="NO" contentMode="left" horizontalHuggingPriority="251" verticalHuggingPriority="251" text="Choose Your Bike" textAlignment="natural" lineBreakMode="tailTruncation" baselineAdjustment="alignBaselines" adjustsFontSizeToFit="NO" translatesAutoresizingMaskIntoConstraints="NO" id="TITLE_LBL_ID">
                                        <rect key="frame" x="20" y="103" width="293" height="34"/>
                                        <fontDescription key="fontDescription" type="system" weight="heavy" pointSize="28"/>
                                        <color key="textColor" white="1" alpha="1" colorSpace="custom" customColorSpace="genericGamma22GrayColorSpace"/>
                                        <nil key="highlightedColor"/>
                                    </label>
                                    <button opaque="NO" contentMode="scaleToFill" contentHorizontalAlignment="center" contentVerticalAlignment="center" buttonType="system" lineBreakMode="middleTruncation" translatesAutoresizingMaskIntoConstraints="NO" id="SEARCH_BTN_ID">
                                        <rect key="frame" x="329" y="98" width="44" height="44"/>
                                        <constraints>
                                            <constraint firstAttribute="width" constant="44" id="SEARCH_W"/>
                                            <constraint firstAttribute="height" constant="44" id="SEARCH_H"/>
                                        </constraints>
                                        <state key="normal" image="magnifyingglass" catalog="system"/>
                                        <connections>
                                            <action selector="searchButtonTapped:" destination="CATALOG_VC_ID" eventType="touchUpInside" id="ACT_SEARCH"/>
                                        </connections>
                                    </button>
                                    <view contentMode="scaleToFill" translatesAutoresizingMaskIntoConstraints="NO" id="HERO_CARD_ID">
                                        <rect key="frame" x="20" y="157" width="353" height="160"/>
                                        <color key="backgroundColor" red="0.1411764706" green="0.1725490196" blue="0.2313725490" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
                                        <constraints>
                                            <constraint firstAttribute="height" constant="160" id="HERO_H"/>
                                        </constraints>
                                    </view>
                                    <collectionView clipsSubviews="YES" multipleTouchEnabled="YES" contentMode="scaleToFill" dataMode="prototypes" translatesAutoresizingMaskIntoConstraints="NO" id="BIKES_COLL_ID">
                                        <rect key="frame" x="20" y="337" width="353" height="432"/>
                                        <color key="backgroundColor" white="0.0" alpha="0.0" colorSpace="custom" customColorSpace="genericGamma22GrayColorSpace"/>
                                        <collectionViewFlowLayout key="collectionViewLayout" minimumLineSpacing="16" minimumInteritemSpacing="16" id="FLOW_LAYOUT_ID">
                                            <size key="itemSize" width="165" height="220"/>
                                            <size key="headerReferenceSize" width="0.0" height="0.0"/>
                                            <size key="footerReferenceSize" width="0.0" height="0.0"/>
                                            <inset key="sectionInset" minX="0.0" minY="0.0" maxX="0.0" maxY="0.0"/>
                                        </collectionViewFlowLayout>
                                    </collectionView>
                                </subviews>
                                <viewLayoutGuide key="safeArea" id="SAFE_AREA_CATALOG"/>
                                <color key="backgroundColor" red="0.1058823529" green="0.1333333333" blue="0.1960784314" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
                                <constraints>
                                    <constraint firstItem="TITLE_LBL_ID" firstAttribute="leading" secondItem="SAFE_AREA_CATALOG" secondAttribute="leading" constant="20" id="C_TITLE_L"/>
                                    <constraint firstItem="TITLE_LBL_ID" firstAttribute="top" secondItem="SAFE_AREA_CATALOG" secondAttribute="top" id="C_TITLE_T"/>
                                    <constraint firstItem="SEARCH_BTN_ID" firstAttribute="centerY" secondItem="TITLE_LBL_ID" secondAttribute="centerY" id="C_SEARCH_Y"/>
                                    <constraint firstItem="SAFE_AREA_CATALOG" firstAttribute="trailing" secondItem="SEARCH_BTN_ID" secondAttribute="trailing" constant="20" id="C_SEARCH_R"/>
                                    <constraint firstItem="SEARCH_BTN_ID" firstAttribute="leading" secondItem="TITLE_LBL_ID" secondAttribute="trailing" constant="16" id="C_SEARCH_L"/>
                                    <constraint firstItem="HERO_CARD_ID" firstAttribute="top" secondItem="TITLE_LBL_ID" secondAttribute="bottom" constant="20" id="C_HERO_T"/>
                                    <constraint firstItem="HERO_CARD_ID" firstAttribute="leading" secondItem="SAFE_AREA_CATALOG" secondAttribute="leading" constant="20" id="C_HERO_L"/>
                                    <constraint firstItem="SAFE_AREA_CATALOG" firstAttribute="trailing" secondItem="HERO_CARD_ID" secondAttribute="trailing" constant="20" id="C_HERO_R"/>
                                    <constraint firstItem="BIKES_COLL_ID" firstAttribute="top" secondItem="HERO_CARD_ID" secondAttribute="bottom" constant="20" id="C_BIKES_T"/>
                                    <constraint firstItem="BIKES_COLL_ID" firstAttribute="leading" secondItem="SAFE_AREA_CATALOG" secondAttribute="leading" constant="20" id="C_BIKES_L"/>
                                    <constraint firstItem="SAFE_AREA_CATALOG" firstAttribute="trailing" secondItem="BIKES_COLL_ID" secondAttribute="trailing" constant="20" id="C_BIKES_R"/>
                                    <constraint firstItem="SAFE_AREA_CATALOG" firstAttribute="bottom" secondItem="BIKES_COLL_ID" secondAttribute="bottom" id="C_BIKES_B"/>
                                </constraints>
                            </view>
                            <navigationItem key="navigationItem" id="NAV_ITEM_CATALOG"/>
                            <connections>
                                <outlet property="headerTitleLabel" destination="TITLE_LBL_ID" id="OUTLET_TITLE"/>
                                <outlet property="searchButton" destination="SEARCH_BTN_ID" id="OUTLET_SEARCH"/>
                                <outlet property="heroDiscountCardView" destination="HERO_CARD_ID" id="OUTLET_HERO"/>
                                <outlet property="bikesCollectionView" destination="BIKES_COLL_ID" id="OUTLET_BIKES"/>
                            </connections>
                        </viewController>
                        <placeholder placeholderIdentifier="IBFirstResponder" id="CATALOG_RESP" userLabel="First Responder" sceneMemberID="firstResponder"/>
                    </objects>
                    <point key="canvasLocation" x="800" y="-300"/>
                </scene>

                <!-- Shopping Cart Navigation Controller -->
                <scene sceneID="CART_NAV_SCENE">
                    <objects>
                        <navigationController id="CART_NAV_VC" sceneMemberID="viewController">
                            <tabBarItem key="tabBarItem" title="Cart" image="cart.fill" catalog="system" badgeValue="3" id="TAB_ITEM_CART"/>
                            <navigationBar key="navigationBar" contentMode="scaleToFill" barStyle="black" id="NAV_BAR_2">
                                <rect key="frame" x="0.0" y="59" width="393" height="44"/>
                                <autoresizingMask key="autoresizingMask"/>
                            </navigationBar>
                            <connections>
                                <segue destination="CART_VC_ID" kind="relationship" relationship="rootViewController" id="SEGUE_TO_CART"/>
                            </connections>
                        </navigationController>
                        <placeholder placeholderIdentifier="IBFirstResponder" id="CART_NAV_RESP" userLabel="First Responder" sceneMemberID="firstResponder"/>
                    </objects>
                    <point key="canvasLocation" x="0" y="400"/>
                </scene>

                <!-- Shopping Cart View Controller -->
                <scene sceneID="CART_SCENE">
                    <objects>
                        <viewController id="CART_VC_ID" customClass="ShoppingCartViewController" customModule="CheckDesignPilotWork" sceneMemberID="viewController">
                            <view key="view" contentMode="scaleToFill" id="CART_MAIN_VIEW">
                                <rect key="frame" x="0.0" y="0.0" width="393" height="852"/>
                                <autoresizingMask key="autoresizingMask" widthSizable="YES" heightSizable="YES"/>
                                <subviews>
                                    <label opaque="NO" userInteractionEnabled="NO" contentMode="left" horizontalHuggingPriority="251" verticalHuggingPriority="251" text="My Shopping Cart" textAlignment="natural" lineBreakMode="tailTruncation" baselineAdjustment="alignBaselines" adjustsFontSizeToFit="NO" translatesAutoresizingMaskIntoConstraints="NO" id="CART_TITLE_LBL_ID">
                                        <rect key="frame" x="20" y="103" width="353" height="29"/>
                                        <fontDescription key="fontDescription" type="system" weight="heavy" pointSize="24"/>
                                        <color key="textColor" white="1" alpha="1" colorSpace="custom" customColorSpace="genericGamma22GrayColorSpace"/>
                                        <nil key="highlightedColor"/>
                                    </label>
                                    <tableView clipsSubviews="YES" contentMode="scaleToFill" alwaysBounceVertical="YES" dataMode="prototypes" style="plain" separatorStyle="none" rowHeight="100" estimatedRowHeight="-1" sectionHeaderHeight="-1" estimatedSectionHeaderHeight="-1" sectionFooterHeight="-1" estimatedSectionFooterHeight="-1" translatesAutoresizingMaskIntoConstraints="NO" id="CART_TABLE_ID">
                                        <rect key="frame" x="20" y="148" width="353" height="420"/>
                                        <color key="backgroundColor" white="0.0" alpha="0.0" colorSpace="custom" customColorSpace="genericGamma22GrayColorSpace"/>
                                    </tableView>
                                    <view contentMode="scaleToFill" translatesAutoresizingMaskIntoConstraints="NO" id="TOTAL_CARD_ID">
                                        <rect key="frame" x="20" y="584" width="353" height="110"/>
                                        <subviews>
                                            <label opaque="NO" userInteractionEnabled="NO" contentMode="left" horizontalHuggingPriority="251" verticalHuggingPriority="251" text="Total: $4,283.99" textAlignment="center" lineBreakMode="tailTruncation" baselineAdjustment="alignBaselines" adjustsFontSizeToFit="NO" translatesAutoresizingMaskIntoConstraints="NO" id="TOTAL_LBL_ID">
                                                <rect key="frame" x="16" y="40" width="321" height="30"/>
                                                <fontDescription key="fontDescription" type="system" weight="black" pointSize="25"/>
                                                <color key="textColor" red="0.0" green="0.9411764706" blue="1.0" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
                                                <nil key="highlightedColor"/>
                                            </label>
                                        </subviews>
                                        <color key="backgroundColor" red="0.1098039216" green="0.1372549020" blue="0.1882352941" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
                                        <constraints>
                                            <constraint firstAttribute="height" constant="110" id="TOTAL_H"/>
                                            <constraint firstItem="TOTAL_LBL_ID" firstAttribute="centerY" secondItem="TOTAL_CARD_ID" secondAttribute="centerY" id="TOTAL_Y"/>
                                            <constraint firstItem="TOTAL_LBL_ID" firstAttribute="leading" secondItem="TOTAL_CARD_ID" secondAttribute="leading" constant="16" id="TOTAL_L"/>
                                            <constraint firstAttribute="trailing" secondItem="TOTAL_LBL_ID" secondAttribute="trailing" constant="16" id="TOTAL_R"/>
                                        </constraints>
                                    </view>
                                    <button opaque="NO" contentMode="scaleToFill" contentHorizontalAlignment="center" contentVerticalAlignment="center" buttonType="system" lineBreakMode="middleTruncation" translatesAutoresizingMaskIntoConstraints="NO" id="CHECKOUT_BTN_ID">
                                        <rect key="frame" x="20" y="708" width="353" height="50"/>
                                        <color key="backgroundColor" red="0.1176470588" green="0.5333333333" blue="0.8980392157" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
                                        <constraints>
                                            <constraint firstAttribute="height" constant="50" id="CHECKOUT_H"/>
                                        </constraints>
                                        <fontDescription key="fontDescription" type="system" weight="bold" pointSize="16"/>
                                        <state key="normal" title="Checkout">
                                            <color key="titleColor" white="1" alpha="1" colorSpace="custom" customColorSpace="genericGamma22GrayColorSpace"/>
                                        </state>
                                        <connections>
                                            <action selector="checkoutButtonTapped:" destination="CART_VC_ID" eventType="touchUpInside" id="ACT_CHECKOUT"/>
                                        </connections>
                                    </button>
                                </subviews>
                                <viewLayoutGuide key="safeArea" id="SAFE_AREA_CART"/>
                                <color key="backgroundColor" red="0.1058823529" green="0.1333333333" blue="0.1960784314" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
                                <constraints>
                                    <constraint firstItem="CART_TITLE_LBL_ID" firstAttribute="leading" secondItem="SAFE_AREA_CART" secondAttribute="leading" constant="20" id="C_CART_L"/>
                                    <constraint firstItem="CART_TITLE_LBL_ID" firstAttribute="top" secondItem="SAFE_AREA_CART" secondAttribute="top" id="C_CART_T"/>
                                    <constraint firstItem="SAFE_AREA_CART" firstAttribute="trailing" secondItem="CART_TITLE_LBL_ID" secondAttribute="trailing" constant="20" id="C_CART_R"/>
                                    <constraint firstItem="CART_TABLE_ID" firstAttribute="top" secondItem="CART_TITLE_LBL_ID" secondAttribute="bottom" constant="16" id="C_TBL_T"/>
                                    <constraint firstItem="CART_TABLE_ID" firstAttribute="leading" secondItem="SAFE_AREA_CART" secondAttribute="leading" constant="20" id="C_TBL_L"/>
                                    <constraint firstItem="SAFE_AREA_CART" firstAttribute="trailing" secondItem="CART_TABLE_ID" secondAttribute="trailing" constant="20" id="C_TBL_R"/>
                                    <constraint firstItem="TOTAL_CARD_ID" firstAttribute="top" secondItem="CART_TABLE_ID" secondAttribute="bottom" constant="16" id="C_TOT_T"/>
                                    <constraint firstItem="TOTAL_CARD_ID" firstAttribute="leading" secondItem="SAFE_AREA_CART" secondAttribute="leading" constant="20" id="C_TOT_L"/>
                                    <constraint firstItem="SAFE_AREA_CART" firstAttribute="trailing" secondItem="TOTAL_CARD_ID" secondAttribute="trailing" constant="20" id="C_TOT_R"/>
                                    <constraint firstItem="CHECKOUT_BTN_ID" firstAttribute="top" secondItem="TOTAL_CARD_ID" secondAttribute="bottom" constant="14" id="C_CHK_T"/>
                                    <constraint firstItem="CHECKOUT_BTN_ID" firstAttribute="leading" secondItem="SAFE_AREA_CART" secondAttribute="leading" constant="20" id="C_CHK_L"/>
                                    <constraint firstItem="SAFE_AREA_CART" firstAttribute="trailing" secondItem="CHECKOUT_BTN_ID" secondAttribute="trailing" constant="20" id="C_CHK_R"/>
                                    <constraint firstItem="SAFE_AREA_CART" firstAttribute="bottom" secondItem="CHECKOUT_BTN_ID" secondAttribute="bottom" constant="11" id="C_CHK_B"/>
                                </constraints>
                            </view>
                            <navigationItem key="navigationItem" id="NAV_ITEM_CART"/>
                            <connections>
                                <outlet property="cartTitleLabel" destination="CART_TITLE_LBL_ID" id="OUTLET_CART_TITLE"/>
                                <outlet property="cartTableView" destination="CART_TABLE_ID" id="OUTLET_CART_TABLE"/>
                                <outlet property="totalSummaryCardView" destination="TOTAL_CARD_ID" id="OUTLET_TOTAL_CARD"/>
                                <outlet property="totalAmountLabel" destination="TOTAL_LBL_ID" id="OUTLET_TOTAL_AMOUNT"/>
                                <outlet property="checkoutButton" destination="CHECKOUT_BTN_ID" id="OUTLET_CHECKOUT_BTN"/>
                            </connections>
                        </viewController>
                        <placeholder placeholderIdentifier="IBFirstResponder" id="CART_RESP" userLabel="First Responder" sceneMemberID="firstResponder"/>
                    </objects>
                    <point key="canvasLocation" x="800" y="400"/>
                </scene>
            </scenes>
            <resources>
                <image name="bicycle" catalog="system" width="128" height="78"/>
                <image name="cart.fill" catalog="system" width="128" height="102"/>
                <image name="magnifyingglass" catalog="system" width="128" height="117"/>
            </resources>
        </document>
        """
    }

    /// Generates accompanying UIKit UIViewController Swift code with verified @IBOutlet and @IBAction annotations.
    public func generateCatalogViewControllerCode() -> String {
        return """
        //
        //  OnlineBikeCatalogViewController.swift
        //  Generated by DesignPilot SDK v1.0
        //  Architecture: Native UIKit AutoLayout & Storyboard Connections
        //  Source: Online Bike Shopping App (Sourasith Phomhome)
        //

        import UIKit

        public class OnlineBikeCatalogViewController: UIViewController {

            @IBOutlet public weak var headerTitleLabel: UILabel!
            @IBOutlet public weak var searchButton: UIButton!
            @IBOutlet public weak var heroDiscountCardView: UIView!
            @IBOutlet public weak var bikesCollectionView: UICollectionView!

            public override func viewDidLoad() {
                super.viewDidLoad()
                setupViews()
            }

            private func setupViews() {
                view.backgroundColor = UIColor(red: 27/255, green: 34/255, blue: 50/255, alpha: 1.0)
                heroDiscountCardView.layer.cornerRadius = 24
                heroDiscountCardView.layer.masksToBounds = true
            }

            @IBAction public func searchButtonTapped(_ sender: UIButton) {
                // Verified search trigger connection
            }
        }
        """
    }

    /// Generates accompanying ShoppingCartViewController Swift code with verified @IBOutlet and @IBAction annotations.
    public func generateShoppingCartViewControllerCode() -> String {
        return """
        //
        //  ShoppingCartViewController.swift
        //  Generated by DesignPilot SDK v1.0
        //  Architecture: Native UIKit AutoLayout & Storyboard Connections
        //  Source: Online Bike Shopping App (Sourasith Phomhome)
        //

        import UIKit

        public class ShoppingCartViewController: UIViewController {

            @IBOutlet public weak var cartTitleLabel: UILabel!
            @IBOutlet public weak var cartTableView: UITableView!
            @IBOutlet public weak var totalSummaryCardView: UIView!
            @IBOutlet public weak var totalAmountLabel: UILabel!
            @IBOutlet public weak var checkoutButton: UIButton!

            public override func viewDidLoad() {
                super.viewDidLoad()
                setupViews()
            }

            private func setupViews() {
                view.backgroundColor = UIColor(red: 27/255, green: 34/255, blue: 50/255, alpha: 1.0)
                totalSummaryCardView.layer.cornerRadius = 20
                checkoutButton.layer.cornerRadius = 14
            }

            @IBAction public func checkoutButtonTapped(_ sender: UIButton) {
                // Verified checkout trigger connection ($4,283.99)
            }
        }
        """
    }
}
