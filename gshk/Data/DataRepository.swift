//
//  DataRepository.swift
//  gshk
//
//  Created by Benjamin on 25. 4. 24.
//

import Foundation
import HealthKit

class DataRepository: WorkoutProvider {
    private let healthStore = HKHealthStore()
    
    func authorize(handler: @escaping ((Error?) -> Void)) {
        if HKHealthStore.isHealthDataAvailable() {
            requestAuthorization(handler: handler)
        } else {
            handler(UseCaseError.noData)
        }
    }
    
    func getWorkouts(days: Int, handler: @escaping ((Result<[WorkoutEntity], Error>) -> Void)) {
        Task {
            if let results = try? await getRecentWorkouts(days: 30) {
                await MainActor.run {
                    handler(.success(results.map { $0.workoutEntity }))
                }
            }
        }
    }
    
    private func requestAuthorization(handler: @escaping ((Error?) -> Void)) {
        let typesToRead: Set = [HKQuantityType.workoutType()]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { (success, error) in
            success ? handler(nil) : handler(error)
        }
    }
    
    private func getRecentWorkouts(days: Int) async throws -> [HKWorkout] {
        let end = Date()
        let start = end.advanced(by: -60 * 60 * 24 * Double(days))

        let recentActivityPredicate = HKQuery.predicateForWorkoutActivities(start: start, end: end)
        let workoutPredicate = HKQuery.predicateForWorkouts(activityPredicate: recentActivityPredicate)
        
        let query = HKSampleQueryDescriptor(
            predicates: [.workout(workoutPredicate)],
            sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)],
            limit: nil
        )
        
        return try await query.result(for: healthStore)
    }
    
}

typealias WorkoutType = HKWorkoutActivityType

extension HKWorkout {
    var workoutEntity: WorkoutEntity {
        return .init(distance: totalDistance?.doubleValue(for: .meter()) ?? 0,
                     duration: duration,
                     energy: totalEnergyBurned?.doubleValue(for: .largeCalorie()) ?? 0,
                     elevation: elevationGain,
                     isIndoor: isIndoor,
                     startDate: startDate,
                     type: workoutActivityType)
    }
    
    var elevationGain: Double? {
        if let elevation = metadata?[HKMetadataKeyElevationAscended] as? HKQuantity {
            return elevation.doubleValue(for: .meter())
        }
        
        return nil
    }
    
    var isIndoor: Bool? {
        return metadata?[HKMetadataKeyIndoorWorkout] as? Bool
    }
}
