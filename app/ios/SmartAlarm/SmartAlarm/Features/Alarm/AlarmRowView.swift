//
//  AlarmRowView.swift
//  SmartAlarm
//
//  Created by Jonas Wahringer on 30.06.26.
//

import SwiftUI

struct AlarmRowView: View {
    
    @Binding var alarm: AlarmModel
    @State private var isOn = false
    
    var body: some View {
            HStack(alignment: .lastTextBaseline) {
                // Time Layout Stack
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(alarm.time())
                        .font(.system(size: 60, weight: .light, design: .default))
                    Text(alarm.period.description)
                        .font(.system(size: 24, weight: .light))
                }
                .opacity(isOn ? 1.0 : 0.65) // Fades text when toggled off

                Spacer()
                
                // Switch Toggle
                Toggle("", isOn: $isOn)
                    .onChange(of: isOn, perform:  { _isOn in
                        alarm.active.toggle()
                    })
                    .labelsHidden()
                    .tint(.green) // Native Apple toggle tint color
            }
            .colorScheme(ColorScheme.dark)
            .padding(.vertical, 4)
            .padding(.horizontal, 16)
            .listRowSeparatorTint(Color(uiColor: .lightGray).opacity(0.3))
            .onSubmit {
                AlarmDetailView(alarm: alarm)
            }
        }
    
}

#Preview {
    AlarmRowView(
        alarm: .constant(
            AlarmModel(
                id: UUID.init(uuidString: "F999E5F8-C36C-495A-93FC-0C247A3E6E5F")!,
                name: "Abfahrt!",
                type: .custom,
                hour: 1,
                minute: 0,
                period: .AM,
                pushable: true,
                weekdays: [Locale.Weekday.thursday, Locale.Weekday.friday]
            )
        )
    )
}
