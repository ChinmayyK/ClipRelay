// ActivityFeedView.swift
<<<<<<< HEAD
// ClipRelay — macOS Timeline-First Clipboard & Activity Feed
//
// Shows all cross-device events in reverse-chronological order.
// Remote clipboard items display an "Apply" button instead of auto-overwriting.
// File transfers show progress bars and Accept/Reject actions.

import SwiftUI

struct ActivityFeedView: View {
    @EnvironmentObject var store: ClipRelayStore
    @State private var searchText = ""

    private var filteredEntries: [IpcActivityEntry] {
        if searchText.isEmpty { return store.activityFeed }
        return store.activityFeed.filter {
            $0.summary.localizedCaseInsensitiveContains(searchText) ||
            $0.device_name.localizedCaseInsensitiveContains(searchText) ||
            ($0.text_preview?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
=======
// ClipRelay — macOS Activity Feed & Clipboard Policy panel

import SwiftUI

// MARK: - Activity Feed

struct ActivityFeedView: View {
    @EnvironmentObject var store: ClipRelayStore
    @State private var searchText = ""
    @State private var filterKind: KindFilter = .all

    private var filteredEntries: [IpcActivityEntry] {
        var entries = store.activityFeed
        if filterKind != .all {
            entries = entries.filter { filterKind.matches($0.kind) }
        }
        if !searchText.isEmpty {
            entries = entries.filter {
                $0.summary.localizedCaseInsensitiveContains(searchText) ||
                $0.device_name.localizedCaseInsensitiveContains(searchText) ||
                ($0.text_preview?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        return entries
>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
    }

    var body: some View {
        VStack(spacing: 0) {
<<<<<<< HEAD
            // ── Search bar ────────────────────────────────────────────────────
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.caption)
                TextField("Filter activity…", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.callout)
                if !searchText.isEmpty {
                    Button { searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // ── Pending clipboard items banner ────────────────────────────────
=======
            // ── Toolbar ───────────────────────────────────────────────────────
            FeedToolbar(searchText: $searchText, filterKind: $filterKind)

            Divider()

            // ── Pending clipboard banner ──────────────────────────────────────
>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
            let pending = store.activityFeed.filter { $0.isApplicable }
            if !pending.isEmpty && searchText.isEmpty {
                PendingClipboardBanner(items: pending)
                Divider()
            }

<<<<<<< HEAD
            // ── Active file transfers ─────────────────────────────────────────
=======
            // ── Active transfers ──────────────────────────────────────────────
>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
            if !store.activeTransfers.isEmpty && searchText.isEmpty {
                ForEach(store.activeTransfers) { transfer in
                    FileTransferRowView(transfer: transfer)
                    Divider()
                }
            }

<<<<<<< HEAD
            // ── Feed entries ──────────────────────────────────────────────────
            if filteredEntries.isEmpty {
                emptyState
=======
            // ── Feed ──────────────────────────────────────────────────────────
            if filteredEntries.isEmpty {
                EmptyFeedState(hasSearch: !searchText.isEmpty || filterKind != .all)
>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredEntries) { entry in
                            ActivityEntryRowView(entry: entry)
<<<<<<< HEAD
                            Divider().padding(.leading, 40)
=======
                            Divider().padding(.leading, 56)
>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
                        }
                    }
                }
            }
        }
<<<<<<< HEAD
        .frame(minWidth: 340, minHeight: 400)
        .task { await store.refreshActivityFeed() }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("No activity yet")
                .font(.subheadline)
            Text("Clipboard copies and file transfers across devices will appear here.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
=======
        .frame(minWidth: 360, minHeight: 440)
        .task { await store.refreshActivityFeed() }
    }
}

// MARK: - Feed Toolbar

private struct FeedToolbar: View {
    @Binding var searchText: String
    @Binding var filterKind: KindFilter

    var body: some View {
        HStack(spacing: 8) {
            // Search
            HStack(spacing: 7) {
                Image(systemName: "magnifyingglass")
                    .font(.caption)
                    .foregroundStyle(PBTheme.inkSoft)
                TextField("Filter activity…", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.callout)
                if !searchText.isEmpty {
                    Button { searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(PBTheme.inkSoft)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(PBTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(PBTheme.stroke, lineWidth: 0.5)
            }

            // Kind filter pills
            HStack(spacing: 4) {
                ForEach(KindFilter.allCases) { kind in
                    Button(kind.label) { filterKind = kind }
                        .font(.system(size: 11.5, weight: filterKind == kind ? .semibold : .regular))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background {
                            if filterKind == kind {
                                Capsule().fill(PBTheme.accentBlue.opacity(0.12))
                            }
                        }
                        .foregroundStyle(filterKind == kind ? PBTheme.accentBlue : PBTheme.inkSoft)
                        .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(PBTheme.surfaceElevated)
    }
}

private enum KindFilter: String, CaseIterable, Identifiable {
    case all, clipboard, files, peers
    var id: String { rawValue }
    var label: String {
        switch self {
        case .all:       return "All"
        case .clipboard: return "Clipboard"
        case .files:     return "Files"
        case .peers:     return "Peers"
        }
    }
    func matches(_ kind: String) -> Bool {
        switch self {
        case .all: return true
        case .clipboard: return kind.contains("clipboard")
        case .files:     return kind.contains("file") || kind.contains("transfer")
        case .peers:     return kind.contains("peer") || kind.contains("sync")
        }
    }
}

// MARK: - Empty State

private struct EmptyFeedState: View {
    let hasSearch: Bool
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: hasSearch ? "magnifyingglass" : "clock.arrow.circlepath")
                .font(.largeTitle)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(PBTheme.accentBlue)
            Text(hasSearch ? "Nothing matched" : "No activity yet")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(PBTheme.ink)
            Text(hasSearch
                 ? "Try adjusting your filter or search term."
                 : "Clipboard copies and file transfers across devices will appear here.")
                .font(.caption)
                .foregroundStyle(PBTheme.inkSoft)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 260)
>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

<<<<<<< HEAD
// ── Pending clipboard items banner ─────────────────────────────────────────────
=======
// MARK: - Pending Clipboard Banner
>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)

private struct PendingClipboardBanner: View {
    let items: [IpcActivityEntry]
    @EnvironmentObject var store: ClipRelayStore

    var body: some View {
<<<<<<< HEAD
        VStack(alignment: .leading, spacing: 4) {
            Label("\(items.count) clipboard item\(items.count == 1 ? "" : "s") waiting",
                  systemImage: "doc.on.clipboard")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.accentColor)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(items) { item in
                        PendingClipboardChip(entry: item)
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.accentColor.opacity(0.06))
    }
}

private struct PendingClipboardChip: View {
    let entry: IpcActivityEntry
    @EnvironmentObject var store: ClipRelayStore
    @State private var applying = false

    var body: some View {
        HStack(spacing: 6) {
            VStack(alignment: .leading, spacing: 1) {
                Text(entry.device_name)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(entry.text_preview ?? "Clipboard item")
                    .font(.caption)
                    .lineLimit(1)
            }
            Button {
                applying = true
                Task {
                    await store.applyClipboard(entry: entry)
                    applying = false
                }
            } label: {
                if applying {
                    ProgressView().controlSize(.mini)
                } else {
                    Text("Apply")
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.mini)
            .disabled(applying)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(6)
        .overlay(RoundedRectangle(cornerRadius: 6)
            .stroke(Color.accentColor.opacity(0.3), lineWidth: 1))
    }
}

// ── File transfer progress row ─────────────────────────────────────────────────
=======
        HStack(spacing: 12) {
            Image(systemName: "doc.on.clipboard.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(PBTheme.accentBlue)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(items.count) pending clipboard item\(items.count == 1 ? "" : "s")")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(PBTheme.ink)
                if let first = items.first {
                    Text("Latest from \(first.device_name)")
                        .font(.system(size: 11.5))
                        .foregroundStyle(PBTheme.inkSoft)
                }
            }
            Spacer()
            Button("Apply latest") {
                if let first = items.first { Task { await store.applyClipboard(entry: first) } }
            }
            .buttonStyle(PBPrimaryButtonStyle())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(PBTheme.accentBlue.opacity(0.06))
    }
}

// MARK: - Activity Entry Row

struct ActivityEntryRowView: View {
    let entry: IpcActivityEntry
    @EnvironmentObject var store: ClipRelayStore
    @State private var expanded = false
    @State private var applying = false
    @State private var isHovered = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // ── Device avatar ─────────────────────────────────────────────────
            ZStack {
                Circle()
                    .fill(kindColor.opacity(0.12))
                    .frame(width: 32, height: 32)
                Image(systemName: kindIcon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(kindColor)
                    .symbolRenderingMode(.hierarchical)
            }

            // ── Content ───────────────────────────────────────────────────────
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(entry.device_name)
                        .font(.system(size: 12.5, weight: .semibold))
                        .foregroundStyle(PBTheme.ink)
                    Text("·").foregroundStyle(PBTheme.inkSubtle)
                    Text(formattedTime(entry.timestamp_ms))
                        .font(.system(size: 11.5))
                        .foregroundStyle(PBTheme.inkSoft)
                }

                Text(entry.summary)
                    .font(.system(size: 12.5))
                    .foregroundStyle(PBTheme.ink)
                    .lineLimit(expanded ? nil : 2)

                if !entry.relay_path.isEmpty {
                    Label(entry.relay_path.joined(separator: " → "), systemImage: "arrow.triangle.branch")
                        .font(.system(size: 10.5))
                        .foregroundStyle(PBTheme.inkSubtle)
                }

                if let preview = entry.text_preview, !preview.isEmpty, expanded {
                    Text(preview)
                        .font(.system(size: 11.5, design: .monospaced))
                        .foregroundStyle(PBTheme.ink)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background {
                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                .fill(PBTheme.surface)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                                        .strokeBorder(PBTheme.stroke, lineWidth: 0.5)
                                }
                        }
                        .onTapGesture { expanded = false }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: expanded)

            Spacer()

            // ── Apply / status ─────────────────────────────────────────────────
            if entry.isApplicable {
                Button {
                    applying = true
                    Task { await store.applyClipboard(entry: entry); applying = false }
                } label: {
                    if applying {
                        ProgressView().controlSize(.mini)
                    } else {
                        Label("Apply", systemImage: "doc.on.clipboard.fill")
                            .font(.system(size: 11.5, weight: .semibold))
                    }
                }
                .buttonStyle(PBPrimaryButtonStyle())
                .controlSize(.small)
                .disabled(applying)
            } else if entry.applied_locally {
                Label("Applied", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(PBTheme.accentGreen)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(isHovered ? PBTheme.surface.opacity(0.5) : .clear)
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
        .onTapGesture { if entry.text_preview != nil { expanded.toggle() } }
    }

    private var kindIcon: String {
        switch entry.kind {
        case "remote_clipboard_available", "clipboard_text": return "doc.on.clipboard"
        case "clipboard_image":          return "photo"
        case "file_transfer_started":    return "arrow.down.circle"
        case "file_transfer_complete":   return "checkmark.circle.fill"
        case "file_transfer_failed":     return "xmark.circle"
        case "peer_connected":           return "wifi"
        case "peer_disconnected":        return "wifi.slash"
        case "sync_paused":              return "pause.circle"
        case "sync_resumed":             return "play.circle"
        case "clipboard_applied":        return "checkmark.circle"
        default:                         return "info.circle"
        }
    }

    private var kindColor: Color {
        switch entry.kind {
        case "remote_clipboard_available":  return entry.applied_locally ? PBTheme.accentGreen : PBTheme.accentBlue
        case "file_transfer_complete":      return PBTheme.accentGreen
        case "file_transfer_failed":        return PBTheme.accentRed
        case "peer_connected":              return PBTheme.accentGreen
        case "peer_disconnected":           return PBTheme.inkSoft
        case "sync_paused":                 return PBTheme.accentOrange
        default:                            return PBTheme.inkSoft
        }
    }

    private func formattedTime(_ ms: Int64) -> String {
        Date(timeIntervalSince1970: Double(ms) / 1000.0).relativeTimeString()
    }
}

// MARK: - File Transfer Row
>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)

struct FileTransferRowView: View {
    let transfer: FileTransferState
    @EnvironmentObject var store: ClipRelayStore

    var body: some View {
<<<<<<< HEAD
        HStack(spacing: 10) {
            // Icon
            Image(systemName: transferIcon)
                .foregroundColor(transferColor)
                .font(.title3)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(transfer.fileName)
                        .font(.callout)
                        .lineLimit(1)
                    Spacer()
                    Text(transfer.formattedSize)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("From \(transfer.fromDeviceName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    statusText
                }
                if case .transferring = transfer.status {
                    ProgressView(value: Double(transfer.percent), total: 100)
                        .progressViewStyle(.linear)
                        .tint(.accentColor)
=======
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(PBTheme.accentIndigo.opacity(0.12))
                    .frame(width: 32, height: 32)
                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(PBTheme.accentIndigo)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(transfer.fileName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(PBTheme.ink)
                        .lineLimit(1)
                    Spacer()
                    Text(transfer.formattedSize)
                        .font(.system(size: 11.5))
                        .foregroundStyle(PBTheme.inkSoft)
                }

                HStack(spacing: 8) {
                    Text("From \(transfer.fromDeviceName)")
                        .font(.system(size: 11.5))
                        .foregroundStyle(PBTheme.inkSoft)

                    if case .transferring = transfer.status {
                        ProgressView(value: Double(transfer.percent), total: 100)
                            .progressViewStyle(.linear)
                            .frame(maxWidth: 120)
                        Text("\(transfer.percent)%")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(PBTheme.inkSoft)
                    }
                }

                if case .failed(let reason) = transfer.status {
                    Label(reason, systemImage: "exclamationmark.triangle.fill")
                        .font(.system(size: 11.5))
                        .foregroundStyle(PBTheme.accentOrange)
                } else if case .complete(let path) = transfer.status {
                    Label("Saved to \(path)", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 11.5))
                        .foregroundStyle(PBTheme.accentGreen)
>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
                }
            }

            // Actions
<<<<<<< HEAD
            actionButtons
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
    }

    @ViewBuilder
    private var actionButtons: some View {
        switch transfer.status {
        case .incoming:
            HStack(spacing: 6) {
                Button("Accept") { store.acceptFileTransfer(transfer) }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                Button("Reject") { store.rejectFileTransfer(transfer) }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            }
        case .transferring:
            Button("Cancel") { store.cancelFileTransfer(transfer) }
                .buttonStyle(.bordered)
                .controlSize(.small)
        case .complete(let path):
            Button {
                NSWorkspace.shared.selectFile(path, inFileViewerRootedAtPath: "")
            } label: {
                Label("Show in Finder", systemImage: "folder")
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        default:
            EmptyView()
        }
    }

    private var statusText: some View {
        Group {
            switch transfer.status {
            case .incoming:      Text("Incoming").foregroundColor(.orange)
            case .transferring:  Text("\(transfer.percent)%").foregroundColor(.accentColor)
            case .verifying:     Text("Verifying…").foregroundColor(.secondary)
            case .complete:      Text("Complete").foregroundColor(.green)
            case .failed(let r): Text("Failed: \(r)").foregroundColor(.red)
            case .cancelled:     Text("Cancelled").foregroundColor(.secondary)
            }
        }
        .font(.caption2)
        .fontWeight(.medium)
    }

    private var transferIcon: String {
        switch transfer.status {
        case .incoming:      return "arrow.down.circle"
        case .transferring:  return "arrow.down.circle.fill"
        case .complete:      return "checkmark.circle.fill"
        case .failed:        return "xmark.circle.fill"
        case .cancelled:     return "minus.circle"
        default:             return "doc.circle"
        }
    }

    private var transferColor: Color {
        switch transfer.status {
        case .incoming:      return .orange
        case .transferring:  return .accentColor
        case .complete:      return .green
        case .failed:        return .red
        default:             return .secondary
        }
    }
}

// ── Single activity entry row ──────────────────────────────────────────────────

private struct ActivityEntryRowView: View {
    let entry: IpcActivityEntry
    @EnvironmentObject var store: ClipRelayStore
    @State private var applying = false
    @State private var expanded = false

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // Kind icon
            Image(systemName: kindIcon)
                .foregroundColor(kindColor)
                .font(.callout)
                .frame(width: 20, alignment: .center)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 2) {
                // Summary line
                Text(entry.summary)
                    .font(.callout)
                    .lineLimit(expanded ? nil : 2)

                // Relay path (mesh traceability)
                if !entry.relay_path.isEmpty {
                    Text(entry.relay_path.joined(separator: " → "))
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.7))
                }

                // Text preview for clipboard items
                if let preview = entry.text_preview, !preview.isEmpty, expanded {
                    Text(preview)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(6)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(4)
                        .onTapGesture { expanded = false }
                }

                // Timestamp
                Text(formattedTime(entry.timestamp_ms))
                    .font(.caption2)
                    .foregroundColor(.secondary.opacity(0.6))
            }

            Spacer()

            // Apply button for unapplied remote clipboard items
            if entry.isApplicable {
                Button {
                    applying = true
                    Task {
                        await store.applyClipboard(entry: entry)
                        applying = false
                    }
                } label: {
                    if applying {
                        ProgressView().controlSize(.mini)
                    } else {
                        Label("Apply", systemImage: "doc.on.clipboard")
                            .font(.caption)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.mini)
                .disabled(applying)
            } else if entry.applied_locally {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .contentShape(Rectangle())
        .onTapGesture {
            if entry.text_preview != nil { expanded.toggle() }
        }
    }

    private var kindIcon: String {
        switch entry.kind {
        case "remote_clipboard_available", "clipboard_text":   return "doc.on.clipboard"
        case "clipboard_image":                                return "photo"
        case "file_transfer_started":                          return "arrow.down.circle"
        case "file_transfer_complete":                         return "checkmark.circle.fill"
        case "file_transfer_failed":                           return "xmark.circle"
        case "peer_connected":                                 return "wifi"
        case "peer_disconnected":                              return "wifi.slash"
        case "sync_paused":                                    return "pause.circle"
        case "sync_resumed":                                   return "play.circle"
        case "clipboard_applied":                              return "checkmark.circle"
        default:                                               return "info.circle"
        }
    }

    private var kindColor: Color {
        switch entry.kind {
        case "remote_clipboard_available":  return entry.applied_locally ? .green : .accentColor
        case "file_transfer_complete":      return .green
        case "file_transfer_failed":        return .red
        case "peer_connected":              return .green
        case "peer_disconnected":           return .secondary
        case "sync_paused":                 return .orange
        default:                            return .secondary
        }
    }

    private func formattedTime(_ ms: Int64) -> String {
        let date = Date(timeIntervalSince1970: Double(ms) / 1000.0)
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// ── Settings pane for clipboard UX preferences ────────────────────────────────
=======
            if case .incoming = transfer.status {
                HStack(spacing: 8) {
                    Button("Accept") { store.acceptFileTransfer(transfer) }
                        .buttonStyle(PBPrimaryButtonStyle(tint: PBTheme.accentGreen))
                    Button("Reject") { store.rejectFileTransfer(transfer) }
                        .buttonStyle(PBDestructiveButtonStyle())
                }
            } else if case .transferring = transfer.status {
                Button("Cancel") { store.cancelFileTransfer(transfer) }
                    .buttonStyle(PBSecondaryButtonStyle())
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}

// MARK: - Clipboard Policy View
>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)

struct ClipboardPolicyView: View {
    @EnvironmentObject var store: ClipRelayStore
    @State private var timelineFirst = true
<<<<<<< HEAD
    @State private var autoApply = false
    @State private var saving = false
=======
    @State private var autoApply    = false
>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)

    var body: some View {
        Form {
            Section {
                Toggle("Timeline-first mode", isOn: $timelineFirst)
<<<<<<< HEAD
                    .onChange(of: timelineFirst) { newValue in
                        Task { await store.setTimelineFirstMode(enabled: newValue) }
                    }
                Text("Remote clipboard items appear in the feed instead of automatically overwriting your clipboard. You tap Apply to use them.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } header: {
                Text("Clipboard Behavior")
            }
=======
                    .onChange(of: timelineFirst) { Task { await store.setTimelineFirstMode(enabled: $0) } }
                Text("Remote clipboard items appear in the feed instead of automatically overwriting your clipboard. Tap Apply to use them.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } header: { Text("Clipboard Behavior") }
>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)

            if timelineFirst {
                Section {
                    Toggle("Auto-apply from trusted devices", isOn: $autoApply)
<<<<<<< HEAD
                        .onChange(of: autoApply) { newValue in
                            Task { await store.setAutoApplyClipboard(enabled: newValue) }
                        }
                    Text("When enabled, clipboard items from trusted devices are still applied automatically. Timeline-first for all others.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text("Auto-Apply (optional)")
                }
=======
                        .onChange(of: autoApply) { Task { await store.setAutoApplyClipboard(enabled: $0) } }
                    Text("When enabled, clipboard items from trusted devices are still applied automatically.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } header: { Text("Auto-Apply (optional)") }
>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
            }
        }
        .formStyle(.grouped)
        .padding()
        .onAppear {
            timelineFirst = store.clipboardPolicy.timelineFirstMode
<<<<<<< HEAD
            autoApply = store.clipboardPolicy.autoApply
=======
            autoApply     = store.clipboardPolicy.autoApply
>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
        }
    }
}
