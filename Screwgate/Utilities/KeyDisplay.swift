import Foundation

/// Converts Karabiner key_code strings into human-readable display symbols.
struct KeyDisplay {

    // MARK: - Key symbol

    static func symbol(for keyCode: String) -> String {
        switch keyCode {
        // ── Punctuation / symbols ─────────────────────────────
        case "hyphen":                  return "-"
        case "equal_sign":              return "="
        case "open_bracket":            return "["
        case "close_bracket":           return "]"
        case "backslash":               return "\\"
        case "semicolon":               return ";"
        case "quote":                   return "'"
        case "grave_accent_and_tilde":  return "`"
        case "comma":                   return ","
        case "period":                  return "."
        case "slash":                   return "/"

        // ── Whitespace / editing ─────────────────────────────
        case "spacebar":                return "⎵"
        case "tab":                     return "⇥"
        case "return_or_enter":         return "↩"
        case "escape":                  return "⎋"
        case "delete_or_backspace":     return "⌫"
        case "delete_forward":          return "⌦"
        case "caps_lock":               return "⇪"

        // ── Arrows ─────────────────────────────────────────
        case "up_arrow":                return "↑"
        case "down_arrow":              return "↓"
        case "left_arrow":              return "←"
        case "right_arrow":             return "→"

        // ── Navigation ─────────────────────────────────────
        case "page_up":                 return "PgUp"
        case "page_down":               return "PgDn"
        case "home":                    return "↖"
        case "end":                     return "↘"
        case "insert":                  return "Ins"

        // ── Media / system ─────────────────────────────────
        case "volume_increment":        return "Vol+"
        case "volume_decrement":        return "Vol-"
        case "mute":                    return "Mute"
        case "play_or_pause":           return "⏯"
        case "fastforward":             return "⏩"
        case "rewind":                  return "⏪"
        case "display_brightness_increment": return "Brt+"
        case "display_brightness_decrement": return "Brt-"

        // ── Function keys ───────────────────────────────────
        case "f1":  return "F1"
        case "f2":  return "F2"
        case "f3":  return "F3"
        case "f4":  return "F4"
        case "f5":  return "F5"
        case "f6":  return "F6"
        case "f7":  return "F7"
        case "f8":  return "F8"
        case "f9":  return "F9"
        case "f10": return "F10"
        case "f11": return "F11"
        case "f12": return "F12"
        case "f13": return "F13"
        case "f14": return "F14"
        case "f15": return "F15"
        case "f16": return "F16"
        case "f17": return "F17"
        case "f18": return "F18"
        case "f19": return "F19"
        case "f20": return "F20"

        // ── Modifier keys ───────────────────────────────────
        case "left_command", "right_command":   return "⌘"
        case "left_option",  "right_option":    return "⌥"
        case "left_control", "right_control":   return "⌃"
        case "left_shift",   "right_shift":     return "⇧"
        case "fn":                              return "Fn"

        // ── Single letter / number: just uppercase ──────────
        default:
            if keyCode.count == 1 { return keyCode.uppercased() }
            // Unknown multi-word code: title-case it
            return keyCode
                .split(separator: "_")
                .map { $0.prefix(1).uppercased() + $0.dropFirst() }
                .joined(separator: " ")
        }
    }

    // MARK: - Modifier symbols for display in action column

    static func modifierSymbol(_ mod: String) -> String? {
        switch mod {
        case "left_command",  "right_command": return "⌘"
        case "left_option",   "right_option":  return "⌥"
        case "left_control",  "right_control": return "⌃"
        case "left_shift",    "right_shift":   return "⇧"
        default: return nil
        }
    }
}
