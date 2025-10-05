//
//  SpeedTestVM.swift
//  SpeedTest
//
//  Created by Maksims Pelna on 05/10/2025.
//

import Foundation
import Combine

final class SpeedTestVM: ObservableObject {
    @Published var speed: Double = 0.0
    @Published var isRunning: Bool = false

    private let speedService: SpeedService
    private var bag = Set<AnyCancellable>()

    init(speedService: SpeedService) {
        self.speedService = speedService
    }

    func startTest() {
        guard !isRunning else { return }
        resetSpeedometer()
        isRunning = true

        speedService.startTest()
        speedService.speedResult
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] _ in
                    self?.isRunning = false
                },
                receiveValue: { [weak self] speed in
                    self?.speed = speed
                }
            )
            .store(in: &bag)
    }

    func stopTest() {
        resetSpeedometer()
        speedService.stopTest()
    }

    private func resetSpeedometer() {
        bag.removeAll()
        isRunning = false
        speed = 0.0
    }
}
