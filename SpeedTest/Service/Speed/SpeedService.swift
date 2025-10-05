//
//  SpeedService.swift
//  SpeedTest
//
//  Created by Maksims Pelna on 05/10/2025.
//

import Foundation
import Combine

protocol SpeedService {
    var speedResult: AnyPublisher<Double, Never> { get }

    func startTest()
    func stopTest()
}

final class SpeedServiceImpl: NSObject, SpeedService {
    private var speed = PassthroughSubject<Double, Never>()

    private var urlSession: URLSession?
    private var startTime: CFAbsoluteTime?
    private var totalBytesReceived: Int64 = 0
    private var timerCancellable: AnyCancellable?

    var speedResult: AnyPublisher<Double, Never> {
        speed.eraseToAnyPublisher()
    }

    func startTest() {
        stopTest()

        let config = URLSessionConfiguration.ephemeral
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.timeoutIntervalForRequest = 30
        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)

        guard let url = URL(string: AppConfig.downloadUrl) else { return }

        let task = urlSession?.dataTask(with: url)
        task?.resume()

        timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.emitCurrentSpeed() }
    }

    func stopTest() {
        timerCancellable?.cancel()
        urlSession?.invalidateAndCancel()
        totalBytesReceived = 0
        startTime = CFAbsoluteTimeGetCurrent()
    }

    private func emitCurrentSpeed() {
        guard let start = startTime else { return }
        let elapsed = CFAbsoluteTimeGetCurrent() - start
        guard elapsed > 0 else { return }

        let bytesPerSecond = Double(totalBytesReceived) / elapsed
        let mbps = (bytesPerSecond * 8) / 1_000_000
        speed.send(mbps)
    }
}

extension SpeedServiceImpl: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        totalBytesReceived += Int64(data.count)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        timerCancellable?.cancel()
        speed.send(completion: .finished)
        speed = PassthroughSubject<Double, Never>()
    }
}
