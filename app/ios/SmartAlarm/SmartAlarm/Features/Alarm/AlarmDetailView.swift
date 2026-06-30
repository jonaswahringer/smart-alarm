//
//  AlarmView.swift
//  SmartAlarm
//
//  Created by Jonas Wahringer on 30.06.26.
//

import SwiftUI

struct AlarmDetailView: View {
    
    @State var date = Date()
    @State var alarm: AlarmModel
    
    init(alarm: AlarmModel) {
        self.alarm = alarm
    }
    
    var body: some View {
        VStack {
            DatePicker("Select Date", selection: $date)
                .datePickerStyle(.wheel)
        }
    }
}

#Preview {
    let alarm = AlarmModel(
        id: UUID.init(uuidString: "test")!,
        name: "Test",
        type: .sleep,
        hour: 1,
        minute: 0,
        period: .AM,
        pushable: true,
        weekdays: [Locale.Weekday.thursday, Locale.Weekday.friday]
    )
    AlarmDetailView(alarm: alarm)
}
