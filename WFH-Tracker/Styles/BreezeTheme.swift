import SwiftUI
import UIKit

// MARK: - Breeze Design System
// Fresh & airy mint/sky environment, warm coral/gold/pink work-type energy.
// All colours are dynamic — automatically adapt to the OS light/dark setting.

private func breezeColor(
    light: (CGFloat, CGFloat, CGFloat),
    dark:  (CGFloat, CGFloat, CGFloat)
) -> Color {
    Color(UIColor { traits in
        let (r, g, b) = traits.userInterfaceStyle == .dark ? dark : light
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    })
}

extension Color {
    // Environment
    static let breezeBackground    = breezeColor(light: (0.918, 0.957, 0.969), dark: (0.055, 0.125, 0.149))   // #EAF4F7 / #0E2026
    static let breezeSurface       = breezeColor(light: (1.000, 1.000, 1.000), dark: (0.086, 0.192, 0.227))   // #FFFFFF / #16313A
    static let breezeSurfaceSoft   = breezeColor(light: (0.957, 0.980, 0.984), dark: (0.106, 0.227, 0.267))   // #F4FAFB / #1B3A44
    static let breezeSurfaceSunken = breezeColor(light: (0.914, 0.953, 0.961), dark: (0.067, 0.165, 0.196))   // #E9F3F5 / #112A32

    // Ink
    static let breezeInk           = breezeColor(light: (0.090, 0.227, 0.259), dark: (0.918, 0.965, 0.969))   // #173A42 / #EAF6F7
    static let breezeInkMuted      = breezeColor(light: (0.318, 0.439, 0.475), dark: (0.608, 0.737, 0.769))   // #517079 / #9BBCC4
    static let breezeInkFaint      = breezeColor(light: (0.541, 0.651, 0.678), dark: (0.384, 0.518, 0.553))   // #8AA6AD / #62848D

    // Lines
    static let breezeLine          = breezeColor(light: (0.859, 0.914, 0.925), dark: (0.149, 0.278, 0.318))   // #DBE9EC / #264751
    static let breezeLineStrong    = breezeColor(light: (0.773, 0.859, 0.878), dark: (0.208, 0.353, 0.392))   // #C5DBE0 / #355A64

    // Brand — sky
    static let breezeBrand         = breezeColor(light: (0.184, 0.706, 0.851), dark: (0.298, 0.776, 0.918))   // #2FB4D9 / #4CC6EA
    static let breezeBrandInk      = breezeColor(light: (0.055, 0.486, 0.612), dark: (0.651, 0.894, 0.969))   // #0E7C9C / #A6E4F7
    static let breezeBrandSoft     = breezeColor(light: (0.863, 0.945, 0.973), dark: (0.071, 0.227, 0.278))   // #DCF1F8 / #123A47

    // Home — coral
    static let breezeHome          = breezeColor(light: (1.000, 0.541, 0.357), dark: (1.000, 0.604, 0.431))   // #FF8A5B / #FF9A6E
    static let breezeHomeSoft      = breezeColor(light: (1.000, 0.902, 0.855), dark: (0.227, 0.149, 0.125))   // #FFE6DA / #3A2620
    static let breezeHomeInk       = breezeColor(light: (0.761, 0.286, 0.122), dark: (1.000, 0.722, 0.608))   // #C2491F / #FFB89B

    // Office — mint
    static let breezeOffice        = breezeColor(light: (0.125, 0.773, 0.592), dark: (0.212, 0.839, 0.675))   // #20C597 / #36D6AC
    static let breezeOfficeSoft    = breezeColor(light: (0.824, 0.957, 0.922), dark: (0.063, 0.196, 0.161))   // #D2F4EB / #103229
    static let breezeOfficeInk     = breezeColor(light: (0.043, 0.494, 0.376), dark: (0.482, 0.914, 0.800))   // #0B7E60 / #7BE9CC

    // Holiday — gold
    static let breezeHoliday       = breezeColor(light: (1.000, 0.761, 0.200), dark: (1.000, 0.808, 0.329))   // #FFC233 / #FFCE54
    static let breezeHolidaySoft   = breezeColor(light: (1.000, 0.941, 0.788), dark: (0.220, 0.188, 0.059))   // #FFF0C9 / #38300F
    static let breezeHolidayInk    = breezeColor(light: (0.663, 0.475, 0.039), dark: (1.000, 0.875, 0.549))   // #A9790A / #FFDF8C

    // Sick — rose
    static let breezeSick          = breezeColor(light: (1.000, 0.478, 0.635), dark: (1.000, 0.561, 0.690))   // #FF7AA2 / #FF8FB0
    static let breezeSickSoft      = breezeColor(light: (1.000, 0.878, 0.918), dark: (0.220, 0.122, 0.157))   // #FFE0EA / #381F28
    static let breezeSickInk       = breezeColor(light: (0.773, 0.243, 0.416), dark: (1.000, 0.714, 0.800))   // #C53E6A / #FFB6CC
}

// MARK: - Gradients

extension LinearGradient {
    // Brand gradient — light: #58C9EA→#2FB4D9 / dark: #57CDEE→#2FA7CE
    static let breezeBrandGrad = LinearGradient(
        colors: [
            breezeColor(light: (0.345, 0.788, 0.918), dark: (0.341, 0.804, 0.933)),
            breezeColor(light: (0.184, 0.706, 0.851), dark: (0.184, 0.655, 0.808))
        ],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    // Warm (home/coral) gradient — dark end uses the dark home colour
    static let breezeWarmGrad = LinearGradient(
        colors: [
            breezeColor(light: (1.0, 0.690, 0.478), dark: (1.0, 0.659, 0.467)),
            breezeColor(light: (1.0, 0.541, 0.357), dark: (1.0, 0.604, 0.431))
        ],
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
        let c = Color(UIColor { t in
            t.userInterfaceStyle == .dark
                ? UIColor(red: 0,    green: 0,    blue: 0,    alpha: 0.30)
                : UIColor(red: 0.09, green: 0.23, blue: 0.26, alpha: 0.06)
        })
        return self
            .shadow(color: c, radius: 1.5, x: 0, y: 1)
            .shadow(color: c, radius: 3,   x: 0, y: 1)
    }

    func breezeShadowMd() -> some View {
        let c = Color(UIColor { t in
            t.userInterfaceStyle == .dark
                ? UIColor(red: 0,    green: 0,    blue: 0,    alpha: 0.50)
                : UIColor(red: 0.09, green: 0.23, blue: 0.26, alpha: 0.18)
        })
        return self.shadow(color: c, radius: 11, x: 0, y: 4)
    }

    func breezeShadowBrand() -> some View {
        let c = Color(UIColor { t in
            t.userInterfaceStyle == .dark
                ? UIColor(red: 0.184, green: 0.655, blue: 0.808, alpha: 0.50)
                : UIColor(red: 0.184, green: 0.706, blue: 0.851, alpha: 0.55)
        })
        return self.shadow(color: c, radius: 13, x: 0, y: 6)
    }

    func breezeShadowWarm() -> some View {
        let c = Color(UIColor { t in
            t.userInterfaceStyle == .dark
                ? UIColor(red: 1.0, green: 0.541, blue: 0.357, alpha: 0.35)
                : UIColor(red: 1.0, green: 0.541, blue: 0.357, alpha: 0.50)
        })
        return self.shadow(color: c, radius: 13, x: 0, y: 6)
    }
}
