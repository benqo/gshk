//
//  WorkoutEntities.swift
//  gshk
//
//  Created by Benjamin on 25. 4. 24.
//

import Foundation

struct WorkoutSummaryEntity {
    let workouts: [WorkoutEntity]
    let distance: Double
    let energy: Double
    let duration: Double
    let elevation: Double
}

struct WorkoutEntity {
    let distance: Double
    let duration: Double
    let energy: Double
    let elevation: Double?
    let isIndoor: Bool?
    let startDate: Date
    let type: WorkoutType
}
