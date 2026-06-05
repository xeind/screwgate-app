import Foundation

struct KeyCodeMap {
    // MARK: - Common keys for the action picker

    static let commonKeys: [String] = [
        // Letters
        "a","b","c","d","e","f","g","h","i","j","k","l","m",
        "n","o","p","q","r","s","t","u","v","w","x","y","z",
        // Numbers
        "1","2","3","4","5","6","7","8","9","0",
        // Arrows
        "up_arrow","down_arrow","left_arrow","right_arrow",
        // Function keys
        "f1","f2","f3","f4","f5","f6","f7","f8","f9","f10","f11","f12",
        "f13","f14","f15","f16","f17","f18","f19","f20",
        // Editing
        "return_or_enter","escape","delete_or_backspace","delete_forward",
        "tab","spacebar",
        // Navigation
        "home","end","page_up","page_down","insert",
        // Symbols
        "hyphen","equal_sign","open_bracket","close_bracket","backslash",
        "semicolon","quote","grave_accent_and_tilde","comma","period","slash",
    ]

    // MARK: - macOS virtual key code → Karabiner key_code

    // Reference: https://karabiner-elements.pqrs.org/docs/json/locale/
    private static let vkToKarabiner: [UInt16: String] = [
        0:   "a",           1:  "s",           2:  "d",           3:  "f",
        4:   "h",           5:  "g",           6:  "z",           7:  "x",
        8:   "c",           9:  "v",           11: "b",           12: "q",
        13:  "w",           14: "e",           15: "r",           16: "y",
        17:  "t",           18: "1",           19: "2",           20: "3",
        21:  "4",           22: "6",           23: "5",           24: "equal_sign",
        25:  "9",           26: "7",           27: "hyphen",      28: "8",
        29:  "0",           30: "close_bracket",31:"o",           32: "u",
        33:  "open_bracket",34: "i",           35: "p",           36: "return_or_enter",
        37:  "l",           38: "j",           39: "quote",       40: "k",
        41:  "semicolon",   42: "backslash",   43: "comma",       44: "slash",
        45:  "n",           46: "m",           47: "period",      48: "tab",
        49:  "spacebar",    50: "grave_accent_and_tilde",
        51:  "delete_or_backspace",            53: "escape",
        96:  "f5",          97: "f6",          98: "f7",          99: "f3",
        100: "f8",          101:"f9",          103:"f11",         105:"f13",
        107: "f14",         109:"f10",         111:"f12",         113:"f15",
        114: "insert",      115:"home",        116:"page_up",     117:"delete_forward",
        118: "f4",          119:"end",         120:"f2",          121:"page_down",
        122: "f1",          123:"left_arrow",  124:"right_arrow", 125:"down_arrow",
        126: "up_arrow",
    ]

    static func karabinerCode(for keyCode: UInt16) -> String? {
        vkToKarabiner[keyCode]
    }
}
