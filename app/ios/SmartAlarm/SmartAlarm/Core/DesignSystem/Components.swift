import SwiftUI

struct GlassCard<Content: View>: View {
    var kind: AlarmKind?
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(16)
            .background {
                cardBackground
            }
            .overlay {
                RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium, style: .continuous)
                    .strokeBorder(Theme.cardStroke, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium, style: .continuous))
    }

    @ViewBuilder
    private var cardBackground: some View {
        if #available(iOS 26.0, *) {
            RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium, style: .continuous)
                .fill(.clear)
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium, style: .continuous))
        } else {
            RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium, style: .continuous)
                .fill(Theme.cardFill)
                .background {
                    if let kind {
                        RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium, style: .continuous)
                            .fill(Theme.glow(for: kind).opacity(0.12))
                            .blur(radius: 18)
                    }
                }
        }
    }
}

struct TimeText: View {
    let components: DateComponents
    var size: CGFloat = 42
    var weight: Font.Weight = .semibold

    var body: some View {
        Text(components.formattedTime)
            .font(.system(size: size, weight: weight, design: .rounded))
            .monospacedDigit()
            .contentTransition(.numericText())
            .foregroundStyle(Theme.textPrimary)
    }
}

struct GlowButton: View {
    let title: String
    var kind: AlarmKind = .sleep
    var role: ButtonRole?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .contentShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall, style: .continuous))
        }
        .buttonStyle(GlowButtonStyle(kind: kind, isDestructive: role == .destructive))
    }
}

private struct GlowButtonStyle: ButtonStyle {
    var kind: AlarmKind
    var isDestructive: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isDestructive ? Color.red.opacity(0.95) : Color.black.opacity(0.88))
            .background {
                RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall, style: .continuous)
                    .fill(isDestructive ? Color.red.opacity(0.18) : Theme.accent(for: kind))
                    .shadow(color: Theme.glow(for: kind).opacity(configuration.isPressed ? 0.15 : 0.45), radius: 16, y: 6)
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.72), value: configuration.isPressed)
    }
}

struct SectionHeader: View {
    let title: String
    let count: Int
    var kind: AlarmKind

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Label(title.uppercased(), systemImage: kind.systemImage)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Theme.accent(for: kind))
                .symbolRenderingMode(.hierarchical)

            Spacer()

            Text("\(count)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.textTertiary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(Theme.cardFill))
        }
    }
}

struct EmptySectionCard: View {
    var kind: AlarmKind

    var body: some View {
        GlassCard(kind: kind) {
            VStack(alignment: .leading, spacing: 8) {
                Text("No \(kind.title.lowercased()) alarms yet")
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)
                Text(kind == .sleep
                     ? "Add a sleep alarm with optimal and minimum hours plus a fallback wake time."
                     : "Add a custom alarm for a fixed wake time.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let namespace: Namespace.ID

    var body: some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(isSelected ? Theme.textPrimary : Theme.textSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background {
                if isSelected {
                    Capsule()
                        .fill(Theme.cardFill)
                        .matchedGeometryEffect(id: "filterPill", in: namespace)
                }
            }
            .overlay {
                Capsule()
                    .strokeBorder(Theme.cardStroke.opacity(isSelected ? 0.8 : 0.3), lineWidth: 1)
            }
    }
}

struct InfoBanner: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(Theme.sleepAccent)
            Text(text)
                .font(.footnote)
                .foregroundStyle(Theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall, style: .continuous)
                .fill(Theme.sleepGlow.opacity(0.12))
        }
    }
}
