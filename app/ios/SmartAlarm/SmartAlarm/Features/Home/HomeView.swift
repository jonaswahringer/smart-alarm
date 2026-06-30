//
//  HomeView.swift
//  SmartAlarm
//
//  Created by Jonas Wahringer on 30.06.26.
//

import SwiftUI


struct Home: View {
    
    @State private var alarms: [AlarmModel] = []
    @State private var isPresentingEdit = false
    @State private var isPresentingNew = false
    @State private var isPresentingDetail = false
    
    private var sleepAlarms: [AlarmModel] {
        alarms.filter { $0.type == .sleep }
    }
    
    private var customAlarms: [AlarmModel] {
        alarms.filter { $0.type == .custom }
    }
    
    // Add this explicit initializer right here:
    init(alarms: [AlarmModel] = []) {
        // We use State(initialValue:) to assign values to a State variable inside an init
        _alarms = State(initialValue: alarms)
    }
    
    var body: some View {
        
        TabView {
            NavigationStack {
                ZStack {
                    List {
                        ForEach(alarms.indices, id: \.self) { index in
                            AlarmRowView(alarm: $alarms[index])
                        }
                        .onDelete(perform: deleteAlarm)
                        .onSubmit(updateAlarm)
                    }
                    .listStyle(.plain) // Removes default padding and backgrounds
                }
                .navigationTitle("Alarms")
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Edit") {
                                isPresentingEdit = true
                            }
                                .foregroundColor(.orange) // Official color
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: { isPresentingNew = true }) {
                                Image(systemName: "plus")
                            }
                            .foregroundColor(.orange)
                        }
                    }
            }.tabItem {
                Image.init(systemName: "alarm")
            }
            NavigationStack {
                List {
                    SmartText(_: "Settings")
                    SmartText(_: "Pizza")
                    SmartText(_: "Andere Pizza")
                }
            }.tabItem {
                Image.init(systemName: "gear")
            }
        }
        .colorScheme(.dark)
    
    }
    
    func updateAlarm() {
        isPresentingDetail = true
    }
    
    func deleteAlarm(at offsets: IndexSet) {
        offsets.forEach { i in
            alarms.remove(at: i)
        }
    }
    
}


#Preview {
    var mockAlarms: [AlarmModel] = ([
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
        AlarmModel(
            id: UUID.init(uuidString: "F999E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            name: "Dings ned vagessn",
            type: .custom,
            hour: 2,
            minute: 0,
            period: .PM,
            pushable: true,
            weekdays: [Locale.Weekday.thursday, Locale.Weekday.friday]
        
        ),
        AlarmModel(
            id: UUID.init(uuidString: "F999E2F8-C36C-495A-93FC-0C247A3E6E5F")!,
            name: "Ajo, Dings ned vagessn",
            type: .custom,
            hour: 2,
            minute: 30,
            period: .PM,
            pushable: true,
            weekdays: [Locale.Weekday.thursday, Locale.Weekday.friday]
        
        ),
        AlarmModel(
            id: UUID.init(uuidString: "F999E3F8-C36C-495A-93FC-0C247A3E6E5F")!,
            name: "Ajoooo, und, Dings ned vagessn",
            type: .custom,
            hour: 3,
            minute: 0,
            period: .PM,
            pushable: true,
            weekdays: [Locale.Weekday.thursday, Locale.Weekday.friday]
        
        ),
        AlarmModel(
            id: UUID.init(uuidString: "F999E4F8-C36C-495A-93FC-0C247A3E6E5F")!,
            name: "Fertig mochn",
            type: .custom,
            hour: 4,
            minute: 0,
            period: .PM,
            pushable: true,
            weekdays: [Locale.Weekday.thursday, Locale.Weekday.friday]
        
        ),
        AlarmModel(
            id: UUID.init(uuidString: "F999E5F8-C36C-495A-93FC-0C247A3E6E5F")!,
            name: "Abfahrt!",
            type: .custom,
            hour: 5,
            minute: 0,
            period: .PM,
            pushable: true,
            weekdays: [Locale.Weekday.thursday, Locale.Weekday.friday]
        
        ),
    ])
    Home(alarms: mockAlarms)
}
