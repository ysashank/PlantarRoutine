//
//  HealthManager.swift
//  Solemate
//
//  Created by sashank.yalamanchili on 29.04.25.
//

import HealthKit

class HealthManager {
    static let shared = HealthManager()
    private let store = HKHealthStore()

    private init() {}

    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let workoutType = HKObjectType.workoutType()

        store.requestAuthorization(toShare: [workoutType], read: []) { success, error in
            if let error = error {
                print("HealthKit auth error: \(error.localizedDescription)")
            }
        }
    }

    func logWorkout(routineName: String) {
        let startDate = Date()
        let endDate = startDate

        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .flexibility

        let builder = HKWorkoutBuilder(healthStore: store, configuration: configuration, device: .local())

        builder.beginCollection(withStart: startDate) { success, error in
            guard error == nil else {
                print("Begin collection error: \(error!.localizedDescription)")
                return
            }

            builder.endCollection(withEnd: endDate) { success, error in
                guard error == nil else {
                    print("End collection error: \(error!.localizedDescription)")
                    return
                }

                builder.finishWorkout { workout, error in
                    if let error = error {
                        print("Workout save error: \(error.localizedDescription)")
                    } else {
                        print("Workout logged to Health: \(routineName)")
                    }
                }
            }
        }
    }
}
