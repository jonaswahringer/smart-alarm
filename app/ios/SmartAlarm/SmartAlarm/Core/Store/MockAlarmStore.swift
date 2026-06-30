import Foundation
import Observation

@MainActor
@Observable
final class MockAlarmStore {
    private(set) var alarms: [Alarm]

    init(alarms: [Alarm] = MockAlarmStore.sampleAlarms) {
        self.alarms = alarms
    }

    var sleepAlarms: [Alarm] {
        alarms.filter { $0.kind == .sleep }
    }

    var customAlarms: [Alarm] {
        alarms.filter { $0.kind == .custom }
    }

    func alarms(for kind: AlarmKind?) -> [Alarm] {
        guard let kind else { return alarms }
        return alarms.filter { $0.kind == kind }
    }

    func add(_ alarm: Alarm) {
        alarms.append(alarm)
        sortAlarms()
    }

    func update(_ alarm: Alarm) {
        guard let index = alarms.firstIndex(where: { $0.id == alarm.id }) else { return }
        alarms[index] = alarm
        sortAlarms()
    }

    func delete(_ alarm: Alarm) {
        alarms.removeAll { $0.id == alarm.id }
    }

    func toggleEnabled(for alarm: Alarm) {
        guard let index = alarms.firstIndex(where: { $0.id == alarm.id }) else { return }
        alarms[index].isEnabled.toggle()
    }

    private func sortAlarms() {
        alarms.sort { lhs, rhs in
            if lhs.kind != rhs.kind {
                return lhs.kind == .sleep
            }
            let lhsMinutes = lhs.displayTime.totalMinutes ?? 0
            let rhsMinutes = rhs.displayTime.totalMinutes ?? 0
            return lhsMinutes < rhsMinutes
        }
    }

    static let sampleAlarms: [Alarm] = [
        Alarm(
            kind: .sleep,
            label: "Weekday Rise",
            isEnabled: true,
            repeatDays: [.monday, .tuesday, .wednesday, .thursday, .friday],
            sound: .dawn,
            sleepWindow: SleepWindow(
                optimalHours: 8,
                minimumHours: 7,
                fallbackTime: DateComponents(hour: 7, minute: 45)
            )
        ),
        Alarm(
            kind: .sleep,
            label: "Weekend Ease",
            isEnabled: false,
            repeatDays: [.saturday, .sunday],
            sound: .gentle,
            sleepWindow: SleepWindow(
                optimalHours: 9,
                minimumHours: 8,
                fallbackTime: DateComponents(hour: 9, minute: 0)
            )
        ),
        Alarm(
            kind: .custom,
            label: "Gym",
            isEnabled: true,
            repeatDays: [.monday, .wednesday, .friday],
            sound: .pulse,
            time: DateComponents(hour: 6, minute: 0)
        ),
        Alarm(
            kind: .custom,
            label: "Medication",
            isEnabled: true,
            repeatDays: Set(Weekday.allCases),
            sound: .chime,
            time: DateComponents(hour: 9, minute: 0)
        ),
        Alarm(
            kind: .custom,
            label: "Meeting Prep",
            isEnabled: false,
            repeatDays: [.tuesday, .thursday],
            sound: .gentle,
            time: DateComponents(hour: 8, minute: 30)
        )
    ]
}
