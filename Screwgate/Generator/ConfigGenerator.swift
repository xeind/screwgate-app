import Foundation

struct ConfigGenerator {

    static func generate(hyperKey: HyperKey, layers: [Layer], sublayers: [Sublayer]) -> KarabinerConfig {
        var rules: [Rule] = []

        // 1. Hyper key activation — variable approach (matches mxstbr's method)
        //    Held  → set hyper=1, tapped alone → Escape
        rules.append(makeHyperRule(hyperKey: hyperKey))

        // 2. Direct (flat) bindings — Hyper + key directly, no sublayer needed
        rules += layers.map { makeFlatRule($0) }

        // 3. Sublayer activation + per-binding rules
        for sublayer in sublayers {
            rules.append(makeSubActivationRule(sublayer, allSublayers: sublayers))
            rules += sublayer.bindings.map { makeBindingRule($0, sublayer: sublayer) }
        }

        let profile = Profile(
            name: "Screwgate",
            selected: true,
            complex_modifications: ComplexModifications(rules: rules)
        )

        return KarabinerConfig(profiles: [profile])
    }

    // MARK: - Hyper key rule (variable-based)

    private static func makeHyperRule(hyperKey: HyperKey) -> Rule {
        let manipulator = Manipulator(
            from: FromKey(key_code: hyperKey.rawValue, modifiers: KeyModifiers(optional: ["any"])),
            to:             [ToKey(set_variable: SetVariable(name: "hyper", value: 1))],
            to_if_alone:    [ToKey(key_code: "escape")],
            to_after_key_up: [ToKey(set_variable: SetVariable(name: "hyper", value: 0))]
        )
        return Rule(
            description: "Hyper Key — \(hyperKey.displayName) (tap: Escape)",
            manipulators: [manipulator]
        )
    }

    // MARK: - Flat / direct binding (Hyper + key → action)

    private static func makeFlatRule(_ layer: Layer) -> Rule {
        let manipulator = Manipulator(
            from: FromKey(key_code: layer.triggerKey, modifiers: KeyModifiers(optional: ["any"])),
            to: [toKey(for: layer.actionType, value: layer.actionValue, modifiers: layer.actionModifiers)],
            conditions: [.init(type: "variable_if", name: "hyper", value: 1)]
        )
        return Rule(description: layer.layerDescription, manipulators: [manipulator])
    }

    // MARK: - Sublayer activation rule

    private static func makeSubActivationRule(_ sublayer: Sublayer, allSublayers: [Sublayer]) -> Rule {
        // All OTHER sublayers must be inactive (value=0), and hyper must be active (value=1)
        var conditions: [Condition] = allSublayers
            .filter { $0.id != sublayer.id }
            .map { Condition(type: "variable_if", name: $0.variableName, value: 0) }
        conditions.append(Condition(type: "variable_if", name: "hyper", value: 1))

        let manipulator = Manipulator(
            from: FromKey(key_code: sublayer.key, modifiers: KeyModifiers(optional: ["any"])),
            to:              [ToKey(set_variable: SetVariable(name: sublayer.variableName, value: 1))],
            to_after_key_up: [ToKey(set_variable: SetVariable(name: sublayer.variableName, value: 0))],
            conditions: conditions
        )
        return Rule(
            description: "Hyper Key sublayer \"\(sublayer.key)\" — \(sublayer.name)",
            manipulators: [manipulator]
        )
    }

    // MARK: - Sublayer binding rule

    private static func makeBindingRule(_ binding: KeyBinding, sublayer: Sublayer) -> Rule {
        let manipulator = Manipulator(
            from: FromKey(key_code: binding.triggerKey, modifiers: KeyModifiers(optional: ["any"])),
            to: [toKey(for: binding.actionType, value: binding.actionValue, modifiers: binding.actionModifiers)],
            conditions: [Condition(type: "variable_if", name: sublayer.variableName, value: 1)]
        )
        return Rule(description: binding.bindingDescription, manipulators: [manipulator])
    }

    // MARK: - ToKey factory

    private static func toKey(for actionType: ActionType, value: String, modifiers: [String]) -> ToKey {
        switch actionType {
        case .keyPress:
            return ToKey(key_code: value, modifiers: modifiers.isEmpty ? nil : modifiers)
        case .url:
            let escaped = value.replacingOccurrences(of: "'", with: "'\\''")
            return ToKey(shell_command: "open '\(escaped)'")
        case .openApp:
            let escaped = value.replacingOccurrences(of: "'", with: "'\\''")
            return ToKey(shell_command: "open -a '\(escaped)'")
        case .shellCommand:
            return ToKey(shell_command: value)
        }
    }
}
