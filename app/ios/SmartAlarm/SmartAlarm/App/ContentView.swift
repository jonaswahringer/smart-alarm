//
//  ContentView.swift
//  SmartAlarm
//
//  Created by Jonas Wahringer on 30.06.26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Home(alarms: [
            AlarmModel(
                id: UUID.init(uuidString: "E333E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
                name: "Unter der Woche",
                type: .sleep,
                hour: 1,
                minute: 0,
                period: .AM,
                pushable: true,
                weekdays: [Locale.Weekday.monday, Locale.Weekday.tuesday, Locale.Weekday.wednesday, Locale.Weekday.thursday, Locale.Weekday.friday]
            ),
            AlarmModel(
                id: UUID.init(uuidString: "E333E2F8-C36C-495A-93FC-0C247A3E6E5F")!,
                name: "Wochenende",
                type: .sleep,
                hour: 1,
                minute: 15,
                period: .AM,
                pushable: true,
                weekdays: [Locale.Weekday.saturday, Locale.Weekday.sunday]
            ),
        ])
            .colorScheme(ColorScheme.light)
        .padding()
    }
}

#Preview {
    ContentView()
}
