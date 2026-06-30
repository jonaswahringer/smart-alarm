import SwiftUI

struct WeekdayPicker: View {
    @Binding var selection: Set<Weekday>
    var isEditable: Bool

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Weekday.allCases, id: \.self) { day in
                let isSelected = selection.contains(day)

                Button {
                    guard isEditable else { return }
                    if isSelected {
                        selection.remove(day)
                    } else {
                        selection.insert(day)
                    }
                } label: {
                    Text(day.shortLabel)
                        .font(.subheadline.weight(.semibold))
                        .frame(width: 36, height: 36)
                        .foregroundStyle(isSelected ? Color.black.opacity(0.85) : Theme.textSecondary)
                        .background {
                            Circle()
                                .fill(isSelected ? Theme.sleepAccent : Theme.cardFill)
                        }
                        .overlay {
                            Circle()
                                .strokeBorder(Theme.cardStroke.opacity(isSelected ? 0 : 0.6), lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
                .disabled(!isEditable)
                .opacity(isEditable || isSelected ? 1 : 0.35)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    WeekdayPicker(
        selection: .constant([.monday, .wednesday, .friday]),
        isEditable: true
    )
    .padding()
    .background(NocturnalBackground())
}
