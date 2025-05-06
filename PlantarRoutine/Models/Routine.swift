//
//  Routine.swift
//  PlantarRoutine
//
//  Created by sashank.yalamanchili on 29.04.25.
//

import Foundation

struct Routine: Codable {
    let name: String
    let timeUnit: String
    let setPrep: Int
    let exercises: [Exercise]
}

struct Exercise: Codable, Identifiable {
    let id: String
    let label: String
    let sets: Int
    let reps: Int?
    let hold: Int
    let rest: Int
    let side: Bool
    let alternateSide: Bool
    let steps: [String]
}
