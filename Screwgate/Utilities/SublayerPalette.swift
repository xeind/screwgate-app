import SwiftUI

enum SublayerPalette {
    static let colors: [Color] = [
        .indigo, .teal, .orange, .pink, .mint, .purple, .brown, .cyan
    ]

    static func color(at index: Int) -> Color {
        colors[index % colors.count]
    }
}
