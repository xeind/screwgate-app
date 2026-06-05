import Foundation

// MARK: - Top-level config

struct KarabinerConfig: Codable {
    var global: Global = Global()
    var profiles: [Profile]
}

struct Global: Codable {
    var check_for_updates_on_startup: Bool = true
    var show_in_menu_bar: Bool = true
    var show_profile_name_in_menu_bar: Bool = false
}

struct Profile: Codable {
    var name: String
    var selected: Bool
    var complex_modifications: ComplexModifications
}

struct ComplexModifications: Codable {
    var parameters: Parameters = Parameters()
    var rules: [Rule] = []
}

struct Parameters: Codable {
    var simultaneousThreshold: Int = 50
    var heldDownThreshold: Int = 500
    var ifAloneTime: Int = 1000

    enum CodingKeys: String, CodingKey {
        case simultaneousThreshold = "basic.simultaneous_threshold_milliseconds"
        case heldDownThreshold     = "basic.to_if_held_down_threshold_milliseconds"
        case ifAloneTime           = "basic.to_if_alone_time_milliseconds"
    }
}

// MARK: - Rules & manipulators

struct Rule: Codable {
    var description: String
    var manipulators: [Manipulator]
}

struct Manipulator: Codable {
    var type: String = "basic"
    var from: FromKey
    var to: [ToKey]
    var to_if_alone: [ToKey]?
    var to_after_key_up: [ToKey]?
    var conditions: [Condition]?
}

// MARK: - From

struct FromKey: Codable {
    var key_code: String
    var modifiers: KeyModifiers?
}

struct KeyModifiers: Codable {
    var mandatory: [String]?
    var optional: [String]?
}

// MARK: - To

struct SetVariable: Codable {
    var name: String
    var value: Int
}

struct ToKey: Codable {
    var key_code: String?
    var shell_command: String?
    var modifiers: [String]?
    var lazy: Bool?
    var toRepeat: Bool?
    var set_variable: SetVariable?

    enum CodingKeys: String, CodingKey {
        case key_code, shell_command, modifiers, lazy, set_variable
        case toRepeat = "repeat"
    }

    init(
        key_code: String? = nil,
        shell_command: String? = nil,
        modifiers: [String]? = nil,
        lazy: Bool? = nil,
        toRepeat: Bool? = nil,
        set_variable: SetVariable? = nil
    ) {
        self.key_code      = key_code
        self.shell_command = shell_command
        self.modifiers     = modifiers
        self.lazy          = lazy
        self.toRepeat      = toRepeat
        self.set_variable  = set_variable
    }
}

// MARK: - Conditions

struct Condition: Codable {
    var type: String
    // variable_if fields
    var name: String?
    var value: Int?
    // bundle_identifier fields
    var bundle_identifiers: [String]?
    var description: String?
}
