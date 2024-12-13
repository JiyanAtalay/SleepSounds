//
//  ContenViewModel.swift
//  SleepSounds
//
//  Created by Mehmet Jiyan Atalay on 9.12.2024.
//

import Foundation

class ContenViewModel: ObservableObject {
    
    @Published var elements: [SleepModel] = [
        SleepModel(name: "Rain", image: "RainGlass", sound: Bundle.main.url(forResource: "RainAndBird", withExtension: "wav")!),
        SleepModel(name: "Fire", image: "Campfire", sound: Bundle.main.url(forResource: "Campfire", withExtension: "wav")!),
        SleepModel(name: "Waterfall", image: "Waterfall", sound: Bundle.main.url(forResource: "Waterfall", withExtension: "wav")!)
    ]
}
