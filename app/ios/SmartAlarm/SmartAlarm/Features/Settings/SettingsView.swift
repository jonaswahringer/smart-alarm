//
//  SettingsView.swift
//  SmartAlarm
//
//  Created by Jonas Wahringer on 30.06.26.
//

import SwiftUI

struct SettingsView: View {
    
    private var title = Text("Settings")
    private var content = List {
        Text("Element 1")
        Text("Element 2")
        Text("Element 3")
    }
    
    var body: some View {
        title
        content
        NavigationStack {
//            Text("Sleep").font(Font.headline).padding(5).padding(Edge.Set(Edge.leading), 15).frame(maxWidth: .infinity, alignment: .leading)
//            
//            List(sleep) { alarm in
//                NavigationLink(alarm.name, value: alarm)
//            }
//            .navigationDestination(for: AlarmModel.self) {
//                alarm in AlarmView(alarm: alarm)
//            }
//            
//            Text("Custom").font(Font.headline).padding(5).padding(Edge.Set(Edge.leading), 15).frame(maxWidth: .infinity, alignment: .leading)
//            
//            List(custom) { alarm in
//                NavigationLink(alarm.name, value: alarm)
//            }
//            .navigationDestination(for: AlarmModel.self) {
//                alarm in AlarmView(alarm: alarm)
//            }
//            .scrollEdgeEffectStyle(.hard, for: .all)
        }
    }
}

#Preview {
    SettingsView()
}
