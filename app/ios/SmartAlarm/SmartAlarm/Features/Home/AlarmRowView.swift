import SwiftUI

struct AlarmRowView: View {
    let alarm: Alarm
    let onToggle: () -> Void

    var body: some View {
        GlassCard(kind: alarm.kind) {
            HStack(alignment: .center, spacing: 14) {
                NavigationLink(value: alarm.id) {
                    AlarmRowLabel(alarm: alarm)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)

                Toggle("", isOn: Binding(
                    get: { alarm.isEnabled },
                    set: { _ in onToggle() }
                ))
                .labelsHidden()
                .tint(Theme.accent(for: alarm.kind))
            }
        }
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(Theme.accent(for: alarm.kind))
                .frame(width: 3)
                .padding(.vertical, 10)
                .padding(.leading, 2)
                .opacity(alarm.isEnabled ? 1 : 0.25)
        }
        .opacity(alarm.isEnabled ? 1 : 0.72)
    }
}

struct AlarmRowLabel: View {
    let alarm: Alarm

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(alarm.label)
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)

                if alarm.kind == .sleep {
                    Image(systemName: "sparkles")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.sleepAccent)
                        .symbolEffect(.pulse, options: .repeating, isActive: alarm.isEnabled)
                }
            }

            if alarm.kind == .sleep, let hours = alarm.sleepHoursLabel {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(hours)
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                    Text("optimal")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.textSecondary)
                }
            } else {
                TimeText(components: alarm.displayTime, size: 34)
            }

            if let windowSummary = alarm.windowSummary {
                Text(windowSummary)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Theme.textSecondary)
            }

            Text(alarm.repeatSummary)
                .font(.caption)
                .foregroundStyle(Theme.textTertiary)
        }
    }
}

#Preview {
    NavigationStack {
        ZStack {
            NocturnalBackground()
            VStack(spacing: 12) {
                AlarmRowView(alarm: MockAlarmStore.sampleAlarms[0], onToggle: {})
                AlarmRowView(alarm: MockAlarmStore.sampleAlarms[2], onToggle: {})
            }
            .padding()
        }
        .navigationDestination(for: UUID.self) { _ in
            Text("Detail")
        }
    }
    .environment(MockAlarmStore())
}
