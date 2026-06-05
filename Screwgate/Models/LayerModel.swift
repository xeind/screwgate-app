import Foundation

// MARK: - Hyper key choice

enum HyperKey: String, CaseIterable, Identifiable, Codable {
    case capsLock     = "caps_lock"
    case fn           = "fn"
    case rightCommand = "right_command"
    case rightOption  = "right_option"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .capsLock:     return "Caps Lock"
        case .fn:           return "Fn"
        case .rightCommand: return "Right ⌘"
        case .rightOption:  return "Right ⌥"
        }
    }
}

// MARK: - Action type (shared by Layer and Binding)

enum ActionType: String, CaseIterable, Identifiable, Codable {
    case keyPress     = "key_press"
    case url          = "url"
    case openApp      = "open_app"
    case shellCommand = "shell_command"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .keyPress:     return "Key Press"
        case .url:          return "URL"
        case .openApp:      return "Open App"
        case .shellCommand: return "Shell"
        }
    }
}

// MARK: - Modifier symbol helper (delegates to KeyDisplay)

func modifierSymbol(_ mod: String) -> String? {
    KeyDisplay.modifierSymbol(mod)
}

// MARK: - Direct (flat) binding: Hyper + key → action

struct Layer: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var triggerKey: String
    var actionType: ActionType
    var actionValue: String
    var actionModifiers: [String]
    var layerDescription: String

    init(
        id: UUID = UUID(),
        triggerKey: String,
        actionType: ActionType,
        actionValue: String,
        actionModifiers: [String] = [],
        description: String = ""
    ) {
        self.id = id
        self.triggerKey       = triggerKey
        self.actionType       = actionType
        self.actionValue      = actionValue
        self.actionModifiers  = actionModifiers
        self.layerDescription = description.isEmpty
            ? "Hyper+\(KeyDisplay.symbol(for: triggerKey)) → \(actionValue)"
            : description
    }

    var displayTrigger: String { "Hyper + \(KeyDisplay.symbol(for: triggerKey))" }

    var displayAction: String {
        actionDisplayString(type: actionType, value: actionValue, modifiers: actionModifiers)
    }
}

// MARK: - Sublayer: Hyper + sublayerKey → activate → key → action

struct Sublayer: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var key: String       // e.g., "b"
    var name: String      // e.g., "Bookmarks"
    var bindings: [KeyBinding]

    init(id: UUID = UUID(), key: String, name: String, bindings: [KeyBinding] = []) {
        self.id = id
        self.key = key
        self.name = name
        self.bindings = bindings
    }

    /// Karabiner variable name for this sublayer
    var variableName: String { "hyper_sublayer_\(key)" }
    var displayTrigger: String { "Hyper + \(KeyDisplay.symbol(for: key))" }
}

// MARK: - Binding: a single key→action inside a sublayer

struct KeyBinding: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var triggerKey: String
    var actionType: ActionType
    var actionValue: String
    var actionModifiers: [String]
    var bindingDescription: String

    init(
        id: UUID = UUID(),
        triggerKey: String,
        actionType: ActionType,
        actionValue: String,
        actionModifiers: [String] = [],
        description: String = ""
    ) {
        self.id = id
        self.triggerKey        = triggerKey
        self.actionType        = actionType
        self.actionValue       = actionValue
        self.actionModifiers   = actionModifiers
        self.bindingDescription = description.isEmpty
            ? "\(KeyDisplay.symbol(for: triggerKey)) → \(actionValue)"
            : description
    }

    var displayTrigger: String { KeyDisplay.symbol(for: triggerKey) }

    var displayAction: String {
        actionDisplayString(type: actionType, value: actionValue, modifiers: actionModifiers)
    }
}

// MARK: - Shared display helper

private func actionDisplayString(type: ActionType, value: String, modifiers: [String]) -> String {
    switch type {
    case .keyPress:
        let mods = modifiers.compactMap { KeyDisplay.modifierSymbol($0) }.joined()
        let key  = KeyDisplay.symbol(for: value)
        return mods.isEmpty ? key : "\(mods)\(key)"
    case .url:
        return URL(string: value)?.host ?? value
    case .openApp:
        return URL(fileURLWithPath: value).deletingPathExtension().lastPathComponent
    case .shellCommand:
        return value
    }
}

// MARK: - Preset

struct Preset: Identifiable {
    let id: String
    let name: String
    let author: String
    let description: String
    let hyperKey: HyperKey
    let layers: [Layer]
    let sublayers: [Sublayer]
}
