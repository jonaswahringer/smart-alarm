import SwiftUI

struct SleepWindowEditor: View {
    @Binding var window: SleepWindow
    var isEditable: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sleep Target")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.textTertiary)

            SleepDurationBar(window: $window, isEditable: isEditable)

            if isEditable {
                editableControls
            } else {
                readOnlySummary
            }

            if !window.isValid {
                Text("Minimum hours must be less than or equal to optimal hours.")
                    .font(.footnote)
                    .foregroundStyle(.orange)
            }
        }
    }

    private var editableControls: some View {
        VStack(spacing: 12) {
            hoursRow(
                title: "Optimal",
                caption: "Target sleep duration",
                value: Binding(
                    get: { window.optimalHours },
                    set: { window.optimalHours = $0; window = window.clamped() }
                ),
                accent: Theme.sleepAccent
            )

            hoursRow(
                title: "Minimum",
                caption: "Shortest acceptable sleep",
                value: Binding(
                    get: { window.minimumHours },
                    set: { window.minimumHours = $0; window = window.clamped() }
                )
            )

            fallbackRow
        }
    }

    private var fallbackRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Fallback")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Latest guaranteed wake time")
                        .font(.caption)
                        .foregroundStyle(Theme.textTertiary)
                }
                Spacer()
                TimeText(components: window.fallbackTime, size: 28)
            }

            DatePicker(
                "Fallback time",
                selection: fallbackTimeBinding,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .tint(Theme.sleepAccent)
        }
        .padding(14)
        .background(fieldBackground)
    }

    private var readOnlySummary: some View {
        VStack(spacing: 10) {
            summaryRow(title: "Optimal", value: "\(window.optimalHours) hours", accent: Theme.sleepAccent)
            summaryRow(title: "Minimum", value: "\(window.minimumHours) hours")
            summaryRow(title: "Fallback", value: window.fallbackTime.formattedTime)
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall, style: .continuous)
                .fill(Theme.cardFill)
        }
    }

    private func hoursRow(
        title: String,
        caption: String,
        value: Binding<Int>,
        accent: Color = Theme.textPrimary
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(accent)
                    Text(caption)
                        .font(.caption)
                        .foregroundStyle(Theme.textTertiary)
                }
                Spacer()
                Text("\(value.wrappedValue)h")
                    .font(.title3.weight(.semibold).monospacedDigit())
                    .foregroundStyle(Theme.textPrimary)
                    .contentTransition(.numericText())
            }

            Stepper("\(title) hours", value: value, in: SleepWindow.hoursRange)
                .labelsHidden()
        }
        .padding(14)
        .background(fieldBackground)
    }

    private func summaryRow(title: String, value: String, accent: Color = Theme.textSecondary) -> some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(accent)
            Spacer()
            Text(value)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Theme.textPrimary)
        }
    }

    private var fallbackTimeBinding: Binding<Date> {
        Binding(
            get: { window.fallbackTime.date() ?? Date() },
            set: { newValue in
                window.fallbackTime = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            }
        )
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall, style: .continuous)
            .fill(Theme.cardFill)
            .overlay {
                RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall, style: .continuous)
                    .strokeBorder(Theme.cardStroke, lineWidth: 1)
            }
    }
}

private struct SleepDurationBar: View {
    @Binding var window: SleepWindow
    var isEditable: Bool

    private let range = SleepWindow.hoursRange
    private let thumbSize: CGFloat = 22

    @State private var activeHandle: Handle?

    private enum Handle {
        case minimum
        case optimal
    }

    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { proxy in
                let width = proxy.size.width
                let span = CGFloat(range.upperBound - range.lowerBound)

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.cardFill)
                        .frame(height: 10)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Theme.sleepGlow.opacity(0.5), Theme.sleepAccent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: barWidth(totalWidth: width, span: span), height: 10)
                        .offset(x: minOffset(totalWidth: width, span: span))

                    thumb(at: window.minimumHours, totalWidth: width, span: span, accent: false)
                    thumb(at: window.optimalHours, totalWidth: width, span: span, accent: true)
                }
                .frame(maxHeight: .infinity, alignment: .center)
                .contentShape(Rectangle())
                .highPriorityGesture(isEditable ? dragGesture(trackWidth: width) : nil)
            }
            .frame(height: 44)

            HStack {
                Text("\(range.lowerBound)h")
                Spacer()
                Text("\(window.minimumHours)–\(window.optimalHours)h")
                    .foregroundStyle(Theme.sleepAccent)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: window.minimumHours)
                    .animation(.snappy, value: window.optimalHours)
                Spacer()
                Text("\(range.upperBound)h")
            }
            .font(.caption2.weight(.medium))
            .foregroundStyle(Theme.textTertiary)
        }
        .padding(.vertical, 4)
    }

    private func minOffset(totalWidth: CGFloat, span: CGFloat) -> CGFloat {
        CGFloat(window.minimumHours - range.lowerBound) / span * totalWidth
    }

    private func barWidth(totalWidth: CGFloat, span: CGFloat) -> CGFloat {
        max(CGFloat(window.optimalHours - window.minimumHours) / span * totalWidth, 8)
    }

    private func thumb(at hours: Int, totalWidth: CGFloat, span: CGFloat, accent: Bool) -> some View {
        let size: CGFloat = accent ? thumbSize : 16
        let offset = CGFloat(hours - range.lowerBound) / span * totalWidth - size / 2

        return Circle()
            .fill(accent ? Color.white : Theme.sleepGlow)
            .frame(width: size, height: size)
            .shadow(color: Theme.sleepAccent.opacity(accent ? 0.6 : 0.3), radius: 6)
            .offset(x: max(offset, -size / 2))
            .allowsHitTesting(false)
    }

    private func dragGesture(trackWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if activeHandle == nil {
                    activeHandle = closestHandle(to: value.startLocation.x, trackWidth: trackWidth)
                }
                switch activeHandle {
                case .minimum:
                    updateMinimumHours(at: value.location.x, trackWidth: trackWidth)
                case .optimal:
                    updateOptimalHours(at: value.location.x, trackWidth: trackWidth)
                case nil:
                    break
                }
            }
            .onEnded { _ in
                activeHandle = nil
            }
    }

    private func closestHandle(to x: CGFloat, trackWidth: CGFloat) -> Handle {
        let span = CGFloat(range.upperBound - range.lowerBound)
        let minimumX = CGFloat(window.minimumHours - range.lowerBound) / span * trackWidth
        let optimalX = CGFloat(window.optimalHours - range.lowerBound) / span * trackWidth
        return abs(x - minimumX) <= abs(x - optimalX) ? .minimum : .optimal
    }

    private func hours(at locationX: CGFloat, trackWidth: CGFloat) -> Int {
        guard trackWidth > 0 else { return range.lowerBound }
        let span = range.upperBound - range.lowerBound
        let fraction = min(max(locationX / trackWidth, 0), 1)
        let raw = range.lowerBound + Int((fraction * CGFloat(span)).rounded())
        return min(max(raw, range.lowerBound), range.upperBound)
    }

    private func updateOptimalHours(at locationX: CGFloat, trackWidth: CGFloat) {
        var updated = window
        updated.optimalHours = max(hours(at: locationX, trackWidth: trackWidth), window.minimumHours)
        window = updated.clamped()
    }

    private func updateMinimumHours(at locationX: CGFloat, trackWidth: CGFloat) {
        var updated = window
        updated.minimumHours = min(hours(at: locationX, trackWidth: trackWidth), window.optimalHours)
        window = updated.clamped()
    }
}

#Preview {
    SleepWindowEditor(
        window: .constant(.defaultWindow),
        isEditable: true
    )
    .padding()
    .background(NocturnalBackground())
}
