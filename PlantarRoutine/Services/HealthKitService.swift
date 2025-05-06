//
//  HealthKitService.swift
//  PlantarRoutine
//
//  Created by sashank.yalamanchili on 29.04.25.
//

import HealthKit

class HealthKitService {
    static let shared = HealthKitService()
    private let store = HKHealthStore()

    func requestPermission() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let typesToShare: Set = [HKObjectType.workoutType()]

        store.requestAuthorization(toShare: typesToShare, read: typesToShare) { success, error in
            if !success {
                print("HealthKit auth failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    func logWorkout(duration: TimeInterval, completion: @escaping (Bool) -> Void) {
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(duration)

        let workoutConfig = HKWorkoutConfiguration()
        workoutConfig.activityType = .flexibility

        let builder = HKWorkoutBuilder(healthStore: store, configuration: workoutConfig, device: .local())

        builder.beginCollection(withStart: startDate) { success, error in
            if !success {
                print("Begin collection failed: \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
                return
            }

            builder.endCollection(withEnd: endDate) { success, error in
                if !success {
                    print("End collection failed: \(error?.localizedDescription ?? "Unknown error")")
                    completion(false)
                    return
                }

                builder.finishWorkout { workout, error in
                    if let error = error {
                        print("Workout finish failed: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("Workout saved to HealthKit! ✅")
                        completion(true)
                    }
                }
            }
        }
    }
}
