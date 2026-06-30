//
//  Alarms.swift
//  SmartAlarm
//
//  Created by Jonas Wahringer on 30.06.26.
//

import Foundation
import AlarmKit
import SwiftUI
import ActivityKit

public func authorize() async throws -> Bool {
    switch try await AlarmManager.shared.requestAuthorization() {
    case .notDetermined:
        return try await authorize()
    case .authorized:
        return true
    case .denied:
        return false
    @unknown default:
        throw RuntimeError("FUck you!")
    }
}

public enum AlarmType {
    case sleep, custom
}

public enum TimePeriod : CustomStringConvertible{
    case AM, PM
    
    public var description: String {
        switch (self) {
            case .AM: return "AM"
            case .PM: return "PM"
        }
    }
    
}

public struct AlarmModel: Hashable, Identifiable {
    public var id: UUID
    var name: String
    var type: AlarmType
    var selectedSound: String?
    var hour: Int
    var minute: Int
    var period: TimePeriod
    var pushable: Bool = false
    var active: Bool = false
    var weekdays: Optional<[Locale.Weekday]>
    func time() -> String {
        return hour.formatted() + ":" + minute.formatted()
    }
}

struct Metadata: AlarmMetadata {}


public func schedule(alarm: AlarmModel) async throws -> Bool {
    
    if(try await authorize()) {return false}
    
    let schedule: Alarm.Schedule
    
    if(alarm.weekdays != nil) {
        let date: Date = Date.now // temp
        schedule = Alarm.Schedule.fixed(date)
    } else {
        schedule = Alarm.Schedule.relative(
            Alarm.Schedule.Relative(
                time: Alarm.Schedule.Relative.Time(hour: alarm.hour, minute: alarm.minute),
                repeats: Alarm.Schedule.Relative.Recurrence.weekly(alarm.weekdays!)
            )
        )
    }
                
    let stopButton = AlarmButton(
        text: LocalizedStringResource(stringLiteral: "Stop"),
        textColor: .red,
        systemImageName: "checkmark.seal.fill"
    )
    
    var pushToNextStageButton: Optional<AlarmButton> = nil
    if (alarm.pushable) {
        pushToNextStageButton = AlarmButton(
            text: LocalizedStringResource(stringLiteral: "Push"),
            textColor: .orange,
            systemImageName: "repeat.circle.fill"
        )
    }
    
    let alertPresentation = AlarmPresentation.Alert(
        title: LocalizedStringResource(stringLiteral: alarm.name),
        stopButton: stopButton,
        secondaryButton: pushToNextStageButton,
        secondaryButtonBehavior: .countdown
    )
    
    let presentation = AlarmPresentation(
        alert: alertPresentation
    )
    
    let attributes = AlarmAttributes(
        presentation: presentation,
        metadata: Metadata(),
        tintColor: .black
    )
    
    // Configure sound with detailed logging
    let soundConfig: AlertConfiguration.AlertSound
    if let selectedSoundName = alarm.selectedSound {
        // Verify the sound file exists
        if let soundURL = Bundle.main.url(forResource: selectedSoundName, withExtension: "mp3") {
            soundConfig = AlertConfiguration.AlertSound.named(selectedSoundName)
            print("🔊 Using custom sound: \(selectedSoundName) (found at \(soundURL))")
        } else {
            soundConfig = .default
            print("⚠️ Custom sound \(selectedSoundName).mp3 not found in bundle, using default")
        }
    } else {
        soundConfig = .default
        print("🔊 Using default sound")
    }
    
    let alarmConfiguration = AlarmManager.AlarmConfiguration(
        schedule: schedule,
        attributes: attributes,
        secondaryIntent: nil,
        sound: soundConfig
    )
    
    print("🚀 Scheduling alarm with ID: \(alarm.id)")
    let scheduledAlarm = try await AlarmManager.shared.schedule(id: alarm.id, configuration: alarmConfiguration)
    print("✅ Successfully scheduled alarm: \(scheduledAlarm)")
    
    return true
    
}
