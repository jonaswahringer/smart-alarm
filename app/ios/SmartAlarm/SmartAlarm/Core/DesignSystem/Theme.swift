import SwiftUI

enum Theme {
    static let sleepAccent = Color(red: 0.55, green: 0.62, blue: 0.98)
    static let sleepGlow = Color(red: 0.35, green: 0.42, blue: 0.85)
    static let customAccent = Color(red: 1.0, green: 0.62, blue: 0.38)
    static let customGlow = Color(red: 0.92, green: 0.45, blue: 0.28)

    static let backgroundTop = Color(red: 0.08, green: 0.07, blue: 0.16)
    static let backgroundBottom = Color(red: 0.02, green: 0.02, blue: 0.05)
    static let textPrimary = Color.white.opacity(0.95)
    static let textSecondary = Color.white.opacity(0.62)
    static let textTertiary = Color.white.opacity(0.38)

    static let cardStroke = Color.white.opacity(0.12)
    static let cardFill = Color.white.opacity(0.06)

    static let cornerRadiusLarge: CGFloat = 24
    static let cornerRadiusMedium: CGFloat = 16
    static let cornerRadiusSmall: CGFloat = 12

    static let horizontalPadding: CGFloat = 20
    static let sectionSpacing: CGFloat = 28
    static let rowSpacing: CGFloat = 12

    static var nocturnalBackground: some View {
        ZStack {
            LinearGradient(
                colors: [backgroundTop, Color(red: 0.12, green: 0.08, blue: 0.22), backgroundBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [sleepGlow.opacity(0.18), .clear],
                center: .topLeading,
                startRadius: 20,
                endRadius: 420
            )

            RadialGradient(
                colors: [customGlow.opacity(0.10), .clear],
                center: .bottomTrailing,
                startRadius: 10,
                endRadius: 360
            )

            StarField()
                .opacity(0.35)
        }
        .ignoresSafeArea()
    }

    static func accent(for kind: AlarmKind) -> Color {
        kind == .sleep ? sleepAccent : customAccent
    }

    static func glow(for kind: AlarmKind) -> Color {
        kind == .sleep ? sleepGlow : customGlow
    }
}

private struct StarField: View {
    var body: some View {
        Canvas { context, size in
            var rng = SeededRandom(seed: 42)
            for _ in 0..<80 {
                let x = rng.next(in: 0...size.width)
                let y = rng.next(in: 0...size.height)
                let radius = rng.next(in: 0.4...1.4)
                let opacity = rng.next(in: 0.15...0.55)
                let rect = CGRect(x: x, y: y, width: radius, height: radius)
                context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(opacity)))
            }
        }
        .allowsHitTesting(false)
    }
}

private struct SeededRandom {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next(in range: ClosedRange<CGFloat>) -> CGFloat {
        state = 6364136223846793005 &* state &+ 1
        let normalized = Double(state % 10_000) / 10_000.0
        return range.lowerBound + CGFloat(normalized) * (range.upperBound - range.lowerBound)
    }
}

struct NocturnalBackground: View {
    var body: some View {
        Theme.nocturnalBackground
    }
}
