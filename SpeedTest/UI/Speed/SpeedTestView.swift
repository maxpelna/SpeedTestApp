//
//  SpeedTestView.swift
//  SpeedTest
//
//  Created by Maksims Pelna on 05/10/2025.
//

import SwiftUI

struct SpeedTestView: View {
    @ObservedObject var viewModel: SpeedTestVM

    var body: some View {
        VStack {
            Spacer()

            SpeedometerView(speed: $viewModel.speed, maxSpeed: 250)

            Spacer()

            HStack {
                Button(action: viewModel.stopTest) {
                    Text("Stop")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.capsule)
                .controlSize(.extraLarge)

                Button(action: viewModel.startTest) {
                    Text("Start")
                        .frame(maxWidth: .infinity)
                }
                .tint(.accentColor)
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.extraLarge)
                .disabled(viewModel.isRunning)
            }
            .padding()
        }
    }
}

private struct SpeedometerView: View {
    @Binding var speed: Double
    var maxSpeed: Double = 100

    private var speedPercentage: Double {
        min(speed / maxSpeed, 1.0)
    }

    private var pointerAngle: Angle {
        let minAngle: Double = -90
        let maxAngle: Double = 90
        let angle = minAngle + (maxAngle - minAngle) * speedPercentage

        return .degrees(angle)
    }

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.0, to: 0.5)
                .stroke(Color.gray.opacity(0.2), lineWidth: 16)
                .rotationEffect(.degrees(180))
                .frame(width: 200, height: 200)

            Circle()
                .trim(from: 0.0, to: 0.49 * speedPercentage)
                .stroke(
                    AngularGradient(gradient: .init(colors: [Color.red, Color.yellow, Color.green]), center: .center, angle: .init(degrees: 180)),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .rotationEffect(.degrees(180))
                .frame(width: 200, height: 200)
                .animation(.easeInOut(duration: 0.1), value: speedPercentage)

            ZStack {
                Rectangle()
                    .fill(Color.primary)
                    .frame(width: 4, height: 60)
                    .offset(y: -30)
                    .rotationEffect(pointerAngle)
                    .shadow(radius: 2)

                Circle()
                    .fill(Color.primary)
                    .frame(width: 10, height: 10)
            }
            .frame(width: 140, height: 140)
            .animation(.easeInOut(duration: 0.1), value: pointerAngle)

            VStack(spacing: 8) {
                Text(String(format: "%.1f", speed))
                    .font(.largeTitle)
                    .foregroundColor(.primary)
                Text("Mbps")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 100)
        }
    }
}
