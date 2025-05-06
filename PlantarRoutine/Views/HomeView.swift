//
//  HomeView.swift
//  PlantarRoutine
//
//  Created by sashank.yalamanchili on 29.04.25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = AppViewModel()
    @State private var showSessionComplete = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Title + Timer
                    VStack(spacing: 12) {
                        Text(viewModel.phase)
                            .font(.largeTitle.weight(.bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 49)

                        Text(viewModel.isRunning ? viewModel.formattedTimer : "\(viewModel.totalMinutes):\(viewModel.totalSeconds)")
                            .font(.system(size: 98, weight: .semibold))
                            .foregroundColor(
                                viewModel.isRunning
                                    ? (viewModel.isPrepPhase ? .red :
                                       (viewModel.isRestPhase ? .yellow : .primary))
                                    : .primary
                            )
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity)

                    // Exercises List (only if not running)
                    if !viewModel.steps.isEmpty && !viewModel.isRunning {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Exercises")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                                .padding(.bottom, 8)

                            ForEach(Array(viewModel.steps.enumerated()), id: \.offset) { index, step in
                                NavigationLink(destination: InstructionDetailView(title: step, steps: viewModel.stepsForExercise(named: step))) {
                                    HStack(alignment: .top, spacing: 8) {
                                        Text("\(index + 1).")
                                            .foregroundColor(.secondary)
                                        Text(step)
                                            .foregroundColor(.primary)
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal)
                                }
                                Divider()
                                    .padding(.leading)
                            }
                        }
                        .padding(.bottom)
                    }

                    // Start / Stop Button
                    ZStack {
                        if viewModel.isRunning {
                            Button(action: {
                                viewModel.stop()
                            }) {
                                Text("Stop")
                                    .foregroundColor(.red)
                                    .frame(width: 84, height: 84)
                                    .overlay(
                                        Circle().stroke(Color.red, lineWidth: 1)
                                    )
                            }
                            .opacity(0.56)
                            .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            Button(action: {
                                viewModel.start()
                            }) {
                                Text("Start")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.primary.opacity(0.1))
                                    .foregroundColor(.primary)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal)
                }
            }
        }
        .onAppear {
            viewModel.loadRoutine()
            HealthKitService.shared.requestPermission()
        }
        .onReceive(viewModel.$didFinishRoutine) { finished in
            if finished {
                showSessionComplete = true
                viewModel.didFinishRoutine = false
            }
        }
        .fullScreenCover(isPresented: $showSessionComplete) {
            SessionCompleteView {
                showSessionComplete = false
            }
        }
    }
}

#Preview {
    HomeView()
}
