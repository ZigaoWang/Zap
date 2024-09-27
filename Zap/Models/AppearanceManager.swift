//
//  AppearanceManager.swift
//  Zap
//
//  Created by Zigao Wang on 9/27/24.
//

import SwiftUI

class AppearanceManager: ObservableObject {
    @AppStorage("appTheme") var appTheme: AppTheme = .system
    @AppStorage("accentColorString") var accentColorString: String = "blue" {
        didSet {
            accentColor = Color(hex: accentColorString) ?? .blue
        }
    }
    @Published var accentColor: Color = .blue
    @AppStorage("fontSize") var fontSize: FontSize = .medium {
        didSet {
            fontSizeValue = getFontSize(fontSize)
        }
    }
    @AppStorage("listViewStyle") var listViewStyle: ListViewStyle = .standard
    
    @Published var fontSizeValue: CGFloat = 16 // Default to medium
    
    enum AppTheme: String, CaseIterable {
        case light, dark, system
    }
    
    enum FontSize: String, CaseIterable {
        case small, medium, large
    }
    
    enum ListViewStyle: String, CaseIterable {
        case compact, standard, expanded
    }
    
    init() {
        self.accentColor = Color(hex: accentColorString) ?? .blue
        self.fontSizeValue = getFontSize(fontSize)
    }
    
    var colorScheme: ColorScheme? {
        switch appTheme {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
    
    private func getFontSize(_ size: FontSize) -> CGFloat {
        switch size {
        case .small: return 14
        case .medium: return 16
        case .large: return 18
        }
    }
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }
    
    func toHex() -> String? {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        if components.count >= 4 {
            a = Float(components[3])
        }

        if a != Float(1.0) {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}

struct FontSizeKey: EnvironmentKey {
    static let defaultValue: CGFloat = 16
}

extension EnvironmentValues {
    var customFontSize: CGFloat {
        get { self[FontSizeKey.self] }
        set { self[FontSizeKey.self] = newValue }
    }
}

struct AppearanceKey: EnvironmentKey {
    static let defaultValue = AppearanceManager()
}

extension EnvironmentValues {
    var appearance: AppearanceManager {
        get { self[AppearanceKey.self] }
        set { self[AppearanceKey.self] = newValue }
    }
}
