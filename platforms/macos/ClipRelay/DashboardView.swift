import SwiftUI
import UniformTypeIdentifiers

<<<<<<< HEAD
=======
// MARK: - Root

>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
struct DashboardRootView: View {
    @ObservedObject var store: ClipRelayStore
    @State private var renameTarget: ManagedDevice?
    @State private var renameDraft = ""
<<<<<<< HEAD

    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(spacing: 0) {
                sidebar
                Divider()
                content
            }
            .background(
                LinearGradient(
                    colors: [PBTheme.backgroundTop, PBTheme.backgroundBottom],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

            ToastStackView(toasts: store.toasts)
                .padding(18)
        }
        .sheet(item: $renameTarget) { device in
            RenameDeviceSheet(
                device: device,
                draft: renameDraft,
                onCancel: { renameTarget = nil },
                onSave: { updatedName in
                    store.rename(device, to: updatedName)
                    renameTarget = nil
                }
=======
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            Sidebar(store: store)
                .navigationSplitViewColumnWidth(min: 200, ideal: 220, max: 260)
        } detail: {
            DetailContent(store: store, beginRename: beginRename(device:))
        }
        .background(PBTheme.backgroundGradient)
        .overlay(alignment: .topTrailing) {
            CRToastStack(toasts: store.toasts).padding(20)
        }
        .sheet(item: $renameTarget) { device in
            RenameDeviceSheet(
                device: device, draft: renameDraft,
                onCancel: { renameTarget = nil },
                onSave: { name in store.rename(device, to: name); renameTarget = nil }
>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
            )
        }
    }

<<<<<<< HEAD
    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text("ClipRelay")
                    .font(.system(size: 30, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                Text(store.connectionBanner)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.72))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                if let status = store.status {
                    Text("\(status.peerCount) device\(status.peerCount == 1 ? "" : "s") nearby")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.56))
                        .lineLimit(1)
                }
            }

            VStack(spacing: 10) {
                ForEach(DashboardSection.allCases) { section in
                    Button {
                        store.selectedSection = section
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: icon(for: section))
                                .frame(width: 18)
                            Text(section.title)
                            Spacer()
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(
                                    store.selectedSection == section
                                        ? Color.white.opacity(0.12)
                                        : Color.clear
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()

            VStack(alignment: .leading, spacing: 10) {
                PBBadge(store.settings?.syncEnabled == false ? "SYNC PAUSED" : "LOCAL-FIRST", tint: PBTheme.accentGreen, dark: true)
                Text("Clipboard history stays on your devices and moves over your local network.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.66))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(22)
        .frame(width: 220)
        .background(
            LinearGradient(
                colors: [PBTheme.sidebarTop, PBTheme.sidebarBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    @ViewBuilder
    private var content: some View {
        switch store.selectedSection {
        case .timeline:
            TimelineSectionView(store: store)
        case .devices:
            DevicesSectionView(
                store: store,
                devices: store.devices,
                rename: beginRename(device:)
            )
        case .trust:
            TrustSectionView(
                store: store,
                rename: beginRename(device:)
            )
        case .settings:
            PreferencesView(store: store)
        }
    }

    private func beginRename(device: ManagedDevice) {
        renameDraft = device.name
        renameTarget = device
    }

    private func icon(for section: DashboardSection) -> String {
        switch section {
        case .timeline: return "clock.arrow.circlepath"
        case .devices: return "desktopcomputer"
        case .trust: return "checkmark.shield"
        case .settings: return "slider.horizontal.3"
=======
    private func beginRename(device: ManagedDevice) {
        renameDraft = device.name; renameTarget = device
    }
}

// MARK: - Sidebar

private struct Sidebar: View {
    @ObservedObject var store: ClipRelayStore

    private var untrustedCount: Int { store.devices.filter { $0.trustState == .untrusted }.count }
    private var deviceCount: Int    { store.devices.count }

    var body: some View {
        ZStack {
            PBTheme.sidebarGradient.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                // ── Brand header ──────────────────────────────────────────────
                SidebarHeader(store: store)

                // ── Divider ───────────────────────────────────────────────────
                Rectangle()
                    .fill(Color.white.opacity(0.10))
                    .frame(height: 1)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                // ── Navigation ────────────────────────────────────────────────
                VStack(spacing: 4) {
                    SidebarNavButton(
                        icon: "clock.arrow.circlepath", label: "Timeline",
                        badge: 0,
                        isSelected: store.selectedSection == .timeline,
                        action: { store.selectedSection = .timeline }
                    )
                    SidebarNavButton(
                        icon: "desktopcomputer", label: "Devices",
                        badge: deviceCount,
                        isSelected: store.selectedSection == .devices,
                        action: { store.selectedSection = .devices }
                    )
                    SidebarNavButton(
                        icon: "checkmark.shield.fill", label: "Trust",
                        badge: untrustedCount,
                        isSelected: store.selectedSection == .trust,
                        action: { store.selectedSection = .trust }
                    )
                    SidebarNavButton(
                        icon: "slider.horizontal.3", label: "Settings",
                        badge: 0,
                        isSelected: store.selectedSection == .settings,
                        action: { store.selectedSection = .settings }
                    )
                }
                .padding(.horizontal, 12)

                Spacer()

                // ── Sync badge + legal copy ───────────────────────────────────
                VStack(alignment: .leading, spacing: 10) {
                    PBBadge(
                        store.settings?.syncEnabled == false ? "SYNC PAUSED" : "LOCAL-FIRST",
                        tint: store.settings?.syncEnabled == false ? PBTheme.accentOrange : PBTheme.accentGreen,
                        dark: true
                    )
                    Text("Clipboard history stays on your\ndevices over your local network.")
                        .font(.system(size: 11.5))
                        .foregroundStyle(.white.opacity(0.50))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(2)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
        }
    }
}

<<<<<<< HEAD
=======
private struct SidebarHeader: View {
    @ObservedObject var store: ClipRelayStore

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                // App icon placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(LinearGradient(colors: [PBTheme.accentBlue, PBTheme.accentIndigo],
                                            startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 34, height: 34)
                    Image(systemName: "clipboard.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text("ClipRelay")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    HStack(spacing: 5) {
                        StatusDot(isOnline: store.isRunning, size: 6)
                        Text(store.isRunning ? "Running" : "Offline")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.white.opacity(0.60))
                    }
                }
            }

            Text(store.connectionBanner)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.55))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 20)
        .padding(.top, 22)
        .padding(.bottom, 4)
    }
}

// MARK: - Detail Content

private struct DetailContent: View {
    @ObservedObject var store: ClipRelayStore
    let beginRename: (ManagedDevice) -> Void

    var body: some View {
        Group {
            switch store.selectedSection {
            case .timeline:
                TimelineSectionView(store: store)
            case .devices:
                DevicesSectionView(store: store, rename: beginRename)
            case .trust:
                TrustSectionView(store: store, rename: beginRename)
            case .settings:
                PreferencesView(store: store)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PBTheme.backgroundGradient)
    }
}

// MARK: - Timeline Section

>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
private struct TimelineSectionView: View {
    @ObservedObject var store: ClipRelayStore

    var body: some View {
<<<<<<< HEAD
        PBPanel {
            VStack(alignment: .leading, spacing: 18) {
                DashboardHeaderView(
                    eyebrow: "Timeline",
                    title: "Recent clipboard activity",
                    subtitle: "Copy items locally, resend them to another device, or keep important entries pinned."
                )

                if store.timeline.isEmpty {
                    EmptySectionView(
                        systemImage: "doc.text.magnifyingglass",
                        title: "Nothing here yet",
                        subtitle: "Copied text, images, and files will show up once the daemon starts receiving activity."
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(store.timeline.prefix(80)) { item in
                                TimelineCardView(item: item, store: store)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct DevicesSectionView: View {
    @ObservedObject var store: ClipRelayStore
    let devices: [ManagedDevice]
=======
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                CRSectionHeader(
                    eyebrow: store.selectedSection.eyebrow,
                    title: "Timeline",
                    subtitle: "All clipboard activity across your devices."
                )
                .padding(.top, 4)

                if store.timeline.isEmpty {
                    CREmptyState(
                        systemImage: "doc.text.magnifyingglass",
                        title: "Nothing here yet",
                        message: "Copied text, images, and files will appear once the daemon receives activity."
                    )
                } else {
                    LazyVStack(spacing: 10) {
                        ForEach(store.timeline) { item in
                            TimelineCard(item: item, store: store)
                        }
                    }
                }
            }
            .padding(24)
        }
    }
}

// MARK: - Devices Section

private struct DevicesSectionView: View {
    @ObservedObject var store: ClipRelayStore
>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
    let rename: (ManagedDevice) -> Void
    @State private var showingFileImporter = false
    @State private var pendingFileTarget: ManagedDevice?

    var body: some View {
<<<<<<< HEAD
        PBPanel {
            VStack(alignment: .leading, spacing: 18) {
                DashboardHeaderView(
                    eyebrow: "Devices",
                    title: "Manage nearby devices",
                    subtitle: "Connect manually, rename trusted devices, and control active sessions."
                )

                ManualConnectCard(store: store)
                FileShareCard(store: store) { target in
                    pendingFileTarget = target
                    showingFileImporter = true
                }

                if devices.isEmpty {
                    EmptySectionView(
                        systemImage: "wifi.slash",
                        title: "No devices discovered",
                        subtitle: "When another ClipRelay device appears on your network, it will show up here."
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(devices) { device in
                                DeviceManagementCard(device: device, store: store, rename: rename)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .fileImporter(
            isPresented: $showingFileImporter,
            allowedContentTypes: [.item],
            allowsMultipleSelection: false
        ) { result in
=======
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                CRSectionHeader(
                    eyebrow: store.selectedSection.eyebrow,
                    title: "Devices",
                    subtitle: "Discover, connect, and manage nearby peers."
                )
                .padding(.top, 4)

                // Manual connect card
                ManualConnectCard(store: store)

                // File share card
                FileShareCard(store: store) { target in
                    pendingFileTarget = target; showingFileImporter = true
                }

                if store.devices.isEmpty {
                    CREmptyState(
                        systemImage: "wifi.slash",
                        title: "No devices discovered",
                        message: "When another ClipRelay device appears on your network, it will show up here."
                    )
                } else {
                    VStack(spacing: 10) {
                        ForEach(store.devices) { device in
                            DeviceCard(device: device, store: store, rename: rename)
                        }
                    }
                }
            }
            .padding(24)
        }
        .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: [.item], allowsMultipleSelection: false) { result in
>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
            guard case let .success(urls) = result, let url = urls.first else { return }
            store.sendFile(url: url, to: pendingFileTarget)
            pendingFileTarget = nil
        }
    }
}

<<<<<<< HEAD
=======
// MARK: - Trust Section

>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
private struct TrustSectionView: View {
    @ObservedObject var store: ClipRelayStore
    let rename: (ManagedDevice) -> Void

    private var attentionDevices: [ManagedDevice] {
        store.devices.filter { $0.trustState != .trusted }
    }

    var body: some View {
<<<<<<< HEAD
        PBPanel {
            VStack(alignment: .leading, spacing: 18) {
                DashboardHeaderView(
                    eyebrow: "Trust",
                    title: "Review device trust",
                    subtitle: "Approve devices you control, reject unknown ones, and revisit trusted peers."
                )

                if store.devices.isEmpty {
                    EmptySectionView(
                        systemImage: "checkmark.shield",
                        title: "No trust prompts right now",
                        subtitle: "New devices will appear here when they request access."
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if !attentionDevices.isEmpty {
                                ForEach(attentionDevices) { device in
                                    DeviceManagementCard(device: device, store: store, rename: rename, emphasizeTrust: true)
                                }
                            }
                            if attentionDevices.isEmpty {
                                EmptySectionView(
                                    systemImage: "checkmark.shield",
                                    title: "All visible devices are trusted",
                                    subtitle: "You can still rename, revoke, or disconnect any device from the Devices tab."
                                )
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct TimelineCardView: View {
    let item: TimelineItem
    @ObservedObject var store: ClipRelayStore

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: item.iconName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(PBTheme.accentBlue)
                    .frame(width: 30, height: 30)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(PBTheme.accentBlue.opacity(0.10))
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(PBTheme.ink)
                        .lineLimit(2)
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 6) {
                            Text(item.typeLabel)
                            Text("•")
                            Text(item.sourceDevice)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Text("•")
                            Text(item.timestamp.relativeTimeString())
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(item.typeLabel) from \(item.sourceDevice)")
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Text(item.timestamp.relativeTimeString())
                        }
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(PBTheme.inkSoft)
                }

                Spacer()
                if item.pinned {
                    PBBadge("PINNED", tint: PBTheme.accentGold)
                }
            }

            ViewThatFits(in: .horizontal) {
                timelineActions
                VStack(alignment: .leading, spacing: 8) {
                    timelineActions
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(PBTheme.surfaceStrong)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(PBTheme.stroke, lineWidth: 1)
                )
        )
    }

    @ViewBuilder
    private var timelineActions: some View {
        HStack(spacing: 8) {
            if item.fullText != nil {
                Button("Copy to this Mac") { store.copyTimelineItem(item) }
                    .buttonStyle(PBPrimaryButtonStyle())
            }

            Menu("Send") {
                Button("Send to all devices") { store.sendTimelineItem(item, to: nil) }
                ForEach(store.connectedDevices) { device in
                    Button(device.name) { store.sendTimelineItem(item, to: device) }
                }
            }
            .menuStyle(.borderlessButton)

            Button(item.pinned ? "Unpin" : "Pin") {
                store.pinTimelineItem(item, pinned: !item.pinned)
            }
            .buttonStyle(PBSecondaryButtonStyle())

            Button("Delete") {
                store.deleteTimelineItem(item)
            }
            .buttonStyle(PBSecondaryButtonStyle())
=======
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                CRSectionHeader(
                    eyebrow: store.selectedSection.eyebrow,
                    title: "Trust",
                    subtitle: "Approve or reject devices requesting access."
                )
                .padding(.top, 4)

                if store.devices.isEmpty || attentionDevices.isEmpty {
                    CREmptyState(
                        systemImage: "checkmark.shield.fill",
                        title: "All clear",
                        message: "No trust prompts right now. New devices appear here when they request access.",
                        accent: PBTheme.accentGreen
                    )
                } else {
                    VStack(spacing: 10) {
                        ForEach(attentionDevices) { device in
                            DeviceCard(device: device, store: store, rename: rename, emphasizeTrust: true)
                        }
                    }
                }
            }
            .padding(24)
        }
    }
}

// MARK: - Timeline Card

struct TimelineCard: View {
    let item: TimelineItem
    @ObservedObject var store: ClipRelayStore
    @State private var isHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // ── Header row ────────────────────────────────────────────────────
            HStack(alignment: .top, spacing: 12) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(accentForKind.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: item.iconName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(accentForKind)
                        .symbolRenderingMode(.hierarchical)
                }

                // Text
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.title)
                        .font(.system(size: 13.5, weight: .semibold))
                        .foregroundStyle(PBTheme.ink)
                        .lineLimit(2)

                    HStack(spacing: 6) {
                        PBBadge(item.typeLabel, tint: accentForKind)
                        Text("·").foregroundStyle(PBTheme.inkSubtle)
                        Text(item.sourceDevice)
                            .lineLimit(1).truncationMode(.middle)
                        Text("·").foregroundStyle(PBTheme.inkSubtle)
                        Text(item.timestamp.relativeTimeString())
                    }
                    .font(.system(size: 11.5))
                    .foregroundStyle(PBTheme.inkSoft)
                }

                Spacer(minLength: 0)

                if item.pinned {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(PBTheme.accentGold)
                        .rotationEffect(.degrees(45))
                }
            }

            // ── Action row ────────────────────────────────────────────────────
            HStack(spacing: 8) {
                if item.fullText != nil {
                    Button("Copy") { store.copyTimelineItem(item) }
                        .buttonStyle(PBPrimaryButtonStyle())
                }

                Menu {
                    Button("Send to all devices") { store.sendTimelineItem(item, to: nil) }
                    Divider()
                    ForEach(store.connectedDevices) { device in
                        Button(device.name) { store.sendTimelineItem(item, to: device) }
                    }
                } label: {
                    Label("Send", systemImage: "paperplane.fill")
                        .font(.system(size: 13, weight: .medium))
                }
                .buttonStyle(PBSecondaryButtonStyle())
                .menuIndicator(.hidden)

                Button(item.pinned ? "Unpin" : "Pin") {
                    store.pinTimelineItem(item, pinned: !item.pinned)
                }
                .buttonStyle(PBSecondaryButtonStyle())

                Spacer()

                Button { store.deleteTimelineItem(item) } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 12, weight: .medium))
                }
                .buttonStyle(PBDestructiveButtonStyle())
            }
        }
        .padding(16)
        .pbCard(cornerRadius: 14, highlighted: isHovered)
        .onHover { isHovered = $0 }
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isHovered)
    }

    private var accentForKind: Color {
        switch item.iconName {
        case "doc.on.clipboard": return PBTheme.accentBlue
        case "photo":            return PBTheme.accentPurple
        case "doc.fill":         return PBTheme.accentIndigo
        case "wifi":             return PBTheme.accentGreen
        case "wifi.slash":       return PBTheme.inkSoft
        default:                 return PBTheme.accentBlue
>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
        }
    }
}

<<<<<<< HEAD
private struct DeviceManagementCard: View {
    let device: ManagedDevice
    @ObservedObject var store: ClipRelayStore
    let rename: (ManagedDevice) -> Void
    var emphasizeTrust = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill((emphasizeTrust ? PBTheme.accentOrange : PBTheme.accentBlue).opacity(0.12))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "desktopcomputer")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(emphasizeTrust ? PBTheme.accentOrange : PBTheme.accentBlue)
                    )

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(device.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(PBTheme.ink)
                            .lineLimit(1)
                            .truncationMode(.tail)
=======
// MARK: - Device Card

private struct DeviceCard: View {
    let device: ManagedDevice
    @ObservedObject var store: ClipRelayStore
    let rename: (ManagedDevice) -> Void
    var emphasizeTrust: Bool = false
    @State private var isHovered = false

    private var accent: Color { emphasizeTrust ? PBTheme.accentOrange : device.connectionState.color }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ── Header ────────────────────────────────────────────────────────
            HStack(alignment: .top, spacing: 12) {
                DeviceAvatar(name: device.name, platform: nil, size: 42, color: accent)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(device.name)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(PBTheme.ink)
                            .lineLimit(1)
>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
                        DevicePill(text: device.connectionState.label, tint: device.connectionState.color)
                        DevicePill(text: device.trustState.rawValue.capitalized, tint: device.trustState.color)
                    }

<<<<<<< HEAD
                    if device.rawName != device.name {
                        Text(device.rawName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(PBTheme.inkSoft)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }

                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 10) {
                            if let endpoint = device.endpoint {
                                Label(endpoint, systemImage: "network")
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                            if let lastSeen = device.lastSeen {
                                Label("Seen \(lastSeen.relativeTimeString())", systemImage: "clock")
                                    .lineLimit(1)
                            }
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            if let endpoint = device.endpoint {
                                Label(endpoint, systemImage: "network")
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                            if let lastSeen = device.lastSeen {
                                Label("Seen \(lastSeen.relativeTimeString())", systemImage: "clock")
                                    .lineLimit(1)
                            }
                        }
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(PBTheme.inkSoft)

                    if let fingerprint = device.fingerprint {
                        Text("Fingerprint: \(fingerprint)")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundStyle(PBTheme.inkSoft)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    if let error = device.lastError, !error.isEmpty {
                        Text(error)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(PBTheme.accentPurple)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            ViewThatFits(in: .horizontal) {
                deviceActions
                VStack(alignment: .leading, spacing: 8) {
                    deviceActions
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(PBTheme.surfaceStrong)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(PBTheme.stroke, lineWidth: 1)
                )
        )
    }

    @ViewBuilder
    private var deviceActions: some View {
        HStack(spacing: 8) {
            if device.isConnected {
                Button("Disconnect") { store.disconnect(device) }
                    .buttonStyle(PBPrimaryButtonStyle(tint: PBTheme.accentOrange))
            }
            if device.trustState != .trusted {
                Button("Trust") { store.trust(device) }
                    .buttonStyle(PBPrimaryButtonStyle(tint: PBTheme.accentGreen))
                Button("Reject") { store.reject(device) }
                    .buttonStyle(PBSecondaryButtonStyle())
            } else {
                Button("Rename") { rename(device) }
                    .buttonStyle(PBSecondaryButtonStyle())
                Button("Revoke Trust") { store.revoke(device) }
                    .buttonStyle(PBSecondaryButtonStyle())
            }
        }
    }
}

=======
                    HStack(spacing: 10) {
                        if let ep = device.endpoint {
                            Label(ep, systemImage: "network")
                                .lineLimit(1).truncationMode(.middle)
                        }
                        if let seen = device.lastSeen {
                            Label("Seen \(seen.relativeTimeString())", systemImage: "clock")
                        }
                    }
                    .font(.system(size: 11.5))
                    .foregroundStyle(PBTheme.inkSoft)

                    if let fp = device.fingerprint {
                        Text("Fingerprint: \(fp)")
                            .font(.system(size: 10.5, weight: .medium, design: .monospaced))
                            .foregroundStyle(PBTheme.inkSubtle)
                            .lineLimit(1).truncationMode(.middle)
                    }
                    if let err = device.lastError, !err.isEmpty {
                        Label(err, systemImage: "exclamationmark.triangle.fill")
                            .font(.system(size: 11.5))
                            .foregroundStyle(PBTheme.accentOrange)
                    }
                }
                Spacer(minLength: 0)
            }

            // ── Actions ───────────────────────────────────────────────────────
            HStack(spacing: 8) {
                if device.isConnected {
                    Button("Disconnect") { store.disconnect(device) }
                        .buttonStyle(PBPrimaryButtonStyle(tint: PBTheme.accentOrange))
                }
                if device.trustState != .trusted {
                    Button("Trust") { store.trust(device) }
                        .buttonStyle(PBPrimaryButtonStyle(tint: PBTheme.accentGreen))
                    Button("Reject") { store.reject(device) }
                        .buttonStyle(PBDestructiveButtonStyle())
                } else {
                    Button("Rename") { rename(device) }
                        .buttonStyle(PBSecondaryButtonStyle())
                    Button("Revoke Trust") { store.revoke(device) }
                        .buttonStyle(PBDestructiveButtonStyle())
                }
                Spacer()
            }
        }
        .padding(16)
        .pbCard(cornerRadius: 14, highlighted: isHovered)
        .onHover { isHovered = $0 }
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isHovered)
    }
}

// MARK: - Manual Connect Card

>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
private struct ManualConnectCard: View {
    @ObservedObject var store: ClipRelayStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
<<<<<<< HEAD
            Text("Manual connect")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(PBTheme.ink)

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 10) {
                    TextField("192.168.1.20:47823", text: $store.manualConnectAddress)
                        .pbInput()
                    Button("Connect") {
                        store.connectManual()
                    }
                    .buttonStyle(PBPrimaryButtonStyle())
                }
                VStack(alignment: .leading, spacing: 10) {
                    TextField("192.168.1.20:47823", text: $store.manualConnectAddress)
                        .pbInput()
                    Button("Connect") {
                        store.connectManual()
                    }
                    .buttonStyle(PBPrimaryButtonStyle())
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(PBTheme.surfaceStrong)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(PBTheme.stroke, lineWidth: 1)
                )
        )
    }
}

=======
            HStack(spacing: 8) {
                Image(systemName: "network")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(PBTheme.accentBlue)
                Text("Manual connect")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(PBTheme.ink)
            }
            HStack(spacing: 10) {
                TextField("192.168.1.20:47823", text: $store.manualConnectAddress)
                    .pbInput()
                Button("Connect") { store.connectManual() }
                    .buttonStyle(PBPrimaryButtonStyle())
            }
        }
        .padding(16)
        .pbCard()
    }
}

// MARK: - File Share Card

>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
private struct FileShareCard: View {
    @ObservedObject var store: ClipRelayStore
    let chooseTarget: (ManagedDevice?) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
<<<<<<< HEAD
            Text("Send a file")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(PBTheme.ink)

            Text("Pick any document, image, or archive and push it directly to nearby ClipRelay devices.")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(PBTheme.inkSoft)
                .fixedSize(horizontal: false, vertical: true)

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 10) {
                    Button("Send to all devices") {
                        chooseTarget(nil)
                    }
                    .buttonStyle(PBPrimaryButtonStyle())

                    if !store.connectedDevices.isEmpty {
                        Menu("Send to device") {
                            ForEach(store.connectedDevices) { device in
                                Button(device.name) { chooseTarget(device) }
                            }
                        }
                        .menuStyle(.borderlessButton)
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Button("Send to all devices") {
                        chooseTarget(nil)
                    }
                    .buttonStyle(PBPrimaryButtonStyle())

                    if !store.connectedDevices.isEmpty {
                        Menu("Send to device") {
                            ForEach(store.connectedDevices) { device in
                                Button(device.name) { chooseTarget(device) }
                            }
                        }
                        .menuStyle(.borderlessButton)
                    }
=======
            HStack(spacing: 8) {
                Image(systemName: "arrow.up.doc.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(PBTheme.accentIndigo)
                Text("Send a file")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(PBTheme.ink)
            }
            Text("Push any document, image, or archive to nearby ClipRelay devices.")
                .font(.system(size: 12.5))
                .foregroundStyle(PBTheme.inkSoft)

            HStack(spacing: 10) {
                Button("Send to all") { chooseTarget(nil) }
                    .buttonStyle(PBPrimaryButtonStyle(tint: PBTheme.accentIndigo))

                if !store.connectedDevices.isEmpty {
                    Menu("Send to device") {
                        ForEach(store.connectedDevices) { d in
                            Button(d.name) { chooseTarget(d) }
                        }
                    }
                    .buttonStyle(PBSecondaryButtonStyle())
>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
                }
            }
        }
        .padding(16)
<<<<<<< HEAD
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(PBTheme.surfaceStrong)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(PBTheme.stroke, lineWidth: 1)
                )
        )
    }
}

private struct DashboardHeaderView: View {
    let eyebrow: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(eyebrow.uppercased())
                .font(.system(size: 11, weight: .bold))
                .tracking(0.5)
                .foregroundStyle(PBTheme.accentBlue)
            Text(title)
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundStyle(PBTheme.ink)
            Text(subtitle)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(PBTheme.inkSoft)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct EmptySectionView: View {
    let systemImage: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 30, weight: .medium))
                .foregroundStyle(PBTheme.accentBlue)
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(PBTheme.ink)
            Text(subtitle)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(PBTheme.inkSoft)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 360)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 40)
    }
}

private struct DevicePill: View {
=======
        .pbCard()
    }
}

// MARK: - Device Pill

struct DevicePill: View {
>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
    let text: String
    let tint: Color

    var body: some View {
        Text(text)
<<<<<<< HEAD
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(tint)
            .lineLimit(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule(style: .continuous)
                    .fill(tint.opacity(0.12))
            )
    }
}

private struct ToastStackView: View {
    let toasts: [ToastItem]

    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            ForEach(toasts.suffix(3)) { toast in
                HStack(spacing: 10) {
                    Circle()
                        .fill(toast.tint)
                        .frame(width: 10, height: 10)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(toast.title)
                            .font(.system(size: 13, weight: .semibold))
                        Text(toast.body)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.96))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(PBTheme.stroke, lineWidth: 1)
                        )
                )
            }
        }
    }
}
=======
            .font(.system(size: 10.5, weight: .bold))
            .foregroundStyle(tint)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Capsule(style: .continuous).fill(tint.opacity(0.12)))
    }
}

// MARK: - Rename Sheet
>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)

private struct RenameDeviceSheet: View {
    let device: ManagedDevice
    @State var draft: String
    let onCancel: () -> Void
    let onSave: (String) -> Void

    var body: some View {
<<<<<<< HEAD
        VStack(alignment: .leading, spacing: 16) {
            Text("Rename Device")
                .font(.system(size: 20, weight: .bold))
            Text("Choose a friendly name for \(device.name).")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
=======
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Rename Device")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(PBTheme.ink)
                Text("Give \(device.rawName) a friendly name.")
                    .font(.system(size: 13))
                    .foregroundStyle(PBTheme.inkSoft)
            }
>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
            TextField("Device name", text: $draft)
                .pbInput()
            HStack {
                Spacer()
<<<<<<< HEAD
                Button("Cancel", action: onCancel)
                    .buttonStyle(PBSecondaryButtonStyle())
                Button("Save") { onSave(draft) }
                    .buttonStyle(PBPrimaryButtonStyle())
            }
        }
        .padding(22)
        .frame(width: 360)
=======
                Button("Cancel", action: onCancel).buttonStyle(PBSecondaryButtonStyle())
                Button("Save")  { onSave(draft) }.buttonStyle(PBPrimaryButtonStyle())
            }
        }
        .padding(24)
        .frame(width: 360)
        .background(PBTheme.surfaceStrong.ignoresSafeArea())
>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
    }
}
