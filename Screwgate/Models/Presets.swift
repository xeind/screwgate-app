import Foundation

// MARK: - Built-in presets

enum Presets {

    // MARK: xeind's preset (imported from existing karabiner.json)

    static let xeind = Preset(
        id: "xeind",
        name: "xeind's Preset",
        author: "xeind",
        description: "Bookmarks, app launcher, window management, controls, vim nav, Raycast",
        hyperKey: .capsLock,
        layers: [],
        sublayers: [

            // b — Browser bookmarks
            Sublayer(key: "b", name: "Bookmarks", bindings: [
                KeyBinding(triggerKey: "x", actionType: .shellCommand, actionValue: "open https://x.com",                          description: "X (Twitter)"),
                KeyBinding(triggerKey: "y", actionType: .shellCommand, actionValue: "open https://youtube.com",                    description: "YouTube"),
                KeyBinding(triggerKey: "f", actionType: .shellCommand, actionValue: "open https://facebook.com",                   description: "Facebook"),
                KeyBinding(triggerKey: "g", actionType: .shellCommand, actionValue: "open https://github.com",                     description: "GitHub"),
                KeyBinding(triggerKey: "r", actionType: .shellCommand, actionValue: "open https://reddit.com",                     description: "Reddit"),
                KeyBinding(triggerKey: "c", actionType: .shellCommand, actionValue: "open https://chatgpt.com",                    description: "ChatGPT"),
                KeyBinding(triggerKey: "m", actionType: .shellCommand, actionValue: "open https://mail.google.com/mail/u/0/#inbox", description: "Gmail"),
                KeyBinding(triggerKey: "p", actionType: .shellCommand, actionValue: "open https://photos.google.com/u/3/",         description: "Google Photos"),
                KeyBinding(triggerKey: "l", actionType: .shellCommand, actionValue: "open https://linkedin.com",                   description: "LinkedIn"),
            ]),

            // o — Open apps
            Sublayer(key: "o", name: "Open Apps", bindings: [
                KeyBinding(triggerKey: "1", actionType: .shellCommand, actionValue: "open -a 'Bitwarden.app'",    description: "Bitwarden"),
                KeyBinding(triggerKey: "b", actionType: .shellCommand, actionValue: "open -a 'Firefox.app'",      description: "Firefox"),
                KeyBinding(triggerKey: "z", actionType: .shellCommand, actionValue: "open -a 'Zen Browser.app'",  description: "Zen Browser"),
                KeyBinding(triggerKey: "d", actionType: .shellCommand, actionValue: "open -a 'Discord.app'",      description: "Discord"),
                KeyBinding(triggerKey: "t", actionType: .shellCommand, actionValue: "open -a 'Ghostty.app'",      description: "Ghostty"),
                KeyBinding(triggerKey: "m", actionType: .shellCommand, actionValue: "open -a 'Obsidian.app'",     description: "Obsidian"),
                KeyBinding(triggerKey: "f", actionType: .shellCommand, actionValue: "open -a 'Finder.app'",       description: "Finder"),
                KeyBinding(triggerKey: "n", actionType: .shellCommand, actionValue: "open -a 'Things3.app'",      description: "Things 3"),
                KeyBinding(triggerKey: "p", actionType: .shellCommand, actionValue: "open -a 'Skim.app'",         description: "Skim"),
                KeyBinding(triggerKey: "h", actionType: .shellCommand, actionValue: "open -a 'Helium.app'",       description: "Helium"),
                KeyBinding(triggerKey: "c", actionType: .shellCommand, actionValue: "open -a 'Zed.app'",          description: "Zed"),
            ]),

            // w — Window management (Raycast)
            Sublayer(key: "w", name: "Windows", bindings: [
                KeyBinding(triggerKey: "f",                  actionType: .shellCommand, actionValue: "open -g raycast://extensions/raycast/window-management/maximize",           description: "Maximize"),
                KeyBinding(triggerKey: "s",                  actionType: .shellCommand, actionValue: "open -g raycast://extensions/raycast/window-management/center",             description: "Center"),
                KeyBinding(triggerKey: "return_or_enter",    actionType: .shellCommand, actionValue: "open -g raycast://extensions/raycast/window-management/almost-maximize",   description: "Almost Maximize"),
                KeyBinding(triggerKey: "delete_or_backspace",actionType: .shellCommand, actionValue: "open -g raycast://extensions/raycast/window-management/restore",           description: "Restore"),
                KeyBinding(triggerKey: "x",                  actionType: .shellCommand, actionValue: "open -g raycast://extensions/raycast/window-management/reasonable-size",   description: "Reasonable Size"),
                // Halves
                KeyBinding(triggerKey: "h",                  actionType: .shellCommand, actionValue: "open -g raycast://extensions/raycast/window-management/left-half",         description: "Left Half"),
                KeyBinding(triggerKey: "l",                  actionType: .shellCommand, actionValue: "open -g raycast://extensions/raycast/window-management/right-half",        description: "Right Half"),
                KeyBinding(triggerKey: "k",                  actionType: .shellCommand, actionValue: "open -g raycast://extensions/raycast/window-management/top-half",          description: "Top Half"),
                KeyBinding(triggerKey: "j",                  actionType: .shellCommand, actionValue: "open -g raycast://extensions/raycast/window-management/bottom-half",       description: "Bottom Half"),
                // Quarters
                KeyBinding(triggerKey: "q",                  actionType: .shellCommand, actionValue: "open -g raycast://extensions/raycast/window-management/top-left-quarter",  description: "Top Left Quarter"),
                KeyBinding(triggerKey: "e",                  actionType: .shellCommand, actionValue: "open -g raycast://extensions/raycast/window-management/top-right-quarter", description: "Top Right Quarter"),
                KeyBinding(triggerKey: "a",                  actionType: .shellCommand, actionValue: "open -g raycast://extensions/raycast/window-management/bottom-left-quarter",  description: "Bottom Left Quarter"),
                KeyBinding(triggerKey: "d",                  actionType: .shellCommand, actionValue: "open -g raycast://extensions/raycast/window-management/bottom-right-quarter", description: "Bottom Right Quarter"),
                // Sixths
                KeyBinding(triggerKey: "1",                  actionType: .shellCommand, actionValue: "open -g raycast://extensions/raycast/window-management/top-left-sixth",    description: "Top Left Sixth"),
                KeyBinding(triggerKey: "3",                  actionType: .shellCommand, actionValue: "open -g raycast://extensions/raycast/window-management/top-right-sixth",   description: "Top Right Sixth"),
                KeyBinding(triggerKey: "z",                  actionType: .shellCommand, actionValue: "open -g raycast://extensions/raycast/window-management/bottom-left-sixth", description: "Bottom Left Sixth"),
                KeyBinding(triggerKey: "c",                  actionType: .shellCommand, actionValue: "open -g raycast://extensions/raycast/window-management/bottom-right-sixth",description: "Bottom Right Sixth"),
                // Resize
                KeyBinding(triggerKey: "equal_sign",         actionType: .shellCommand, actionValue: "open -g raycast://extensions/raycast/window-management/make-larger",       description: "Make Larger"),
                KeyBinding(triggerKey: "hyphen",              actionType: .shellCommand, actionValue: "open -g raycast://extensions/raycast/window-management/make-smaller",      description: "Make Smaller"),
                // Move
                KeyBinding(triggerKey: "up_arrow",           actionType: .shellCommand, actionValue: "open -g raycast://extensions/raycast/window-management/move-up",           description: "Move Up"),
                KeyBinding(triggerKey: "down_arrow",         actionType: .shellCommand, actionValue: "open -g raycast://extensions/raycast/window-management/move-down",         description: "Move Down"),
                KeyBinding(triggerKey: "left_arrow",         actionType: .shellCommand, actionValue: "open -g raycast://extensions/raycast/window-management/move-left",         description: "Move Left"),
                KeyBinding(triggerKey: "right_arrow",        actionType: .shellCommand, actionValue: "open -g raycast://extensions/raycast/window-management/move-right",        description: "Move Right"),
                // Display
                KeyBinding(triggerKey: "y",                  actionType: .shellCommand, actionValue: "open -g raycast://extensions/raycast/window-management/previous-display",  description: "Previous Display"),
                KeyBinding(triggerKey: "o",                  actionType: .shellCommand, actionValue: "open -g raycast://extensions/raycast/window-management/next-display",      description: "Next Display"),
                // Misc
                KeyBinding(triggerKey: "spacebar",           actionType: .shellCommand, actionValue: "open -b com.apple.exposelauncher",                                          description: "Mission Control"),
                KeyBinding(triggerKey: "n",                  actionType: .keyPress,     actionValue: "grave_accent_and_tilde", actionModifiers: ["right_command"],               description: "Next Window (⌘`)"),
                KeyBinding(triggerKey: "b",                  actionType: .keyPress,     actionValue: "open_bracket",          actionModifiers: ["right_command"],               description: "Back (⌘[)"),
                KeyBinding(triggerKey: "m",                  actionType: .keyPress,     actionValue: "close_bracket",         actionModifiers: ["right_command"],               description: "Forward (⌘])"),
                KeyBinding(triggerKey: "semicolon",          actionType: .keyPress,     actionValue: "h",                     actionModifiers: ["right_command"],               description: "Hide Window (⌘H)"),
                KeyBinding(triggerKey: "u",                  actionType: .keyPress,     actionValue: "tab",                   actionModifiers: ["right_control", "right_shift"],description: "Prev Tab (⌃⇧Tab)"),
                KeyBinding(triggerKey: "i",                  actionType: .keyPress,     actionValue: "tab",                   actionModifiers: ["right_control"],               description: "Next Tab (⌃Tab)"),
            ]),

            // c — Desktop/Space switching (⌃⌘+Fn keys)
            Sublayer(key: "c", name: "Desktops", bindings: [
                KeyBinding(triggerKey: "a",                  actionType: .keyPress, actionValue: "f12", actionModifiers: ["left_control", "left_command"], description: "Desktop 4 (⌃⌘F12)"),
                KeyBinding(triggerKey: "w",                  actionType: .keyPress, actionValue: "f11", actionModifiers: ["left_control", "left_command"], description: "Desktop 3 (⌃⌘F11)"),
                KeyBinding(triggerKey: "e",                  actionType: .keyPress, actionValue: "f10", actionModifiers: ["left_control", "left_command"], description: "Desktop 2 (⌃⌘F10)"),
                KeyBinding(triggerKey: "q",                  actionType: .keyPress, actionValue: "f9",  actionModifiers: ["left_control", "left_command"], description: "Desktop 1 (⌃⌘F9)"),
                KeyBinding(triggerKey: "d",                  actionType: .keyPress, actionValue: "f8",  actionModifiers: ["left_control", "left_command"], description: "Desktop 8 (⌃⌘F8)"),
                KeyBinding(triggerKey: "s",                  actionType: .keyPress, actionValue: "f7",  actionModifiers: ["left_control", "left_command"], description: "Desktop 7 (⌃⌘F7)"),
                KeyBinding(triggerKey: "k",                  actionType: .keyPress, actionValue: "f6",  actionModifiers: ["left_control", "left_command"], description: "Desktop 6 (⌃⌘F6)"),
                KeyBinding(triggerKey: "z",                  actionType: .keyPress, actionValue: "f5",  actionModifiers: ["left_control", "left_command"], description: "Desktop 5 (⌃⌘F5)"),
                KeyBinding(triggerKey: "delete_or_backspace",actionType: .keyPress, actionValue: "f4",  actionModifiers: ["left_control", "left_command"], description: "Desktop 0 (⌃⌘F4)"),
            ]),

            // s — System controls
            Sublayer(key: "s", name: "System", bindings: [
                KeyBinding(triggerKey: "u", actionType: .keyPress,     actionValue: "volume_increment",           description: "Volume Up"),
                KeyBinding(triggerKey: "j", actionType: .keyPress,     actionValue: "volume_decrement",           description: "Volume Down"),
                KeyBinding(triggerKey: "i", actionType: .keyPress,     actionValue: "display_brightness_increment",description: "Brightness Up"),
                KeyBinding(triggerKey: "k", actionType: .keyPress,     actionValue: "display_brightness_decrement",description: "Brightness Down"),
                KeyBinding(triggerKey: "l", actionType: .keyPress,     actionValue: "q", actionModifiers: ["right_control", "right_command"], description: "Lock Screen (⌃⌘Q)"),
                KeyBinding(triggerKey: "p", actionType: .shellCommand, actionValue: "open x-apple.systempreferences:com.apple.preference",                       description: "System Settings"),
                KeyBinding(triggerKey: "d", actionType: .shellCommand, actionValue: "open raycast://extensions/yakitrak/do-not-disturb/toggle?launchType=background", description: "Toggle Do Not Disturb"),
                KeyBinding(triggerKey: "c", actionType: .shellCommand, actionValue: "open raycast://extensions/raycast/system/open-camera",                       description: "Open Camera"),
                KeyBinding(triggerKey: "r", actionType: .shellCommand, actionValue: "open raycast://script-commands/recording-mode",                              description: "Start Recording Mode"),
                KeyBinding(triggerKey: "t", actionType: .shellCommand, actionValue: "open raycast://script-commands/undo-recording-mode",                         description: "Stop Recording Mode"),
            ]),

            // v — Vim navigation
            Sublayer(key: "v", name: "Vim Nav", bindings: [
                KeyBinding(triggerKey: "h", actionType: .keyPress, actionValue: "left_arrow",  description: "← Left"),
                KeyBinding(triggerKey: "j", actionType: .keyPress, actionValue: "down_arrow",  description: "↓ Down"),
                KeyBinding(triggerKey: "k", actionType: .keyPress, actionValue: "up_arrow",    description: "↑ Up"),
                KeyBinding(triggerKey: "l", actionType: .keyPress, actionValue: "right_arrow", description: "→ Right"),
                KeyBinding(triggerKey: "u", actionType: .keyPress, actionValue: "page_down",   description: "Page Down"),
                KeyBinding(triggerKey: "i", actionType: .keyPress, actionValue: "page_up",     description: "Page Up"),
                KeyBinding(triggerKey: "b", actionType: .keyPress, actionValue: "left_arrow",  actionModifiers: ["left_option"], description: "Word Left (⌥←)"),
                KeyBinding(triggerKey: "m", actionType: .keyPress, actionValue: "right_arrow", actionModifiers: ["left_option"], description: "Word Right (⌥→)"),
                KeyBinding(triggerKey: "n", actionType: .keyPress, actionValue: "delete_or_backspace", actionModifiers: ["left_option"], description: "Delete Word (⌥⌫)"),
                // Space/s/f → desktop switch via Ctrl+Cmd+Fn
                KeyBinding(triggerKey: "spacebar", actionType: .keyPress, actionValue: "f1", actionModifiers: ["left_control", "left_command"], description: "Desktop 1 (⌃⌘F1)"),
                KeyBinding(triggerKey: "s",        actionType: .keyPress, actionValue: "f2", actionModifiers: ["left_control", "left_command"], description: "Desktop 2 (⌃⌘F2)"),
                KeyBinding(triggerKey: "f",        actionType: .keyPress, actionValue: "f3", actionModifiers: ["left_control", "left_command"], description: "Desktop 3 (⌃⌘F3)"),
            ]),

            // r — Raycast commands
            Sublayer(key: "r", name: "Raycast", bindings: [
                KeyBinding(triggerKey: "c", actionType: .shellCommand, actionValue: "open raycast://extensions/thomas/color-picker/pick-color",          description: "Color Picker"),
                KeyBinding(triggerKey: "j", actionType: .shellCommand, actionValue: "open raycast://script-commands/dismiss-notifications",              description: "Dismiss Notifications"),
                KeyBinding(triggerKey: "e", actionType: .shellCommand, actionValue: "open raycast://extensions/raycast/emoji-symbols/search-emoji-symbols", description: "Emoji Picker"),
            ]),
        ]
    )

    // MARK: Default preset (simple vi-style flat bindings)

    static let defaultPreset = Preset(
        id: "default",
        name: "Default Preset",
        author: "Screwgate",
        description: "Simple vi-style arrow key and editing shortcuts as direct bindings",
        hyperKey: .capsLock,
        layers: [
            Layer(triggerKey: "j", actionType: .keyPress, actionValue: "down_arrow",           description: "Arrow Down"),
            Layer(triggerKey: "k", actionType: .keyPress, actionValue: "up_arrow",             description: "Arrow Up"),
            Layer(triggerKey: "h", actionType: .keyPress, actionValue: "left_arrow",           description: "Arrow Left"),
            Layer(triggerKey: "l", actionType: .keyPress, actionValue: "right_arrow",          description: "Arrow Right"),
            Layer(triggerKey: "d", actionType: .keyPress, actionValue: "delete_forward",       description: "Delete Forward"),
            Layer(triggerKey: "w", actionType: .keyPress, actionValue: "delete_or_backspace",  actionModifiers: ["left_option"], description: "Delete Word (⌥⌫)"),
            Layer(triggerKey: "t", actionType: .keyPress, actionValue: "t", actionModifiers: ["left_command"], description: "New Tab (⌘T)"),
            Layer(triggerKey: "n", actionType: .keyPress, actionValue: "n", actionModifiers: ["left_command"], description: "New Window (⌘N)"),
            Layer(triggerKey: "q", actionType: .keyPress, actionValue: "q", actionModifiers: ["left_command"], description: "Quit App (⌘Q)"),
        ],
        sublayers: []
    )

    static let all: [Preset] = [xeind, defaultPreset]
}
