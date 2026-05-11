<<<<<<< HEAD
=======
// ClipboardHistoryView.swift
// Spotlight-inspired quick access panel — floats above all windows.

>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
import SwiftUI

struct QuickAccessHistoryView: View {
    @ObservedObject var store: ClipRelayStore
    @State private var search = ""
<<<<<<< HEAD

    private var results: [TimelineItem] {
        if search.isEmpty { return store.timeline }
        return store.timeline.filter {
            $0.title.localizedCaseInsensitiveContains(search) ||
            $0.sourceDevice.localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        PBPanel {
            VStack(spacing: 16) {
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Quick Access")
                            .font(.system(size: 25, weight: .bold, design: .serif))
                            .foregroundStyle(PBTheme.ink)
                        Text("Search, copy, or resend your recent clipboard items.")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(PBTheme.inkSoft)
                    }

                    Spacer()

                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(PBTheme.inkSoft)
                        TextField("Search clipboard history", text: $search)
                            .textFieldStyle(.plain)
                    }
                    .pbInput()
                    .frame(width: 220)
                }

                ScrollView {
                    LazyVStack(spacing: 10) {
                        if let context = store.quickSendContext, !context.text.isEmpty {
                            QuickSendStripView(store: store, text: context.text)
                        }

                        if results.isEmpty {
                            VStack(spacing: 10) {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .font(.system(size: 30))
                                    .foregroundStyle(PBTheme.accentBlue)
                                Text(search.isEmpty ? "No items yet" : "Nothing matched")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(PBTheme.ink)
                                Text(search.isEmpty ? "Recent clipboard history will appear here." : "Try a shorter or different search phrase.")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(PBTheme.inkSoft)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 28)
                        } else {
                            ForEach(results.prefix(25)) { item in
                                QuickHistoryRow(item: item, store: store)
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
            .padding(18)
        }
        .frame(width: 460, height: 540)
    }
}

private struct QuickSendStripView: View {
    @ObservedObject var store: ClipRelayStore
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                PBBadge("JUST COPIED", tint: PBTheme.accentBlue)
                Spacer()
                Text("\(store.connectedDevices.count) target\(store.connectedDevices.count == 1 ? "" : "s")")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(PBTheme.inkSoft)
            }

            Text(text)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(PBTheme.ink)
                .lineLimit(3)
=======
    @FocusState private var searchFocused: Bool
    @State private var selectedIndex: Int = 0

    private var results: [TimelineItem] {
        let all = store.timeline
        if search.isEmpty { return Array(all.prefix(25)) }
        return all.filter {
            $0.title.localizedCaseInsensitiveContains(search) ||
            $0.sourceDevice.localizedCaseInsensitiveContains(search) ||
            $0.typeLabel.localizedCaseInsensitiveContains(search)
        }.prefix(25).map { $0 }
    }

    var body: some View {
        ZStack {
            // Glass background
            VisualEffectBackground(material: .sidebar, blendingMode: .behindWindow)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Search bar ────────────────────────────────────────────────
                SearchBar(text: $search, focused: $searchFocused)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                Divider().opacity(0.4)

                // ── Just-copied strip ─────────────────────────────────────────
                if let ctx = store.quickSendContext, !ctx.text.isEmpty, search.isEmpty {
                    QuickSendStrip(store: store, context: ctx)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 4)
                }

                // ── Results ───────────────────────────────────────────────────
                if results.isEmpty {
                    QuickEmptyState(hasSearch: !search.isEmpty)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 6) {
                            ForEach(Array(results.enumerated()), id: \.element.id) { idx, item in
                                QuickRow(
                                    item: item,
                                    store: store,
                                    isSelected: idx == selectedIndex
                                )
                                .onTapGesture { store.copyTimelineItem(item) }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                }
            }
        }
        .frame(width: 480, height: 560)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.30), radius: 40, x: 0, y: 12)
        .environment(\.colorScheme, .dark)
        .onAppear { searchFocused = true }
    }
}

// MARK: - Search Bar

private struct SearchBar: View {
    @Binding var text: String
    var focused: FocusState<Bool>.Binding

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white.opacity(0.50))
                .frame(width: 20)

            TextField("Search clipboard history…", text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
                .focused(focused)

            if !text.isEmpty {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.40))
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.09))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                }
        }
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: text.isEmpty)
    }
}

// MARK: - Just-Copied Strip

private struct QuickSendStrip: View {
    @ObservedObject var store: ClipRelayStore
    let context: QuickSendContext

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Circle()
                    .fill(PBTheme.accentBlue)
                    .frame(width: 7, height: 7)
                Text("JUST COPIED")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(PBTheme.accentBlue.opacity(0.85))
                Spacer()
                Text(context.timestamp.relativeTimeString())
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.35))
            }

            Text(context.text)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.90))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)

            HStack(spacing: 8) {
                Button("Send to all") { store.sendCurrentClipboard(to: nil) }
                    .buttonStyle(PBPrimaryButtonStyle())
<<<<<<< HEAD
=======

>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
                ForEach(store.connectedDevices.prefix(3)) { device in
                    Button(device.name) { store.sendCurrentClipboard(to: device) }
                        .buttonStyle(PBSecondaryButtonStyle())
                }
            }
        }
<<<<<<< HEAD
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [PBTheme.accentBlue.opacity(0.12), Color.white],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(PBTheme.accentBlue.opacity(0.18), lineWidth: 1)
                )
        )
    }
}

private struct QuickHistoryRow: View {
    let item: TimelineItem
    @ObservedObject var store: ClipRelayStore

    var body: some View {
        Button {
            store.copyTimelineItem(item)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(PBTheme.accentBlue.opacity(0.12))
                    .frame(width: 34, height: 34)
                    .overlay(
                        Image(systemName: item.iconName)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(PBTheme.accentBlue)
                    )

                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(PBTheme.ink)
                        .lineLimit(2)
                    HStack(spacing: 6) {
                        Text(item.sourceDevice)
                        Text("•")
                        Text(item.timestamp.relativeTimeString())
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(PBTheme.inkSoft)
                }

                Spacer()
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(PBTheme.surfaceStrong)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(PBTheme.stroke, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
=======
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(PBTheme.accentBlue.opacity(0.14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(PBTheme.accentBlue.opacity(0.28), lineWidth: 1)
                }
        }
    }
}

// MARK: - Quick Row

private struct QuickRow: View {
    let item: TimelineItem
    @ObservedObject var store: ClipRelayStore
    var isSelected: Bool
    @State private var isHovered = false

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 32, height: 32)
                Image(systemName: item.iconName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.70))
                    .symbolRenderingMode(.hierarchical)
            }

            // Text
            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.system(size: 13.5, weight: .medium))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)

                HStack(spacing: 5) {
                    Text(item.typeLabel)
                    Text("·").opacity(0.4)
                    Text(item.sourceDevice)
                        .lineLimit(1).truncationMode(.middle)
                    Text("·").opacity(0.4)
                    Text(item.timestamp.relativeTimeString())
                }
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.40))
            }

            Spacer(minLength: 0)

            // Hover actions
            if isHovered {
                HStack(spacing: 6) {
                    Button { store.copyTimelineItem(item) } label: {
                        Image(systemName: "doc.on.clipboard")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .buttonStyle(QuickActionButton())

                    if !store.connectedDevices.isEmpty {
                        Menu {
                            Button("Send to all") { store.sendTimelineItem(item, to: nil) }
                            Divider()
                            ForEach(store.connectedDevices) { d in
                                Button(d.name) { store.sendTimelineItem(item, to: d) }
                            }
                        } label: {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .buttonStyle(QuickActionButton())
                        .menuIndicator(.hidden)
                    }

                    Button { store.pinTimelineItem(item, pinned: !item.pinned) } label: {
                        Image(systemName: item.pinned ? "pin.slash" : "pin.fill")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .buttonStyle(QuickActionButton())
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else if item.pinned {
                Image(systemName: "pin.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(PBTheme.accentGold)
                    .rotationEffect(.degrees(45))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isHovered || isSelected
                      ? Color.white.opacity(0.08)
                      : Color.clear)
        }
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
        .animation(.spring(response: 0.20, dampingFraction: 0.8), value: isHovered)
>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
        .contextMenu {
            Button("Copy to this Mac") { store.copyTimelineItem(item) }
            Menu("Send to device") {
                Button("Send to all devices") { store.sendTimelineItem(item, to: nil) }
<<<<<<< HEAD
                ForEach(store.connectedDevices) { device in
                    Button(device.name) { store.sendTimelineItem(item, to: device) }
                }
            }
            Button(item.pinned ? "Unpin" : "Pin") {
                store.pinTimelineItem(item, pinned: !item.pinned)
            }
            Button("Delete", role: .destructive) {
                store.deleteTimelineItem(item)
            }
        }
    }
}
=======
                Divider()
                ForEach(store.connectedDevices) { d in
                    Button(d.name) { store.sendTimelineItem(item, to: d) }
                }
            }
            Divider()
            Button(item.pinned ? "Unpin" : "Pin") {
                store.pinTimelineItem(item, pinned: !item.pinned)
            }
            Button("Delete", role: .destructive) { store.deleteTimelineItem(item) }
        }
    }
}

// MARK: - Quick Action Button Style

private struct QuickActionButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white.opacity(configuration.isPressed ? 0.5 : 0.70))
            .frame(width: 28, height: 28)
            .background {
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(Color.white.opacity(configuration.isPressed ? 0.18 : 0.10))
            }
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.18, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

// MARK: - Empty State

private struct QuickEmptyState: View {
    let hasSearch: Bool

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: hasSearch ? "magnifyingglass" : "clock.arrow.circlepath")
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(.white.opacity(0.25))
            Text(hasSearch ? "Nothing matched" : "No history yet")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white.opacity(0.50))
            Text(hasSearch
                 ? "Try a shorter search phrase."
                 : "Copied items will appear here once the daemon is running.")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.30))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 48)
    }
}

// MARK: - NSVisualEffectView wrapper

private struct VisualEffectBackground: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let v = NSVisualEffectView()
        v.material     = material
        v.blendingMode = blendingMode
        v.state        = .active
        return v
    }

    func updateNSView(_ v: NSVisualEffectView, context: Context) {
        v.material     = material
        v.blendingMode = blendingMode
    }
}
>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
