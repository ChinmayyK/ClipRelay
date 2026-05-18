// IncomingCallBanner.swift — ClipRelay macOS
// Apple-style incoming call banner overlay.
//
// Architecture mirrors NotificationOverlayWindow.swift:
//   CallBannerWindowManager owns a CallBannerPanel (NSPanel)
//   that hosts a SwiftUI CallBannerView.
//
// The banner appears when store.activeCall transitions from nil → ringing,
// plays a ringtone loop via AVAudioPlayer, and dismisses on accept/decline/idle.

import AppKit
import AVFoundation
import Combine
import SwiftUI

// MARK: - Window Manager

@MainActor
final class CallBannerWindowManager: NSObject {
    private let store: ClipRelayStore
    private let panel: CallBannerPanel
    private let hostingView: NSHostingView<CallBannerContainerView>
    private var audioPlayer: AVAudioPlayer?
    private var cancellables = Set<AnyCancellable>()

    init(store: ClipRelayStore) {
        self.store = store
        self.panel = CallBannerPanel()
        self.hostingView = NSHostingView(rootView: CallBannerContainerView(store: store))
        super.init()

        hostingView.translatesAutoresizingMaskIntoConstraints = false
        panel.contentView = NSView(frame: .zero)
        panel.contentView?.addSubview(hostingView)
        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: panel.contentView!.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: panel.contentView!.trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: panel.contentView!.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: panel.contentView!.bottomAnchor),
        ])

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(layoutPanel),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )

        store.$activeCall
            .receive(on: RunLoop.main)
            .sink { [weak self] call in
                self?.handleCallUpdate(call)
            }
            .store(in: &cancellables)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        audioPlayer?.stop()
    }

    private func handleCallUpdate(_ call: IncomingCallState?) {
        layoutPanel()
        if let call = call, call.isRinging {
            panel.orderFrontRegardless()
            startRingtone()
            NSHapticFeedbackManager.defaultPerformer.perform(.levelChange, performanceTime: .default)
        } else {
            panel.orderOut(nil)
            stopRingtone()
        }
    }

    @objc private func layoutPanel() {
        guard let screen = activeScreen else { return }
        let visible = screen.visibleFrame
        let width: CGFloat = 380
        let height: CGFloat = 160
        let frame = NSRect(
            x: visible.midX - width / 2,
            y: visible.maxY - height - 12,
            width: width,
            height: height
        )
        panel.setFrame(frame, display: false)
    }

    private var activeScreen: NSScreen? {
        if let key = NSApp.keyWindow?.screen { return key }
        let mouse = NSEvent.mouseLocation
        return NSScreen.screens.first { NSMouseInRect(mouse, $0.frame, false) } ?? NSScreen.main
    }

    // MARK: - Audio

    private func startRingtone() {
        guard audioPlayer == nil || audioPlayer?.isPlaying == false else { return }
        // Try bundled ringtone first, fall back to system sound
        let url = Bundle.main.url(forResource: "ringtone", withExtension: "caf")
            ?? Bundle.main.url(forResource: "ringtone", withExtension: "mp3")
        guard let url = url else {
            // Fallback: play system sound
            NSSound.beep()
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // infinite loop
            audioPlayer?.volume = 0.7
            audioPlayer?.play()
        } catch {
            NSLog("ClipRelay: failed to play ringtone: \(error)")
        }
    }

    private func stopRingtone() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}

// MARK: - Panel

private final class CallBannerPanel: NSPanel {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 160),
            styleMask: [.borderless, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        level = .floating
        hasShadow = true
        isOpaque = false
        backgroundColor = .clear
        hidesOnDeactivate = false
        ignoresMouseEvents = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

// MARK: - SwiftUI Container

private struct CallBannerContainerView: View {
    @ObservedObject var store: ClipRelayStore

    var body: some View {
        Group {
            if let call = store.activeCall, call.isRinging {
                CallBannerView(
                    call: call,
                    onAccept: { store.acceptCall() },
                    onDecline: { store.declineCall() }
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(8)
        .animation(.spring(response: 0.4, dampingFraction: 0.78, blendDuration: 0.1), value: store.activeCall)
    }
}

// MARK: - Call Banner View

private struct CallBannerView: View {
    let call: IncomingCallState
    let onAccept: () -> Void
    let onDecline: () -> Void

    @State private var ringPulse = false

    @Environment(\.colorScheme) var colorScheme

    // ── Design tokens ────────────────────────────────────────────────────────
    private let acceptGreen = Color(hex: 0x30D158)
    private let declineRed = Color(hex: 0xFF453A)

    var body: some View {
        HStack(spacing: 16) {
            // ── Caller avatar / phone icon ────────────────────────────────
            ZStack {
                Circle()
                    .fill(acceptGreen.opacity(0.15))
                    .frame(width: 56, height: 56)
                    .scaleEffect(ringPulse ? 1.25 : 1.0)
                    .opacity(ringPulse ? 0.0 : 0.4)

                Circle()
                    .fill(colorScheme == .dark ? Color.white.opacity(0.15) : Color.black.opacity(0.1))
                    .frame(width: 48, height: 48)

                Image(systemName: "phone.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(acceptGreen)
                    .rotationEffect(.degrees(ringPulse ? -15 : 15))
            }
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 0.5)
                    .repeatForever(autoreverses: true)
                ) {
                    ringPulse = true
                }
            }

            // ── Caller info ──────────────────────────────────────────────
            VStack(alignment: .leading, spacing: 4) {
                Text("Incoming Call")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(acceptGreen)
                    .textCase(.uppercase)
                    .tracking(0.8)

                Text(call.displayName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "iphone")
                        .font(.system(size: 10))
                    Text(call.deviceName)
                        .font(.system(size: 11))
                }
                .foregroundStyle(Color.secondary)
            }

            Spacer(minLength: 0)

            // ── Action buttons ────────────────────────────────────────────
            VStack(spacing: 8) {
                Button(action: onAccept) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(acceptGreen))
                }
                .buttonStyle(.plain)
                .shadow(color: acceptGreen.opacity(0.4), radius: 8, y: 2)

                Button(action: onDecline) {
                    Image(systemName: "phone.down.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(declineRed))
                }
                .buttonStyle(.plain)
                .shadow(color: declineRed.opacity(0.4), radius: 8, y: 2)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.clear)
                .background(CRHUDMaterial().clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous)))
                .background {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(colorScheme == .dark ? Color.black.opacity(0.4) : Color.white.opacity(0.4))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(colorScheme == .dark ? Color.white.opacity(0.15) : Color.black.opacity(0.1), lineWidth: 0.5)
                }
                .shadow(color: .black.opacity(0.25), radius: 20, y: 8)
        }
    }
}
