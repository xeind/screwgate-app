import SwiftUI
import AppKit

// MARK: - ANSI keyboard preview (60 / 65 / 75 / TKL)

struct KeyboardLayoutView: View {
    let activeKeys: Set<String>
    var layout: KeyboardLayout = .sixtyFive
    var hyperKeyCode: String   = "caps_lock"
    var onKeyTap: ((String) -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {

            // ── F-row (75% and TKL only) ──────────────────────────
            if layout == .seventyFive || layout == .tkl {
                HStack(spacing: 2) {
                    cap("escape", w: 20)
                    Rectangle().fill(.clear).frame(width: layout == .tkl ? 12 : 4)
                    ForEach(fKeys, id: \.self) { cap($0, w: layout == .tkl ? 20 : 17) }
                    if layout == .tkl {
                        Rectangle().fill(.clear).frame(width: 6)
                        caps(["print_screen", "scroll_lock", "pause"])
                    }
                }
            }

            // ── Number row ────────────────────────────────────────
            HStack(spacing: 2) {
                // 60/65: Escape lives here; 75/TKL: it moved to F-row
                if layout == .sixty || layout == .sixtyFive {
                    cap("escape", w: 20)
                    Rectangle().fill(.clear).frame(width: 6)
                }
                caps(numberRowKeys)
                cap("delete_or_backspace", w: 32)
                if layout == .tkl {
                    Rectangle().fill(.clear).frame(width: 6)
                    caps(["insert", "home", "page_up"])
                }
            }

            // ── QWERTY row ────────────────────────────────────────
            HStack(spacing: 2) {
                cap("tab", w: 30)
                caps(["q","w","e","r","t","y","u","i","o","p","open_bracket","close_bracket"])
                cap("backslash", w: 26)
                if layout == .tkl {
                    Rectangle().fill(.clear).frame(width: 6)
                    caps(["delete_forward", "end", "page_down"])
                }
            }

            // ── Home row ──────────────────────────────────────────
            HStack(spacing: 2) {
                cap("caps_lock", w: 34,
                    forceLabel: hyperKeyCode == "caps_lock" ? "Hyper" : nil,
                    dead: hyperKeyCode == "caps_lock")
                caps(["a","s","d","f","g","h","j","k","l","semicolon","quote"])
                cap("return_or_enter", w: 40)
            }

            // ── ZXCV row ─────────────────────────────────────────
            HStack(spacing: 2) {
                Rectangle().fill(.clear).frame(width: 42)   // ⇧ placeholder
                caps(["z","x","c","v","b","n","m","comma","period","slash"])
            }

            // ── Bottom row ────────────────────────────────────────
            HStack(spacing: 2) {
                cap("spacebar", w: layout == .sixty ? 160 : 120)
                if layout != .sixty {
                    Rectangle().fill(.clear).frame(width: 6)
                    caps(["left_arrow", "down_arrow", "up_arrow", "right_arrow"])
                }
            }
        }
        .padding(10)
        .background(.quinary, in: RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(.separator.opacity(0.5), lineWidth: 0.5)
        )
    }

    // ── Static key lists ─────────────────────────────────────────

    private let fKeys = ["f1","f2","f3","f4","f5","f6","f7","f8","f9","f10","f11","f12"]
    private let numberRowKeys = ["grave_accent_and_tilde","1","2","3","4","5","6","7","8","9","0","hyphen","equal_sign"]

    // ── Helpers ──────────────────────────────────────────────────

    @ViewBuilder
    private func caps(_ codes: [String]) -> some View {
        ForEach(codes, id: \.self) { cap($0) }
    }

    @ViewBuilder
    private func cap(
        _ code: String,
        w: CGFloat = 20,
        forceLabel: String? = nil,
        dead: Bool = false
    ) -> some View {
        let label = forceLabel ?? KeyDisplay.symbol(for: code)
        let active = activeKeys.contains(code)
        KeyCap(label: label, width: w, isActive: active, isDead: dead) {
            if !dead { onKeyTap?(code) }
        }
    }
}

// MARK: - Single keycap

private struct KeyCap: View {
    let label: String
    let width: CGFloat
    let isActive: Bool
    let isDead: Bool
    let onTap: () -> Void

    @State private var isHovered = false

    private var bg: Color {
        if isDead   { return Color(nsColor: .controlBackgroundColor).opacity(0.4) }
        if isActive { return .accentColor }
        return isHovered ? Color.accentColor.opacity(0.12) : Color(nsColor: .controlBackgroundColor)
    }

    private var fg: Color {
        if isDead   { return .secondary.opacity(0.35) }
        if isActive { return .white }
        return isHovered ? .accentColor : .secondary
    }

    var body: some View {
        Button(action: onTap) {
            Text(label)
                .font(.system(size: 9, weight: isActive ? .bold : .medium, design: .monospaced))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .foregroundStyle(fg)
                .frame(width: width, height: 19)
                .background {
                    RoundedRectangle(cornerRadius: 3).fill(bg)
                    if isActive || isHovered {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(LinearGradient(
                                colors: [.white.opacity(isActive ? 0.2 : 0.05), .clear],
                                startPoint: .top, endPoint: .center
                            ))
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .strokeBorder(
                            isActive   ? Color.accentColor.opacity(0.6)
                            : isHovered ? Color.accentColor.opacity(0.35)
                                        : Color.secondary.opacity(0.15),
                            lineWidth: 0.5
                        )
                )
                .shadow(
                    color: isActive ? Color.accentColor.opacity(0.4) : .black.opacity(0.07),
                    radius: isActive ? 3 : 0.5,
                    x: 0, y: 1
                )
        }
        .buttonStyle(.plain)
        .disabled(isDead)
        .onHover { hovering in
            guard !isDead else { return }
            withAnimation(.easeInOut(duration: 0.1)) { isHovered = hovering }
            if hovering { NSCursor.pointingHand.push() }
            else        { NSCursor.pop() }
        }
        .help(isDead   ? "Hyper key — cannot be used as a trigger"
              : isActive ? "Jump to binding"
                         : "Add binding for this key")
    }
}

// MARK: - Preview

#Preview("65%") {
    KeyboardLayoutView(
        activeKeys: ["j","k","h","l","semicolon","spacebar","return_or_enter"],
        layout: .sixtyFive,
        hyperKeyCode: "caps_lock"
    )
    .padding()
    .frame(width: 440)
}

#Preview("TKL") {
    KeyboardLayoutView(
        activeKeys: ["j","k","h","l","f5","insert"],
        layout: .tkl,
        hyperKeyCode: "caps_lock"
    )
    .padding()
    .frame(width: 600)
}
