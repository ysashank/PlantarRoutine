//
//  AppViewModel.swift
//  PlantarRoutine
//
//  Created by sashank.yalamanchili on 29.04.25.
//

import Foundation
import Combine
import UIKit

struct StepItem {
    let label: String
    let time: Int
    let isRest: Bool
    let steps: [String]
}

final class AppViewModel: ObservableObject {
    // MARK: - Published UI State
    @Published var phase = ""
    @Published var exerciseLabel = ""
    @Published var steps: [String] = []
    @Published var formattedTimer: String = "00:00"
    @Published var isRunning = false
    @Published var isPrepPhase = false
    @Published var isRestPhase = false
    @Published var showSavedAlert = false
    @Published var showTimerView = false

    // MARK: - Total Duration
    var totalDuration: Int {
        queue.map { $0.time }.reduce((routine?.setPrep ?? 5), +)
    }

    var totalMinutes: String {
        String(format: "%02d", totalDuration / 60)
    }

    var totalSeconds: String {
        String(format: "%02d", totalDuration % 60)
    }

    // MARK: - Internal State
    private(set) var queue: [StepItem] = []
    private var currentIndex = 0
    private var currentSeconds = 0
    private var timer: Timer?
    private var routine: Routine?

    // MARK: - Load Routine
    func loadRoutine() {
        guard let url = Bundle.main.url(forResource: "routine", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: Routine].self, from: data) else {
            return
        }
        routine = decoded["routine"]
        buildQueue()
        showSummary()
    }

    private func buildQueue() {
        guard let routine = routine else { return }
        queue = []

        for ex in routine.exercises {
            for set in 1...ex.sets {
                let sides = ex.side ? (ex.alternateSide ? ["Left", "Right"] : ["Both"]) : [""]
                for side in sides {
                    if let reps = ex.reps {
                        for rep in 1...reps {
                            queue.append(.init(label: "\(ex.label) \(side) (Rep \(rep))", time: ex.hold, isRest: false, steps: ex.steps))
                            if rep < reps {
                                queue.append(.init(label: "Rest", time: ex.rest, isRest: true, steps: []))
                            }
                        }
                    } else {
                        queue.append(.init(label: "\(ex.label) \(side)", time: ex.hold, isRest: false, steps: ex.steps))
                    }

                    if ex.rest > 0, !(set == ex.sets && side == sides.last) {
                        queue.append(.init(label: "Rest", time: ex.rest, isRest: true, steps: []))
                    }
                }
            }
        }
    }

    private func showSummary() {
        phase = routine?.name ?? ""
        steps = routine?.exercises.map { $0.label } ?? []
        formattedTimer = "\(totalMinutes):\(totalSeconds)"
    }

    // MARK: - Timer Start/Stop
    func start() {
        UIApplication.shared.isIdleTimerDisabled = true
        isRunning = true
        showTimerView = true
        currentIndex = 0
        startPrep()
    }

    func stop() {
        UIApplication.shared.isIdleTimerDisabled = false
        timer?.invalidate()
        timer = nil
        isRunning = false
        showTimerView = false
        showSummary()
    }
    
    func stepsForExercise(named name: String) -> [String] {
        routine?.exercises.first(where: { $0.label == name })?.steps ?? []
    }

    private func finishRoutine() {
        stop()
        phase = "All Done!"
        exerciseLabel = ""
        SoundManager.shared.play(.end)

        let duration = TimeInterval(totalDuration)
        HealthKitService.shared.logWorkout(duration: duration) { success in
            if success {
                DispatchQueue.main.async {
                    self.showSavedAlert = true
                }
            }
        }
    }

    // MARK: - Phase Flow
    private func startPrep() {
        isPrepPhase = true
        isRestPhase = false
        phase = "Get Ready"
        exerciseLabel = ""
        steps = []
        runTimer(for: routine?.setPrep ?? 5) { [weak self] in
            self?.nextStep()
        }
    }

    private func nextStep() {
        guard currentIndex < queue.count else {
            finishRoutine()
            return
        }

        let step = queue[currentIndex]
        isPrepPhase = false
        isRestPhase = step.isRest

        if step.isRest {
            phase = "Rest"
            exerciseLabel = ""
        } else {
            updatePhaseLabel(for: step.label)
            exerciseLabel = step.label.replacingOccurrences(of: "(Left|Right|Both).*", with: "", options: .regularExpression)
            
            SoundManager.shared.play(.start)
            SoundManager.shared.vibrate()
        }

        steps = step.steps
        runTimer(for: step.time) { [weak self] in
            SoundManager.shared.play(.end)
            self?.currentIndex += 1
            self?.nextStep()
        }
    }

    private func updatePhaseLabel(for label: String) {
        if label.contains("Left") {
            phase = "Left Side"
        } else if label.contains("Right") {
            phase = "Right Side"
        } else if label.contains("Both") {
            phase = "Both Sides"
        } else {
            phase = "Exercise"
        }
    }

    // MARK: - Timer Logic
    private func runTimer(for seconds: Int, completion: @escaping () -> Void) {
        timer?.invalidate()
        currentSeconds = seconds
        updateFormattedTimer()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
            guard let self = self else { return }

            self.currentSeconds -= 1
            self.updateFormattedTimer()

            if self.currentSeconds == 0 {
                t.invalidate()
                completion()
            } else if self.currentSeconds <= 5 {
                SoundManager.shared.play(.warn)
            }
        }
    }

    private func updateFormattedTimer() {
        let m = currentSeconds / 60
        let s = currentSeconds % 60
        formattedTimer = String(format: "%02d:%02d", m, s)
    }
}
