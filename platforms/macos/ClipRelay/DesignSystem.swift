// DesignSystem.swift — ClipRelay macOS
// Complete design token system: colors, typography, components, and button styles.

import SwiftUI
import AppKit

// MARK: - Adaptive Color Helper

extension Color {
    init(light: Color, dark: Color) {
        self.init(nsColor: NSColor(name: nil) { appearance in
            switch appearance.bestMatch(from: [.aqua, .darkAqua]) {
            case .darkAqua: return NSColor(dark)
            default:        return NSColor(light)
            }
        })
    }
}

// MARK: - PBTheme — Design Tokens

enum PBTheme {

    // ── Backgrounds ───────────────────────────────────────────────────────────
    static var backgroundTop: Color {
        Color(light: Color(red: 0.97, green: 0.97, blue: 0.99),
              dark:  Color(red: 0.09, green: 0.09, blue: 0.12))
    }
    static var backgroundBottom: Color {
        Color(light: Color(red: 0.93, green: 0.94, blue: 0.97),
              dark:  Color(red: 0.06, green: 0.06, blue: 0.09))
    }

    // ── Sidebar (rich navy-indigo gradient) ───────────────────────────────────
    static var sidebarTop: Color {
        Color(light: Color(red: 0.12, green: 0.14, blue: 0.26),
              dark:  Color(red: 0.08, green: 0.09, blue: 0.16))
    }
    static var sidebarBottom: Color {
        Color(light: Color(red: 0.08, green: 0.10, blue: 0.20),
              dark:  Color(red: 0.04, green: 0.05, blue: 0.10))
    }

    // ── Accents (Apple HIG palette) ───────────────────────────────────────────
    static let accentBlue    = Color(red: 0/255,   green: 122/255, blue: 255/255) // #007AFF
    static let accentGreen   = Color(red: 52/255,  green: 199/255, blue: 89/255)  // #34C759
    static let accentGold    = Color(red: 255/255, green: 159/255, blue: 10/255)  // #FF9F0A
    static let accentOrange  = Color(red: 255/255, green: 107/255, blue: 0/255)   // #FF6B00
    static let accentPurple  = Color(red: 175/255, green: 82/255,  blue: 222/255) // #AF52DE
    static let accentRed     = Color(red: 255/255, green: 59/255,  blue: 48/255)  // #FF3B30
    static let accentIndigo  = Color(red: 94/255,  green: 92/255,  blue: 230/255) // #5E5CE6
    static let accentTeal    = Color(red: 50/255,  green: 173/255, blue: 230/255) // #32ADE6

    // ── Text ──────────────────────────────────────────────────────────────────
    static var ink: Color       { Color(nsColor: .labelColor) }
    static var inkSoft: Color   { Color(nsColor: .secondaryLabelColor) }
    static var inkSubtle: Color { Color(nsColor: .tertiaryLabelColor) }

    // ── Surfaces ──────────────────────────────────────────────────────────────
    static var surface: Color        { Color(nsColor: .controlBackgroundColor) }
    static var surfaceStrong: Color  { Color(nsColor: .textBackgroundColor) }
    static var surfaceElevated: Color{ Color(nsColor: .windowBackgroundColor) }

    // ── Borders ───────────────────────────────────────────────────────────────
    static var stroke: Color     { Color(nsColor: .separatorColor) }
    static var strokeSoft: Color { Color(nsColor: .separatorColor).opacity(0.4) }

    // ── Gradients ─────────────────────────────────────────────────────────────
    static var sidebarGradient: LinearGradient {
        LinearGradient(colors: [sidebarTop, sidebarBottom],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    static var backgroundGradient: LinearGradient {
        LinearGradient(colors: [backgroundTop, backgroundBottom],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    static func accentGlow(_ color: Color) -> RadialGradient {
        RadialGradient(colors: [color.opacity(0.25), .clear], center: .center, startRadius: 0, endRadius: 80)
    }
}

// MARK: - PBPanel — Card Container

struct PBPanel<Content: View>: View {
    var dark: Bool = false
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .background {
                if dark {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(PBTheme.sidebarTop.opacity(0.96))
                        .overlay {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                        }
                } else {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(PBTheme.surfaceStrong)
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(PBTheme.stroke, lineWidth: 0.5)
                        }
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                }
            }
    }
}

// MARK: - PBBadge — Pill Label

struct PBBadge: View {
    let text: String
    let tint: Color
    var dark: Bool = false

    init(_ text: String, tint: Color, dark: Bool = false) {
        self.text = text; self.tint = tint; self.dark = dark
    }

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .tracking(0.6)
            .foregroundStyle(dark ? tint.opacity(0.9) : tint)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background {
                Capsule(style: .continuous)
                    .fill(tint.opacity(dark ? 0.18 : 0.12))
            }
    }
}

// MARK: - Button Styles

struct PBPrimaryButtonStyle: ButtonStyle {
    var tint: Color = PBTheme.accentBlue

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(tint)
                    .opacity(configuration.isPressed ? 0.75 : 1.0)
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

struct PBSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(PBTheme.ink)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(PBTheme.surface)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(PBTheme.stroke, lineWidth: 1)
                    }
                    .opacity(configuration.isPressed ? 0.7 : 1.0)
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

struct PBDestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(PBTheme.accentRed)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(PBTheme.accentRed.opacity(0.08))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(PBTheme.accentRed.opacity(0.2), lineWidth: 1)
                    }
                    .opacity(configuration.isPressed ? 0.7 : 1.0)
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

// MARK: - Input Field Modifier

private struct PBInputModifier: ViewModifier {
    var dark: Bool = false

    func body(content: Content) -> some View {
        content
            .textFieldStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background {
                if dark {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                        }
                } else {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(PBTheme.surface)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(PBTheme.stroke, lineWidth: 1)
                        }
                }
            }
            .foregroundStyle(dark ? .white : PBTheme.ink)
    }
}

extension View {
    func pbInput(dark: Bool = false) -> some View {
        modifier(PBInputModifier(dark: dark))
    }
}

// MARK: - Card Modifier

private struct PBCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 16
    var highlighted: Bool = false

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(PBTheme.surfaceStrong)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(
                                highlighted ? PBTheme.accentBlue.opacity(0.4) : PBTheme.stroke,
                                lineWidth: highlighted ? 1.5 : 0.5
                            )
                    }
                    .shadow(color: .black.opacity(highlighted ? 0.08 : 0.04),
                            radius: highlighted ? 10 : 6, x: 0, y: 2)
            }
    }
}

extension View {
    func pbCard(cornerRadius: CGFloat = 16, highlighted: Bool = false) -> some View {
        modifier(PBCardModifier(cornerRadius: cornerRadius, highlighted: highlighted))
    }
}

// MARK: - Sidebar Nav Button

struct SidebarNavButton: View {
    let icon: String
    let label: String
    var badge: Int = 0
    var isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 11) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(isSelected ? Color.white.opacity(0.20) : Color.white.opacity(0.06))
                        .frame(width: 30, height: 30)
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                        .foregroundStyle(.white)
                        .symbolRenderingMode(.hierarchical)
                }

                Text(label)
                    .font(.system(size: 13.5, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.72))

                Spacer()

                if badge > 0 {
                    Text("\(badge)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.white.opacity(0.22)))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white.opacity(0.13))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                        }
                }
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSelected)
    }
}

// MARK: - Status Dot

struct StatusDot: View {
    var isOnline: Bool
    var size: CGFloat = 8

    var body: some View {
        Circle()
            .fill(isOnline ? PBTheme.accentGreen : PBTheme.accentOrange)
            .frame(width: size, height: size)
            .overlay {
                Circle()
                    .fill(isOnline ? PBTheme.accentGreen.opacity(0.4) : .clear)
                    .frame(width: size + 4, height: size + 4)
                    .scaleEffect(isOnline ? 1.0 : 0.0)
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.6).repeatForever(autoreverses: true),
                       value: isOnline)
    }
}

// MARK: - Device Avatar

struct DeviceAvatar: View {
    let name: String
    let platform: String?
    var size: CGFloat = 38
    var color: Color = PBTheme.accentBlue

    private var initials: String {
        let words = name.split(separator: " ")
        if words.count >= 2 {
            return String(words[0].prefix(1) + words[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    private var platformIcon: String {
        switch platform?.lowercased() {
        case "ios", "iphone": return "iphone"
        case "android":       return "phone"
        case "windows":       return "pc"
        case "linux":         return "terminal"
        default:              return "desktopcomputer"
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: size, height: size)
            Text(initials)
                .font(.system(size: size * 0.35, weight: .bold, design: .rounded))
                .foregroundStyle(color)
        }
    }
}

// MARK: - Section Header

struct CRSectionHeader: View {
    let eyebrow: String
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(eyebrow.uppercased())
                .font(.system(size: 11, weight: .bold))
                .tracking(0.8)
                .foregroundStyle(PBTheme.accentBlue)
            Text(title)
                .font(.system(size: 26, weight: .bold, design: .default))
                .foregroundStyle(PBTheme.ink)
            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(PBTheme.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Empty State

struct CREmptyState: View {
    let systemImage: String
    let title: String
    let message: String
    var accent: Color = PBTheme.accentBlue

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(accent.opacity(0.10))
                    .frame(width: 68, height: 68)
                Image(systemName: systemImage)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(accent)
                    .symbolRenderingMode(.hierarchical)
            }
            VStack(spacing: 5) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(PBTheme.ink)
                Text(message)
                    .font(.system(size: 13))
                    .foregroundStyle(PBTheme.inkSoft)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 320)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 48)
    }
}

// MARK: - Toast Stack

struct CRToastStack: View {
    let toasts: [ToastItem]

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            ForEach(toasts.suffix(3)) { toast in
                HStack(spacing: 10) {
                    Circle()
                        .fill(toast.tint)
                        .frame(width: 8, height: 8)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(toast.title)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(PBTheme.ink)
                        Text(toast.body)
                            .font(.system(size: 12))
                            .foregroundStyle(PBTheme.inkSoft)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.regularMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(PBTheme.stroke, lineWidth: 0.5)
                        }
                        .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: toasts.count)
    }
}
