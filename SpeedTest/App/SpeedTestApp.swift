//
//  SpeedTestApp.swift
//  SpeedTest
//
//  Created by Maksims Pelna on 05/10/2025.
//

import SwiftUI

@main
struct SpeedTestApp: App {
    private let speedService: SpeedService = SpeedServiceImpl()

    var body: some Scene {
        WindowGroup {
            SpeedTestView(
                viewModel: SpeedTestVM(speedService: speedService)
            )
        }
    }
}
