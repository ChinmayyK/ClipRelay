<<<<<<< HEAD
=======
// CommandPaletteView.swift
// Keyboard-first command palette — summon with ⌘K

>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
import SwiftUI

struct CommandPaletteView: View {
    @ObservedObject var store: ClipRelayStore
    @State private var query = ""
<<<<<<< HEAD
    @FocusState private var focused: Bool

    var suggestions: [String] {
        let all = [
            "/history",
            "/devices",
            "/send \(store.connectedDevices.first?.name ?? "<device>")",
            "/connect 192.168.1.20:47823",
            "/trust \(store.devices.first?.name ?? "<device>")",
        ]

        if query.isEmpty { return all }
        return all.filter { $0.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        PBPanel(dark: true) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Command Palette")
                        .font(.system(size: 25, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                    Text("Jump directly to history, devices, trust actions, and manual connects.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.64))
                }

                HStack(spacing: 10) {
                    Image(systemName: "command")
                        .foregroundStyle(.white.opacity(0.66))
                    TextField("Run a command", text: $query)
                        .textFieldStyle(.plain)
                        .focused($focused)
                        .onSubmit {
                            store.performCommand(query)
                        }
                }
                .pbInput(dark: true)

                VStack(spacing: 10) {
                    ForEach(suggestions, id: \.self) { suggestion in
                        Button {
                            query = suggestion
                            store.performCommand(suggestion)
                        } label: {
                            HStack {
                                Text(suggestion)
                                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                                    .foregroundStyle(.white)
                                Spacer()
                                Image(systemName: "arrow.up.left")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.45))
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.white.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(18)
        }
        .frame(width: 540)
        .onAppear { focused = true }
=======
    @State private var selectedIndex = 0
    @FocusState private var inputFocused: Bool

    private var commands: [PaletteCommand] {
        let all: [PaletteCommand] = [
            PaletteCommand(icon: "clock.arrow.circlepath", label: "Open Timeline",    hint: "View recent clipboard activity",  action: { store.selectedSection = .timeline }),
            PaletteCommand(icon: "desktopcomputer",        label: "Open Devices",     hint: "Manage connected peers",          action: { store.selectedSection = .devices }),
            PaletteCommand(icon: "checkmark.shield.fill",  label: "Open Trust",       hint: "Review device trust requests",    action: { store.selectedSection = .trust }),
            PaletteCommand(icon: "slider.horizontal.3",    label: "Open Settings",    hint: "Tune sync and network options",   action: { store.selectedSection = .settings }),
            PaletteCommand(icon: "paperplane.fill",        label: "Send Clipboard",   hint: "Push current clipboard to all",   action: { store.sendCurrentClipboard(to: nil) }),
            PaletteCommand(icon: "network",                label: "Manual Connect…",  hint: "Connect to a specific IP:port",   action: { store.selectedSection = .devices }),
        ]
        if query.isEmpty { return all }
        return all.filter {
            $0.label.localizedCaseInsensitiveContains(query) ||
            $0.hint.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        ZStack {
            VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Input ─────────────────────────────────────────────────────
                HStack(spacing: 12) {
                    Image(systemName: "command")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white.opacity(0.40))
                        .frame(width: 20)

                    TextField("Type a command…", text: $query)
                        .textFieldStyle(.plain)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .focused($inputFocused)
                        .onSubmit { runSelected() }

                    if !query.isEmpty {
                        Button { query = "" } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.white.opacity(0.35))
                        }
                        .buttonStyle(.plain)
                        .transition(.scale.combined(with: .opacity))
                    }

                    // Keyboard shortcut hint
                    Text("↵ run")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.25))
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)

                Divider().opacity(0.20)

                // ── Results ───────────────────────────────────────────────────
                if commands.isEmpty {
                    noResults
                } else {
                    VStack(spacing: 3) {
                        ForEach(Array(commands.enumerated()), id: \.element.id) { idx, cmd in
                            PaletteRow(
                                command: cmd,
                                isSelected: idx == selectedIndex
                            )
                            .onTapGesture {
                                selectedIndex = idx
                                runSelected()
                            }
                            .onHover { hovered in if hovered { selectedIndex = idx } }
                        }
                    }
                    .padding(10)
                }

                Divider().opacity(0.20)

                // ── Footer ────────────────────────────────────────────────────
                HStack(spacing: 14) {
                    Label("↑↓ navigate", systemImage: "")
                        .font(.system(size: 10.5, design: .monospaced))
                    Label("↵ run", systemImage: "")
                        .font(.system(size: 10.5, design: .monospaced))
                    Label("⎋ dismiss", systemImage: "")
                        .font(.system(size: 10.5, design: .monospaced))
                }
                .foregroundStyle(.white.opacity(0.22))
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
            }
        }
        .frame(width: 520)
        .fixedSize(horizontal: false, vertical: true)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.35), radius: 48, x: 0, y: 16)
        .environment(\.colorScheme, .dark)
        .onAppear { inputFocused = true; selectedIndex = 0 }
        .onChange(of: query) { _ in selectedIndex = 0 }
        .background {
            // Arrow-key handler via NSView trick
            KeyEventInterceptor { event in
                switch event.keyCode {
                case 125: selectedIndex = min(selectedIndex + 1, commands.count - 1); return true // ↓
                case 126: selectedIndex = max(selectedIndex - 1, 0); return true                  // ↑
                case 36:  runSelected(); return true                                               // ↵
                default:  return false
                }
            }
        }
    }

    private var noResults: some View {
        VStack(spacing: 10) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(.white.opacity(0.20))
            Text("No commands matched")
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.35))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
    }

    private func runSelected() {
        guard !commands.isEmpty else { return }
        let cmd = commands[max(0, min(selectedIndex, commands.count - 1))]
        cmd.action()
    }
}

// MARK: - Palette Row

private struct PaletteRow: View {
    let command: PaletteCommand
    var isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.white.opacity(isSelected ? 0.14 : 0.06))
                    .frame(width: 30, height: 30)
                Image(systemName: command.icon)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(isSelected ? 0.95 : 0.55))
                    .symbolRenderingMode(.hierarchical)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(command.label)
                    .font(.system(size: 13.5, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(.white.opacity(isSelected ? 1.0 : 0.80))
                Text(command.hint)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(isSelected ? 0.55 : 0.35))
            }

            Spacer()

            if isSelected {
                Text("↵")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.30))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color.white.opacity(0.08)))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isSelected ? Color.white.opacity(0.08) : .clear)
        }
        .animation(.spring(response: 0.18, dampingFraction: 0.8), value: isSelected)
        .contentShape(Rectangle())
    }
}

// MARK: - Palette Command Model

private struct PaletteCommand: Identifiable {
    let id = UUID()
    let icon: String
    let label: String
    let hint: String
    let action: () -> Void
}

// MARK: - NSVisualEffectView Wrapper

private struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let v = NSVisualEffectView()
        v.material = material; v.blendingMode = blendingMode; v.state = .active
        return v
    }
    func updateNSView(_ v: NSVisualEffectView, context: Context) {
        v.material = material; v.blendingMode = blendingMode
    }
}

// MARK: - Key Event Interceptor (arrow key navigation)

private struct KeyEventInterceptor: NSViewRepresentable {
    let handler: (NSEvent) -> Bool

    func makeNSView(context: Context) -> KeyView {
        let v = KeyView(); v.handler = handler; return v
    }
    func updateNSView(_ v: KeyView, context: Context) { v.handler = handler }

    class KeyView: NSView {
        var handler: ((NSEvent) -> Bool)?
        override var acceptsFirstResponder: Bool { false }
        override func keyDown(with event: NSEvent) {
            if handler?(event) == true { return }
            super.keyDown(with: event)
        }
>>>>>>> 546e515 (feat: implement architectural improvements and synchronize core assets)
    }
}
