//
//  RuntimeError.swift
//  SmartAlarm
//
//  Created by Jonas Wahringer on 30.06.26.
//

import Foundation

struct RuntimeError: LocalizedError {
    let description: String

    init(_ description: String) {
        self.description = description
    }

    var errorDescription: String? {
        description
    }
}

