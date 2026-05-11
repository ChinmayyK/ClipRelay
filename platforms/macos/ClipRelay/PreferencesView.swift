<<<<<<< HEAD
=======
// PreferencesView.swift
// Tabbed settings — native macOS grouped form style.

>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
import SwiftUI

struct PreferencesView: View {
    @ObservedObject var store: ClipRelayStore
<<<<<<< HEAD
    @State private var workingCopy = ClipRelaySettingsSnapshot(
        port: 47823,
        deviceName: "",
        syncEnabled: true,
        syncText: true,
        syncImages: true,
        syncFiles: true,
        syncMode: .auto,
        maxPayloadBytes: 64 * 1024 * 1024,
        historyLimit: 50,
        maxHistoryTextBytes: 64 * 1024,
        showReceiveNotification: true,
        requireTofuConfirmation: true,
        blockedDeviceIds: [],
        blockSensitiveText: true,
        ignorePatterns: [],
        clipboardPollMs: 100,
        maxPushesPerSec: 10,
        rateLimitBurst: 3,
        smartSyncDuplicateWindowMs: 1500,
        smartSyncDebounceMs: 150,
        startOnLogin: false
    )

    @State private var ignorePatternInput = ""

    var body: some View {
        Form {
            Section("General") {
                TextField("Device name", text: $workingCopy.deviceName)
                Toggle("Enable syncing", isOn: $workingCopy.syncEnabled)
                Picker("Sync mode", selection: $workingCopy.syncMode) {
                    ForEach(SyncModeModel.allCases) { mode in
                        Text(mode.rawValue.capitalized).tag(mode)
                    }
                }
                Toggle("Show receive notifications", isOn: $workingCopy.showReceiveNotification)
            }

            Section("History") {
                Stepper("History size: \(workingCopy.historyLimit)", value: $workingCopy.historyLimit, in: 20...100)
                Stepper(
                    "Retained text bytes: \(workingCopy.maxHistoryTextBytes)",
                    value: $workingCopy.maxHistoryTextBytes,
                    in: 1024...262144,
                    step: 1024
                )
            }

            Section("Filtering") {
                Toggle("Sync text", isOn: $workingCopy.syncText)
                Toggle("Sync images", isOn: $workingCopy.syncImages)
                Toggle("Sync files", isOn: $workingCopy.syncFiles)
                Toggle("Block likely secrets", isOn: $workingCopy.blockSensitiveText)
                Stepper(
                    "Max payload: \(Int(workingCopy.maxPayloadBytes / 1024 / 1024)) MB",
                    value: Binding(
                        get: { Int(workingCopy.maxPayloadBytes / 1024 / 1024) },
                        set: { workingCopy.maxPayloadBytes = UInt64($0) * 1024 * 1024 }
                    ),
                    in: 1...128
                )
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ignore patterns")
                    HStack {
                        TextField("Add substring to suppress syncing", text: $ignorePatternInput)
                        Button("Add") {
                            let trimmed = ignorePatternInput.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else { return }
                            workingCopy.ignorePatterns.append(trimmed)
                            ignorePatternInput = ""
                        }
                    }
                    ForEach(workingCopy.ignorePatterns, id: \.self) { pattern in
                        HStack {
                            Text(pattern)
                            Spacer()
                            Button(role: .destructive) {
                                workingCopy.ignorePatterns.removeAll { $0 == pattern }
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            Section("Network") {
                TextField("Port", value: $workingCopy.port, format: .number)
                Stepper(
                    "Clipboard poll: \(workingCopy.clipboardPollMs) ms",
                    value: Binding(
                        get: { Int(workingCopy.clipboardPollMs) },
                        set: { workingCopy.clipboardPollMs = UInt64($0) }
                    ),
                    in: 50...1000,
                    step: 25
                )
                Stepper(
                    "Duplicate window: \(workingCopy.smartSyncDuplicateWindowMs) ms",
                    value: Binding(
                        get: { Int(workingCopy.smartSyncDuplicateWindowMs) },
                        set: { workingCopy.smartSyncDuplicateWindowMs = UInt64($0) }
                    ),
                    in: 250...5000,
                    step: 50
                )
                Stepper(
                    "Debounce window: \(workingCopy.smartSyncDebounceMs) ms",
                    value: Binding(
                        get: { Int(workingCopy.smartSyncDebounceMs) },
                        set: { workingCopy.smartSyncDebounceMs = UInt64($0) }
                    ),
                    in: 50...1000,
                    step: 25
                )
            }

            Section {
                HStack {
                    Spacer()
                    Button("Reload") { if let settings = store.settings { workingCopy = settings } }
                    Button("Save Changes") { store.saveSettings(workingCopy) }
                        .buttonStyle(.borderedProminent)
                }
            }
        }
        .formStyle(.grouped)
        .padding(20)
        .frame(minWidth: 520, minHeight: 640)
        .onAppear {
            if let settings = store.settings {
                workingCopy = settings
=======
    @State private var tab: SettingsTab = .general
    @State private var workingCopy = ClipRelaySettingsSnapshot(
        port: 47823, deviceName: "", syncEnabled: true,
        syncText: true, syncImages: true, syncFiles: true,
        syncMode: .auto, maxPayloadBytes: 64 * 1024 * 1024,
        historyLimit: 50, maxHistoryTextBytes: 64 * 1024,
        showReceiveNotification: true, requireTofuConfirmation: true,
        blockedDeviceIds: [], blockSensitiveText: true,
        ignorePatterns: [], clipboardPollMs: 100,
        maxPushesPerSec: 10, rateLimitBurst: 3,
        smartSyncDuplicateWindowMs: 1500, smartSyncDebounceMs: 150,
        startOnLogin: false
    )
    @State private var ignorePatternDraft = ""
    @State private var isDirty = false

    var body: some View {
        VStack(spacing: 0) {
            // ── Tab bar ───────────────────────────────────────────────────────
            HStack(spacing: 0) {
                ForEach(SettingsTab.allCases) { t in
                    SettingsTabButton(tab: t, selected: tab == t) { tab = t }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 6)

            Divider()

            // ── Content ───────────────────────────────────────────────────────
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    switch tab {
                    case .general:  GeneralTab(copy: $workingCopy)
                    case .sync:     SyncTab(copy: $workingCopy, ignorePatternDraft: $ignorePatternDraft)
                    case .network:  NetworkTab(copy: $workingCopy)
                    case .security: SecurityTab(copy: $workingCopy)
                    }
                }
                .padding(24)
                .onChange(of: workingCopy.deviceName)    { _ in isDirty = true }
                .onChange(of: workingCopy.syncEnabled)   { _ in isDirty = true }
                .onChange(of: workingCopy.port)          { _ in isDirty = true }
                .onChange(of: workingCopy.historyLimit)  { _ in isDirty = true }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // ── Footer ────────────────────────────────────────────────────────
            Divider()
            HStack {
                if isDirty {
                    Label("Unsaved changes", systemImage: "pencil.circle")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(PBTheme.accentGold)
                }
                Spacer()
                Button("Revert") {
                    if let s = store.settings { workingCopy = s }
                    isDirty = false
                }
                .buttonStyle(PBSecondaryButtonStyle())
                .disabled(!isDirty)

                Button("Save Changes") {
                    store.saveSettings(workingCopy)
                    isDirty = false
                }
                .buttonStyle(PBPrimaryButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
        }
        .frame(minWidth: 560, minHeight: 560)
        .background(PBTheme.surfaceElevated.ignoresSafeArea())
        .onAppear { if let s = store.settings { workingCopy = s } }
    }
}

// MARK: - Tab Bar

private enum SettingsTab: String, CaseIterable, Identifiable {
    case general, sync, network, security
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
    var icon: String {
        switch self {
        case .general:  return "person.crop.circle"
        case .sync:     return "arrow.triangle.2.circlepath"
        case .network:  return "network"
        case .security: return "lock.shield"
        }
    }
}

private struct SettingsTabButton: View {
    let tab: SettingsTab
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: tab.icon)
                    .font(.system(size: 18, weight: selected ? .semibold : .regular))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(selected ? PBTheme.accentBlue : PBTheme.inkSoft)
                Text(tab.label)
                    .font(.system(size: 11, weight: selected ? .semibold : .regular))
                    .foregroundStyle(selected ? PBTheme.accentBlue : PBTheme.inkSoft)
            }
            .frame(width: 72, height: 52)
            .background {
                if selected {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(PBTheme.accentBlue.opacity(0.08))
                }
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.22, dampingFraction: 0.8), value: selected)
    }
}

// MARK: - General Tab

private struct GeneralTab: View {
    @Binding var copy: ClipRelaySettingsSnapshot

    var body: some View {
        SettingsSection(title: "Identity") {
            SettingsRow(label: "Device name", description: "How this Mac appears to other ClipRelay peers.") {
                TextField("MacBook Pro", text: $copy.deviceName)
                    .pbInput()
                    .frame(maxWidth: 260)
            }
            SettingsRow(label: "Start on login", description: "Launch ClipRelay automatically when you log in.") {
                Toggle("", isOn: $copy.startOnLogin).labelsHidden()
            }
        }

        SettingsSection(title: "Notifications") {
            SettingsRow(label: "Show receive notification", description: "Banner when a device sends clipboard content to this Mac.") {
                Toggle("", isOn: $copy.showReceiveNotification).labelsHidden()
            }
        }

        SettingsSection(title: "History") {
            SettingsRow(label: "History limit", description: "Maximum number of items kept in the local timeline.") {
                Stepper("\(copy.historyLimit) items", value: $copy.historyLimit, in: 10...500, step: 10)
                    .frame(maxWidth: 180)
            }
            SettingsRow(label: "Max text size", description: "Largest text payload stored per entry.") {
                Stepper("\(copy.maxHistoryTextBytes / 1024) KB",
                        value: Binding(get: { copy.maxHistoryTextBytes / 1024 },
                                       set: { copy.maxHistoryTextBytes = $0 * 1024 }),
                        in: 4...256, step: 4)
                .frame(maxWidth: 180)
>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
            }
        }
    }
}
<<<<<<< HEAD
=======

// MARK: - Sync Tab

private struct SyncTab: View {
    @Binding var copy: ClipRelaySettingsSnapshot
    @Binding var ignorePatternDraft: String

    var body: some View {
        SettingsSection(title: "Sync") {
            SettingsRow(label: "Enable sync", description: "Pause all cross-device clipboard sync at once.") {
                Toggle("", isOn: $copy.syncEnabled).labelsHidden()
            }
            SettingsRow(label: "Sync mode", description: "Auto: sync immediately. Manual: only on request.") {
                Picker("", selection: $copy.syncMode) {
                    ForEach(SyncModeModel.allCases) { mode in
                        Text(mode.rawValue.capitalized).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 220)
                .labelsHidden()
            }
        }

        SettingsSection(title: "Content types") {
            SettingsRow(label: "Text") {
                Toggle("", isOn: $copy.syncText).labelsHidden()
            }
            SettingsRow(label: "Images") {
                Toggle("", isOn: $copy.syncImages).labelsHidden()
            }
            SettingsRow(label: "Files") {
                Toggle("", isOn: $copy.syncFiles).labelsHidden()
            }
            SettingsRow(label: "Max payload", description: "Largest single item that will be synced.") {
                Stepper("\(Int(copy.maxPayloadBytes / 1024 / 1024)) MB",
                        value: Binding(get: { Int(copy.maxPayloadBytes / 1024 / 1024) },
                                       set: { copy.maxPayloadBytes = UInt64($0) * 1024 * 1024 }),
                        in: 1...256)
                .frame(maxWidth: 180)
            }
        }

        SettingsSection(title: "Ignore patterns") {
            Text("Substrings that suppress syncing. Useful for passwords, OTPs, or sensitive data.")
                .font(.system(size: 12))
                .foregroundStyle(PBTheme.inkSoft)
                .padding(.bottom, 8)

            HStack(spacing: 10) {
                TextField("Add pattern…", text: $ignorePatternDraft)
                    .pbInput()
                Button("Add") {
                    let t = ignorePatternDraft.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !t.isEmpty else { return }
                    copy.ignorePatterns.append(t)
                    ignorePatternDraft = ""
                }
                .buttonStyle(PBPrimaryButtonStyle())
                .disabled(ignorePatternDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            if !copy.ignorePatterns.isEmpty {
                VStack(spacing: 6) {
                    ForEach(copy.ignorePatterns, id: \.self) { pattern in
                        HStack {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(PBTheme.accentRed.opacity(0.75))
                                .onTapGesture { copy.ignorePatterns.removeAll { $0 == pattern } }
                            Text(pattern)
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundStyle(PBTheme.ink)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(RoundedRectangle(cornerRadius: 8).fill(PBTheme.surface))
                    }
                }
                .padding(.top, 6)
            }
        }
    }
}

// MARK: - Network Tab

private struct NetworkTab: View {
    @Binding var copy: ClipRelaySettingsSnapshot

    var body: some View {
        SettingsSection(title: "Listener") {
            SettingsRow(label: "Port", description: "TCP port the daemon listens on for peer connections.") {
                TextField("47823", value: $copy.port, format: .number)
                    .pbInput()
                    .frame(width: 100)
            }
        }

        SettingsSection(title: "Clipboard polling") {
            SettingsRow(label: "Poll interval", description: "How often ClipRelay checks for new clipboard content.") {
                Stepper("\(copy.clipboardPollMs) ms",
                        value: Binding(get: { Int(copy.clipboardPollMs) },
                                       set: { copy.clipboardPollMs = UInt64($0) }),
                        in: 50...2000, step: 25)
                .frame(maxWidth: 180)
            }
        }

        SettingsSection(title: "Smart sync") {
            SettingsRow(label: "Duplicate window", description: "Window for detecting identical content already synced.") {
                Stepper("\(copy.smartSyncDuplicateWindowMs) ms",
                        value: Binding(get: { Int(copy.smartSyncDuplicateWindowMs) },
                                       set: { copy.smartSyncDuplicateWindowMs = UInt64($0) }),
                        in: 100...10000, step: 100)
                .frame(maxWidth: 200)
            }
            SettingsRow(label: "Debounce window", description: "Delay after a copy before broadcasting to avoid partial pastes.") {
                Stepper("\(copy.smartSyncDebounceMs) ms",
                        value: Binding(get: { Int(copy.smartSyncDebounceMs) },
                                       set: { copy.smartSyncDebounceMs = UInt64($0) }),
                        in: 25...2000, step: 25)
                .frame(maxWidth: 200)
            }
        }

        SettingsSection(title: "Rate limiting") {
            SettingsRow(label: "Max pushes/sec") {
                Stepper("\(copy.maxPushesPerSec)", value: $copy.maxPushesPerSec, in: 1...60)
                    .frame(maxWidth: 160)
            }
            SettingsRow(label: "Burst allowance") {
                Stepper("\(copy.rateLimitBurst)", value: $copy.rateLimitBurst, in: 1...20)
                    .frame(maxWidth: 160)
            }
        }
    }
}

// MARK: - Security Tab

private struct SecurityTab: View {
    @Binding var copy: ClipRelaySettingsSnapshot

    var body: some View {
        SettingsSection(title: "Trust") {
            SettingsRow(label: "Require confirmation", description: "Show a trust prompt for every new device before allowing sync.") {
                Toggle("", isOn: $copy.requireTofuConfirmation).labelsHidden()
            }
        }

        SettingsSection(title: "Content filtering") {
            SettingsRow(label: "Block likely secrets", description: "Suppress sync for clipboard content that looks like passwords, API keys, or tokens.") {
                Toggle("", isOn: $copy.blockSensitiveText).labelsHidden()
            }
        }

        SettingsSection(title: "About security") {
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(icon: "lock.fill",          tint: PBTheme.accentBlue,  text: "All sync traffic is encrypted end-to-end using Noise protocol.")
                InfoRow(icon: "person.2.slash",     tint: PBTheme.accentGreen, text: "No relay servers. Peers connect directly over your local network.")
                InfoRow(icon: "checkmark.shield",   tint: PBTheme.accentIndigo, text: "TOFU trust model — each device is verified on first connection.")
            }
        }
    }
}

// MARK: - Settings Section & Row helpers

private struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(title.uppercased())
                .font(.system(size: 10.5, weight: .bold))
                .tracking(0.6)
                .foregroundStyle(PBTheme.inkSubtle)
                .padding(.horizontal, 16)
                .padding(.bottom, 6)

            VStack(spacing: 0) {
                content()
            }
            .background(PBTheme.surfaceStrong)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(PBTheme.stroke, lineWidth: 0.5)
            }
        }
        .padding(.bottom, 24)
    }
}

private struct SettingsRow<Control: View>: View {
    let label: String
    var description: String? = nil
    @ViewBuilder var control: () -> Control

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(PBTheme.ink)
                if let desc = description {
                    Text(desc)
                        .font(.system(size: 11.5))
                        .foregroundStyle(PBTheme.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer()
            control()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
        .overlay(alignment: .bottom) {
            Divider().padding(.leading, 16)
        }
    }
}

private struct InfoRow: View {
    let icon: String
    let tint: Color
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 18)
            Text(text)
                .font(.system(size: 12.5))
                .foregroundStyle(PBTheme.inkSoft)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
