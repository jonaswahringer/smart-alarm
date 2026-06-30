import SwiftUI

enum HomeFilter: String, CaseIterable, Identifiable {
    case all
    case sleep
    case custom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: "All"
        case .sleep: "Sleep"
        case .custom: "Custom"
        }
    }

    var kind: AlarmKind? {
        switch self {
        case .all: nil
        case .sleep: .sleep
        case .custom: .custom
        }
    }
}

struct HomeView: View {
    @Environment(MockAlarmStore.self) private var store
    @Namespace private var filterNamespace
    @Namespace private var zoomNamespace

    @State private var filter: HomeFilter = .all
    @State private var navigationPath = NavigationPath()
    @State private var editorMode: EditorMode?
    @State private var appeared = false

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                NocturnalBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.sectionSpacing) {
                        header
                        filterBar
                        alarmSections
                    }
                    .padding(.horizontal, Theme.horizontalPadding)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
            .navigationDestination(for: UUID.self) { alarmID in
                AlarmDetailDestination(
                    alarmID: alarmID,
                    zoomNamespace: zoomNamespace,
                    onSave: handleSave,
                    onDelete: handleDelete,
                    onDismiss: popDetail
                )
            }
            .navigationDestination(item: $editorMode) { mode in
                AlarmEditorView(
                    mode: mode,
                    onSave: handleSave,
                    onDelete: handleDelete,
                    onDismiss: { editorMode = nil }
                )
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            editorMode = .create(.sleep)
                        } label: {
                            Label("Sleep Alarm", systemImage: AlarmKind.sleep.systemImage)
                        }

                        Button {
                            editorMode = .create(.custom)
                        } label: {
                            Label("Custom Alarm", systemImage: AlarmKind.custom.systemImage)
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Theme.sleepAccent)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) {
                appeared = true
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Smart Alarm")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(Theme.textPrimary)

            Text("Sleep windows and custom alarms, side by side.")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .animation(.easeOut(duration: 0.55).delay(0.05), value: appeared)
    }

    private var filterBar: some View {
        HStack(spacing: 8) {
            ForEach(HomeFilter.allCases) { item in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                        filter = item
                    }
                } label: {
                    FilterPill(title: item.title, isSelected: filter == item, namespace: filterNamespace)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background {
            if #available(iOS 26.0, *) {
                Capsule()
                    .fill(.clear)
                    .glassEffect(.regular, in: Capsule())
            } else {
                Capsule().fill(Theme.cardFill)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.55).delay(0.12), value: appeared)
    }

    @ViewBuilder
    private var alarmSections: some View {
        if filter == .all || filter == .sleep {
            sleepSection
        }
        if filter == .all || filter == .custom {
            customSection
        }
    }

    private var sleepSection: some View {
        VStack(alignment: .leading, spacing: Theme.rowSpacing) {
            SectionHeader(title: "Sleep", count: store.sleepAlarms.count, kind: .sleep)

            if store.sleepAlarms.isEmpty {
                EmptySectionCard(kind: .sleep)
            } else {
                ForEach(Array(store.sleepAlarms.enumerated()), id: \.element.id) { index, alarm in
                    alarmRow(alarm, index: index)
                }
            }
        }
    }

    private var customSection: some View {
        VStack(alignment: .leading, spacing: Theme.rowSpacing) {
            SectionHeader(title: "Custom", count: store.customAlarms.count, kind: .custom)

            if store.customAlarms.isEmpty {
                EmptySectionCard(kind: .custom)
            } else {
                ForEach(Array(store.customAlarms.enumerated()), id: \.element.id) { index, alarm in
                    alarmRow(alarm, index: index + store.sleepAlarms.count)
                }
            }
        }
    }

    private func alarmRow(_ alarm: Alarm, index: Int) -> some View {
        AlarmRowView(
            alarm: alarm,
            onToggle: { store.toggleEnabled(for: alarm) }
        )
        .matchedTransitionSource(id: alarm.id, in: zoomNamespace)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
        .animation(.spring(response: 0.55, dampingFraction: 0.84).delay(0.08 + Double(index) * 0.05), value: appeared)
        .scrollTransition { content, phase in
            content
                .opacity(phase.isIdentity ? 1 : 0.7)
                .scaleEffect(phase.isIdentity ? 1 : 0.97)
        }
    }

    private func handleSave(_ alarm: Alarm) {
        if store.alarms.contains(where: { $0.id == alarm.id }) {
            store.update(alarm)
        } else {
            store.add(alarm)
        }
        editorMode = nil
        popDetail()
    }

    private func handleDelete(_ alarm: Alarm) {
        store.delete(alarm)
        editorMode = nil
        popDetail()
    }

    private func popDetail() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
}

private struct AlarmDetailDestination: View {
    @Environment(MockAlarmStore.self) private var store

    let alarmID: UUID
    let zoomNamespace: Namespace.ID
    let onSave: (Alarm) -> Void
    let onDelete: (Alarm) -> Void
    let onDismiss: () -> Void

    var body: some View {
        if let alarm = store.alarms.first(where: { $0.id == alarmID }) {
            AlarmEditorView(
                mode: .view(alarm),
                onSave: onSave,
                onDelete: onDelete,
                onDismiss: onDismiss
            )
            .navigationTransition(.zoom(sourceID: alarmID, in: zoomNamespace))
        } else {
            ContentUnavailableView("Alarm Not Found", systemImage: "alarm")
                .onAppear(perform: onDismiss)
        }
    }
}

#Preview {
    HomeView()
        .environment(MockAlarmStore())
}
