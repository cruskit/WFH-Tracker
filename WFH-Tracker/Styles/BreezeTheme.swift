import SwiftUI

// MARK: - Breeze Design System
// Fresh & airy mint/sky environment, warm coral/gold/pink work-type energy.

extension Color {
    // Environment
    static let breezeBackground    = Color(red: 0.918, green: 0.957, blue: 0.969)   // #EAF4F7
    static let breezeSurface       = Color.white
    static let breezeSurfaceSoft   = Color(red: 0.957, green: 0.980, blue: 0.984)   // #F4FAFB
    static let breezeSurfaceSunken = Color(red: 0.914, green: 0.953, blue: 0.961)   // #E9F3F5

    // Ink
    static let breezeInk           = Color(red: 0.090, green: 0.227, blue: 0.259)   // #173A42
    static let breezeInkMuted      = Color(red: 0.318, green: 0.439, blue: 0.475)   // #517079
    static let breezeInkFaint      = Color(red: 0.541, green: 0.651, blue: 0.678)   // #8AA6AD

    // Lines
    static let breezeLine          = Color(red: 0.859, green: 0.914, blue: 0.925)   // #DBE9EC
    static let breezeLineStrong    = Color(red: 0.773, green: 0.859, blue: 0.878)   // #C5DBE0

    // Brand — sky
    static let breezeBrand         = Color(red: 0.184, green: 0.706, blue: 0.851)   // #2FB4D9
    static let breezeBrandInk      = Color(red: 0.055, green: 0.486, blue: 0.612)   // #0E7C9C
    static let breezeBrandSoft     = Color(red: 0.863, green: 0.945, blue: 0.973)   // #DCF1F8

    // Home — coral
    static let breezeHome          = Color(red: 1.000, green: 0.541, blue: 0.357)   // #FF8A5B
    static let breezeHomeSoft      = Color(red: 1.000, green: 0.902, blue: 0.855)   // #FFE6DA
    static let breezeHomeInk       = Color(red: 0.761, green: 0.286, blue: 0.122)   // #C2491F

    // Office — mint
    static let breezeOffice        = Color(red: 0.125, green: 0.773, blue: 0.592)   // #20C597
    static let breezeOfficeSoft    = Color(red: 0.824, green: 0.957, blue: 0.922)   // #D2F4EB
    static let breezeOfficeInk     = Color(red: 0.043, green: 0.494, blue: 0.376)   // #0B7E60

    // Holiday — gold
    static let breezeHoliday       = Color(red: 1.000, green: 0.761, blue: 0.200)   // #FFC233
    static let breezeHolidaySoft   = Color(red: 1.000, green: 0.941, blue: 0.788)   // #FFF0C9
    static let breezeHolidayInk    = Color(red: 0.663, green: 0.475, blue: 0.039)   // #A9790A

    // Sick — rose
    static let breezeSick          = Color(red: 1.000, green: 0.478, blue: 0.635)   // #FF7AA2
    static let breezeSickSoft      = Color(red: 1.000, green: 0.878, blue: 0.918)   // #FFE0EA
    static let breezeSickInk       = Color(red: 0.773, green: 0.243, blue: 0.416)   // #C53E6A
}

// MARK: - Gradients

extension LinearGradient {
    static let breezeBrandGrad = LinearGradient(
        colors: [Color(red: 0.345, green: 0.788, blue: 0.918),
                 Color(red: 0.184, green: 0.706, blue: 0.851)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let breezeWarmGrad = LinearGradient(
        colors: [Color(red: 1.0, green: 0.690, blue: 0.478),
                 Color(red: 1.0, green: 0.541, blue: 0.357)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
}

// MARK: - Typography (SF Rounded approximates Fredoka)

extension Font {
    static func breezeDisplay(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
}

// MARK: - Shadow helpers

extension View {
    func breezeShadowSm() -> some View {
        self
            .shadow(color: Color(red: 0.09, green: 0.23, blue: 0.26).opacity(0.06), radius: 1.5, x: 0, y: 1)
            .shadow(color: Color(red: 0.09, green: 0.23, blue: 0.26).opacity(0.05), radius: 3, x: 0, y: 1)
    }

    func breezeShadowMd() -> some View {
        self.shadow(color: Color(red: 0.09, green: 0.23, blue: 0.26).opacity(0.18), radius: 11, x: 0, y: 4)
    }

    func breezeShadowBrand() -> some View {
        self.shadow(color: Color.breezeBrand.opacity(0.55), radius: 13, x: 0, y: 6)
    }

    func breezeShadowWarm() -> some View {
        self.shadow(color: Color.breezeHome.opacity(0.5), radius: 13, x: 0, y: 6)
    }
}
