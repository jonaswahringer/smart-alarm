import SwiftUI

enum EditorMode: Identifiable, Hashable {
    case create(AlarmKind)
    case view(Alarm)
    case edit(Alarm)

    var id: String {
        switch self {
        case .create(let kind):
            "create-\(kind.rawValue)"
        case .view(let alarm):
            "view-\(alarm.id.uuidString)"
        case .edit(let alarm):
            "edit-\(alarm.id.uuidString)"
        }
    }

    static func == (lhs: EditorMode, rhs: EditorMode) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var navigationTitle: String {
        switch self {
        case .create(let kind):
            "New \(kind.title) Alarm"
        case .view, .edit:
            "Alarm"
        }
    }

    var isCreating: Bool {
        if case .create = self { return true }
        return false
    }
}

struct AlarmEditorView: View {
    let mode: EditorMode
    let onSave: (Alarm) -> Void
    let onDelete: (Alarm) -> Void
    let onDismiss: () -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var draft: Alarm
    @State private var showDeleteConfirmation = false
    @State private var showUnsavedChangesAlert = false

    private let originalAlarm: Alarm

    init(
        mode: EditorMode,
        onSave: @escaping (Alarm) -> Void,
        onDelete: @escaping (Alarm) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.mode = mode
        self.onSave = onSave
        self.onDelete = onDelete
        self.onDismiss = onDismiss

        let initialAlarm: Alarm = switch mode {
        case .create(let kind):
            kind == .sleep ? .sleepDefault() : .customDefault()
        case .view(let alarm), .edit(let alarm):
            alarm
        }

        self.originalAlarm = initialAlarm
        _draft = State(initialValue: initialAlarm)
    }

    private var hasUnsavedChanges: Bool {
        normalized(draft) != normalized(originalAlarm)
    }

    var body: some View {
        ZStack {
            NocturnalBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    labelField
                    timeSection
                    weekdaySection
                    soundSection

                    if draft.kind == .sleep {
                        InfoBanner(text: "Dynamic sleep-stage scheduling is not enabled in this prototype. Hours define your sleep target; fallback is the latest wake time.")
                    }

                    GlowButton(title: "Save", kind: draft.kind) {
                        save()
                    }
                    .disabled(!mode.isCreating && !hasUnsavedChanges)
                    .opacity(mode.isCreating || hasUnsavedChanges ? 1 : 0.45)

                    if !mode.isCreating {
                        GlowButton(title: "Delete", kind: draft.kind, role: .destructive) {
                            showDeleteConfirmation = true
                        }
                    }
                }
                .padding(.horizontal, Theme.horizontalPadding)
                .padding(.vertical, 20)
            }
        }
        .navigationTitle(mode.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(hasUnsavedChanges)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if hasUnsavedChanges {
                    Button {
                        showUnsavedChangesAlert = true
                    } label: {
                        Image(systemName: "chevron.backward")
                            .font(.body.weight(.semibold))
                    }
                }
            }
        }
        .onDisappear {
            if !hasUnsavedChanges {
                onDismiss()
            }
        }
        .alert("Unsaved Changes", isPresented: $showUnsavedChangesAlert) {
            Button("Discard Changes", role: .destructive) {
                discardChanges()
            }
            Button("Save") {
                save()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You have unsaved changes to this alarm.")
        }
        .alert("Delete this alarm?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                onDelete(draft)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This cannot be undone.")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(draft.kind.title, systemImage: draft.kind.systemImage)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.accent(for: draft.kind))

            if draft.kind == .custom {
                TimeText(components: draft.displayTime, size: 56)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var labelField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Label")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.textTertiary)

            TextField("Alarm name", text: $draft.label)
                .textFieldStyle(.plain)
                .padding(14)
                .background(fieldBackground)
        }
    }

    @ViewBuilder
    private var timeSection: some View {
        switch draft.kind {
        case .sleep:
            SleepWindowEditor(
                window: Binding(
                    get: { draft.sleepWindow ?? .defaultWindow },
                    set: { draft.sleepWindow = $0.clamped() }
                ),
                isEditable: true
            )
        case .custom:
            VStack(alignment: .leading, spacing: 8) {
                Text("Time")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.textTertiary)

                DatePicker(
                    "Alarm time",
                    selection: customTimeBinding,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(fieldBackground)
            }
        }
    }

    private var weekdaySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Repeat")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.textTertiary)

            WeekdayPicker(selection: $draft.repeatDays, isEditable: true)
        }
    }

    private var soundSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Sound")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.textTertiary)

            Picker("Sound", selection: $draft.sound) {
                ForEach(AlarmSound.allCases, id: \.self) { sound in
                    Text(sound.label).tag(sound)
                }
            }
            .pickerStyle(.menu)
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(fieldBackground)
        }
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall, style: .continuous)
            .fill(Theme.cardFill)
            .overlay {
                RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall, style: .continuous)
                    .strokeBorder(Theme.cardStroke, lineWidth: 1)
            }
    }

    private var customTimeBinding: Binding<Date> {
        Binding(
            get: {
                draft.time?.date() ?? Date()
            },
            set: { newValue in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                draft.time = components
            }
        )
    }

    private func normalized(_ alarm: Alarm) -> Alarm {
        var copy = alarm
        if copy.kind == .sleep {
            copy.sleepWindow = (copy.sleepWindow ?? .defaultWindow).clamped()
            copy.time = nil
        } else {
            copy.sleepWindow = nil
        }
        return copy
    }

    private func save() {
        draft = normalized(draft)
        onSave(draft)
        dismiss()
    }

    private func discardChanges() {
        onDismiss()
        dismiss()
    }
}

#Preview("Create Sleep") {
    NavigationStack {
        AlarmEditorView(
            mode: .create(.sleep),
            onSave: { _ in },
            onDelete: { _ in },
            onDismiss: {}
        )
    }
}

#Preview("View Custom") {
    NavigationStack {
        AlarmEditorView(
            mode: .view(MockAlarmStore.sampleAlarms[2]),
            onSave: { _ in },
            onDelete: { _ in },
            onDismiss: {}
        )
    }
}
