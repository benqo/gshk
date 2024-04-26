//
//  WorkoutUseCase.swift
//  gshk
//
//  Created by Benjamin on 25. 4. 24.
//

import Foundation

protocol WorkoutProvider {
    func authorize(handler: @escaping ((Error?) -> Void))
    func getWorkouts(days: Int, handler: @escaping ((Result<[WorkoutEntity], Error>) -> Void))
}

enum UseCaseError: Error {
    case noData
}

class WorkoutUseCase {
    let repository: WorkoutProvider
    
    init(repository: WorkoutProvider) {
        self.repository = repository
    }
    
    func authorize(handler: @escaping ((Error?) -> Void)) {
        repository.authorize(handler: handler)
    }
    
    func getSummary(days: Int, handler: @escaping ((Result<WorkoutSummaryEntity, Error>) -> Void)) {
        repository.getWorkouts(days: days) { result in
            switch result {
            case .success(let workouts): 
                var duration: Double = 0
                var energy: Double = 0
                var distance: Double = 0
                var elevation: Double = 0
                
                workouts.forEach { workout in
                    duration += workout.duration
                    energy += workout.energy
                    distance += workout.distance
                    elevation += workout.elevation ?? 0
                }
                
                handler(.success(.init(workouts: workouts, distance: distance, energy: energy,
                                       duration: duration, elevation: elevation)))
            case.failure(let error):
                handler(.failure(error))
            }
        }
    }
}
