import Foundation

enum AlarmKind: String, CaseIterable, Codable, Sendable, Hashable {
    case sleep
    case custom

    var title: String {
        switch self {
        case .sleep: "Sleep"
        case .custom: "Custom"
        }
    }

    var systemImage: String {
        switch self {
        case .sleep: "moon.stars.fill"
        case .custom: "alarm.fill"
        }
    }
}

enum Weekday: Int, CaseIterable, Codable, Hashable, Sendable {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday

    var shortLabel: String {
        switch self {
        case .monday: "M"
        case .tuesday: "T"
        case .wednesday: "W"
        case .thursday: "T"
        case .friday: "F"
        case .saturday: "S"
        case .sunday: "S"
        }
    }

    var fullLabel: String {
        switch self {
        case .monday: "Monday"
        case .tuesday: "Tuesday"
        case .wednesday: "Wednesday"
        case .thursday: "Thursday"
        case .friday: "Friday"
        case .saturday: "Saturday"
        case .sunday: "Sunday"
        }
    }
}

enum AlarmSound: String, CaseIterable, Codable, Sendable, Hashable {
    case dawn
    case gentle
    case chime
    case pulse

    var label: String {
        switch self {
        case .dawn: "Dawn"
        case .gentle: "Gentle Rise"
        case .chime: "Crystal Chime"
        case .pulse: "Soft Pulse"
        }
    }
}

struct SleepWindow: Equatable, Codable, Sendable, Hashable {
    var optimalHours: Int
    var minimumHours: Int
    var fallbackTime: DateComponents

    static let defaultWindow = SleepWindow(
        optimalHours: 8,
        minimumHours: 7,
        fallbackTime: DateComponents(hour: 7, minute: 30)
    )

    static let hoursRange = 4...12

    var isValid: Bool {
        SleepWindow.hoursRange.contains(optimalHours)
            && SleepWindow.hoursRange.contains(minimumHours)
            && minimumHours <= optimalHours
            && fallbackTime.hour != nil
            && fallbackTime.minute != nil
    }

    func clamped() -> SleepWindow {
        let clampedOptimal = min(max(optimalHours, SleepWindow.hoursRange.lowerBound), SleepWindow.hoursRange.upperBound)
        let clampedMinimum = min(
            max(minimumHours, SleepWindow.hoursRange.lowerBound),
            clampedOptimal
        )
        return SleepWindow(
            optimalHours: clampedOptimal,
            minimumHours: clampedMinimum,
            fallbackTime: fallbackTime
        )
    }

    var durationSummary: String {
        "\(minimumHours)–\(optimalHours)h sleep"
    }
}

struct Alarm: Identifiable, Equatable, Codable, Sendable, Hashable {
    var id: UUID
    var kind: AlarmKind
    var label: String
    var isEnabled: Bool
    var repeatDays: Set<Weekday>
    var sound: AlarmSound
    var time: DateComponents?
    var sleepWindow: SleepWindow?

    init(
        id: UUID = UUID(),
        kind: AlarmKind,
        label: String,
        isEnabled: Bool = true,
        repeatDays: Set<Weekday> = Set(Weekday.allCases),
        sound: AlarmSound = .gentle,
        time: DateComponents? = nil,
        sleepWindow: SleepWindow? = nil
    ) {
        self.id = id
        self.kind = kind
        self.label = label
        self.isEnabled = isEnabled
        self.repeatDays = repeatDays
        self.sound = sound
        self.time = time
        self.sleepWindow = sleepWindow
    }

    static func customDefault() -> Alarm {
        Alarm(
            kind: .custom,
            label: "New Alarm",
            time: DateComponents(hour: 7, minute: 0)
        )
    }

    static func sleepDefault() -> Alarm {
        Alarm(
            kind: .sleep,
            label: "Morning Rise",
            sleepWindow: .defaultWindow
        )
    }

    var displayTime: DateComponents {
        switch kind {
        case .custom:
            time ?? DateComponents(hour: 7, minute: 0)
        case .sleep:
            sleepWindow?.fallbackTime ?? DateComponents(hour: 7, minute: 30)
        }
    }

    var repeatSummary: String {
        if repeatDays.count == Weekday.allCases.count {
            return "Every day"
        }
        if repeatDays.isEmpty {
            return "Once"
        }
        let ordered = Weekday.allCases.filter { repeatDays.contains($0) }
        return ordered.map(\.shortLabel).joined(separator: " ")
    }

    var windowSummary: String? {
        guard kind == .sleep, let window = sleepWindow else { return nil }
        return "\(window.durationSummary) · up by \(window.fallbackTime.formattedTime)"
    }

    var sleepHoursLabel: String? {
        guard kind == .sleep, let window = sleepWindow else { return nil }
        return "\(window.optimalHours)h"
    }
}

extension DateComponents {
    var totalMinutes: Int? {
        guard let hour, let minute else { return nil }
        return hour * 60 + minute
    }

    static func fromTotalMinutes(_ total: Int) -> DateComponents {
        let normalized = ((total % (24 * 60)) + (24 * 60)) % (24 * 60)
        return DateComponents(hour: normalized / 60, minute: normalized % 60)
    }

    var formattedTime: String {
        guard let hour, let minute else { return "--:--" }
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let calendar = Calendar.current
        guard let date = calendar.date(from: components) else { return "--:--" }
        return date.formatted(date: .omitted, time: .shortened)
    }

    func date(on reference: Date = .now) -> Date? {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: reference)
        components.hour = hour
        components.minute = minute
        components.second = 0
        return Calendar.current.date(from: components)
    }
}
