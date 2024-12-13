//
//  SleepModel.swift
//  SleepSounds
//
//  Created by Mehmet Jiyan Atalay on 9.12.2024.
//

import Foundation

struct SleepModel: Identifiable, Equatable {
    let id: UUID = UUID()
    let name: String
    let image: String
    let sound: URL
}
