//
//  SmartText.swift
//  SmartAlarm
//
//  Created by Jonas Wahringer on 30.06.26.
//

import SwiftUI

func SmartText(_ text: String) -> some View {
    Text(text).font(Font.headline).padding(5).padding(Edge.Set(Edge.leading), 15).frame(maxWidth: .infinity, alignment: .init(horizontal: .leading, vertical: .center))
}
