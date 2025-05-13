//
//  Routine.swift
//  Solemate
//
//  Created by sashank.yalamanchili on 29.04.25.
//

import Foundation

struct Routine: Codable {
    let name: String
    let description: String
    let timeUnit: TimeUnit
    let prepTime: Int
    let restTime: Int
    let exercises: [Exercise]
}

enum TimeUnit: String, Codable {
    case seconds
    case minutes
}

struct Exercise: Codable, Identifiable {
    let id: String
    let label: String
    let sets: Int
    let reps: Int?
    let hold: Int
    let alternateSide: Bool
    let instructions: [String]
}

extension Routine {
    static let routine = Routine(
        name: "Solemate",
        description: "Daily ritual to heal your Plantar Fasciitis",
        timeUnit: .seconds,
        prepTime: 5,
        restTime: 5,
        exercises: [
            Exercise(
                id: "arcStretch",
                label: "Plantar Arch Stretch",
                sets: 2,
                reps: nil,
                hold: 30,
                alternateSide: true,
                instructions: [
                    "Sit, cross ankle over knee",
                    "Grab the base of the toes with same hand",
                    "Pull it firmly back toward shin",
                    "Hold stretch"
                ]
            ),
            Exercise(
                id: "toeSpreadCurl",
                label: "Toe Spread + Curl",
                sets: 1,
                reps: 5,
                hold: 5,
                alternateSide: false,
                instructions: [
                    "Spread toes wide, hold",
                    "Curl toes inward, hold",
                    "Relax briefly, repeat"
                ]
            ),
            Exercise(
                id: "toeDoodles",
                label: "Toe Drawing",
                sets: 1,
                reps: nil,
                hold: 60,
                alternateSide: false,
                instructions: [
                    "Lift foot",
                    "Draw A–E with big toe in air",
                    "Use ankle movement only",
                    "Slow and controlled"
                ]
            ),
            Exercise(
                id: "shortFoot",
                label: "Short Foot Drill",
                sets: 2,
                reps: 5,
                hold: 5,
                alternateSide: false,
                instructions: [
                    "Stand barefoot",
                    "Press ball of foot down, lift arch",
                    "Lift arch without toe curl",
                    "Hold and release"
                ]
            ),
            Exercise(
                id: "calfStretch",
                label: "Standing Calf Stretch",
                sets: 1,
                reps: nil,
                hold: 60,
                alternateSide: false,
                instructions: [
                    "Stand near wall",
                    "Step back one leg",
                    "Heel flat, knee straight",
                    "Lean forward to stretch calf"
                ]
            ),
            Exercise(
                id: "archMassage",
                label: "Arch Massage",
                sets: 1,
                reps: nil,
                hold: 60,
                alternateSide: false,
                instructions: [
                    "Sit with foot on opposite leg",
                    "Use thumbs to press arch",
                    "Massage heel to ball slowly"
                ]
            )
        ]
    )
}

extension Routine {
    func totalDurationSeconds() -> Int {
        var total = prepTime

        for exercise in exercises {
            let reps = exercise.reps ?? 1
            let sets = exercise.sets
            let hold = exercise.hold

            var exerciseTime = sets * reps * hold
            if exercise.alternateSide {
                exerciseTime *= 2
            }

            total += exerciseTime
            // rest after each set (not after last exercise)
            if exercise.id != exercises.last?.id {
                total += restTime
            }
        }

        return total
    }

    func formattedDuration() -> String {
        let totalSeconds = totalDurationSeconds()
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
