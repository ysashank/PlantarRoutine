//
//  ContentView.swift
//  PlantarRoutine
//
//  Created by sashank.yalamanchili on 29.04.25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AppViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    if viewModel.isRunning {
                        Text(!viewModel.exerciseLabel.isEmpty ? viewModel.exerciseLabel : "Starting...")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .opacity(!viewModel.exerciseLabel.isEmpty ? 1 : 0)
                    } else {
                        Text("Total Duration")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    if viewModel.isRunning {
                        Text(viewModel.formattedTimer)
                            .font(.system(size: 98, weight: .medium, design: .default))
                            .foregroundColor(
                                viewModel.isPrepPhase ? .red :
                                    (viewModel.isRestPhase ? .yellow : .primary)
                            )
                    } else {
                        VStack(spacing: 8) {
                            HStack(alignment: .bottom, spacing: 16) {
                                VStack(spacing: 4) {
                                    Text("MIN")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(viewModel.totalMinutes)
                                        .font(.system(size: 98, weight: .semibold))
                                        .foregroundColor(.primary)
                                }
                                Text(":")
                                    .font(.system(size: 98, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .padding(.bottom, 6)
                                VStack(spacing: 4) {
                                    Text("SEC")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(viewModel.totalSeconds)
                                        .font(.system(size: 98, weight: .semibold))
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                    
                    if !viewModel.steps.isEmpty {
                        List(Array(viewModel.steps.enumerated()), id: \.offset) { index, step in
                            if viewModel.isRunning {
                                HStack(alignment: .top, spacing: 8) {
                                    Text("\(index + 1).")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                    
                                    Text(step)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                            } else {
                                NavigationLink(destination: InstructionDetailView(title: step, steps: viewModel.stepsForExercise(named: step))) {
                                    HStack(alignment: .top, spacing: 8) {
                                        Text("\(index + 1).")
                                            .font(.body)
                                            .foregroundColor(.secondary)
                                        
                                        Text(step)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    if viewModel.isRunning {
                        viewModel.stop()
                    } else {
                        viewModel.start()
                    }
                }) {
                    Text(viewModel.isRunning ? "Stop" : "Start")
                        .foregroundColor(viewModel.isRunning ? Color.red.opacity(0.7) : Color.primary.opacity(0.7))
                        .padding(.vertical, 14)
                        .padding(.horizontal, 48)
                        .background(
                            Group {
                                if viewModel.isRunning {
                                    Color.clear
                                } else {
                                    Capsule().fill(Color.primary.opacity(0.1))
                                }
                            }
                        )
                        .overlay(viewModel.isRunning ?
                            RoundedRectangle(cornerRadius: 21).stroke(Color.red.opacity(0.7), lineWidth: 1)
                            : nil
                        )
                }
                .padding(.bottom, 77)
            }
            .navigationTitle(viewModel.phase)
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert(isPresented: $viewModel.showSavedAlert) {
            Alert(
                title: Text("Workout Saved!"),
                message: Text("Your session was saved to Apple Health."),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            viewModel.loadRoutine()
            HealthKitService.shared.requestPermission()
        }
    }
}
