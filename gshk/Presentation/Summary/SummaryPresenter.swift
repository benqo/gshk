//
//  SummaryPresenter.swift
//  gshk
//
//  Created by Benjamin on 25. 4. 24.
//

import Foundation

protocol SummaryPresenting {
    func loadData()
}

protocol SummaryDisplaying {
    func display(viewModel: SummaryPresenter.ViewModel)
    func display(error: String)
}

class SummaryPresenter: SummaryPresenting {
    struct Constants {
        static let summaryDays: Int = 30
    }
    
    struct DisplayedWorkout {
        let title: String
        let subtitle: String
        let image: String
    }
    
    struct DisplayedSummary {
        let itemOne: Item
        let itemTwo: Item
        
        struct Item {
            let title: String
            let value: String
            let valueUnits: [String]
        }
    }
    
    struct ViewModel {
        let sections: [Section]
    }
    
    struct Section {
        let title: String
        let rows: [Row]
    }
    
    enum Row {
        case summary(DisplayedSummary), workout(DisplayedWorkout)
    }
    
    typealias SummaryDisplayer = SummaryDisplaying & AnyObject
    var workoutUseCase: WorkoutUseCase!
    var viewModel = ViewModel(sections: [])
    weak var displayer: SummaryDisplayer!
    
    private var data: WorkoutSummaryEntity?
    private let dateFormatter = DateFormatter()
    private let decimalFormatter = NumberFormatter()
    
    init(displayer: SummaryDisplayer) {
        self.displayer = displayer
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        decimalFormatter.minimumFractionDigits = 0
        decimalFormatter.maximumFractionDigits = 2
        decimalFormatter.numberStyle = .decimal
    }
    
    func loadData() {
        workoutUseCase.authorize { [weak self] error in self?.handleAuthorization(error: error) }
    }
    
    func updateViewModelAndDisplay() {
        guard let data = data else { return }
        
        let workouts = data.workouts.map { getWorkoutRow(for: $0) }
        viewModel = .init(sections: [
            .init(title: "LAST \(Constants.summaryDays) DAYS", rows: getSummaryRows(for: data)),
            .init(title: "\(data.workouts.count) ACTIVITIES", rows: workouts)
        ])
        displayer.display(viewModel: viewModel)
    }
    
    private func handleAuthorization(error: Error?) {
        if let error = error as? UseCaseError {
            displayer.display(error: error.message)
        } else if let error = error {
            displayer.display(error: error.localizedDescription)
        } else {
            workoutUseCase.getSummary(days: Constants.summaryDays) { [weak self] result in self?.handleSummary(result) }
        }
    }
    
    private func handleSummary(_ result: Result<WorkoutSummaryEntity, Error>) {
        switch result {
        case .success(let summary):
            data = summary
            updateViewModelAndDisplay()
        case .failure(let error):
            displayer.display(error: error.localizedDescription)
        }
    }
    
    private func getWorkoutRow(for workout: WorkoutEntity) -> Row {
        let distanceString = decimalFormatter.string(for: workout.distance / 1000) ?? "0"
        var name = workout.type.name
        
        if let isIndoor = workout.isIndoor {
            name = "\(isIndoor ? "Indoor" : "Outdoor") \(name)"
        }
        
        return .workout(.init(title: "\(distanceString) km \(name)",
                              subtitle: dateFormatter.string(from: workout.startDate),
                              image: workout.type.icon))
    }
    
    private func getSummaryRows(for data: WorkoutSummaryEntity) -> [Row] {
        let duration = data.duration / 60
        let hours = Int(duration / 60)
        let minutes = Int(duration - Double(hours * 60))
        let energyString = decimalFormatter.string(for: Int(data.energy)) ?? "0"
        let distanceString = decimalFormatter.string(for: data.distance / 1000) ?? "0"
        let elevationString = decimalFormatter.string(for: data.elevation) ?? "0"
        
        return [
            .summary(
                .init(itemOne: .init(title: "Duration", value: "\(hours) hr \(minutes) min", valueUnits: ["hr", "min"]),
                      itemTwo: .init(title: "Active rnergy", value: "\(energyString) kcal", valueUnits: ["kcal"]))),
            .summary(
                .init(itemOne: .init(title: "Distance", value: "\(distanceString) km", valueUnits: ["km"]),
                      itemTwo: .init(title: "Elevation Gain", value: "\(elevationString) m", valueUnits: ["m"])))
        ]
    }
}

extension WorkoutType {
    var icon: String {
        switch self {
        case .cycling: return "figure.outdoor.cycle"
        case .running: return "figure.run"
        case .walking: return "figure.walk"
        case .swimming: return "figure.pool.swim"
        case .tennis: return "figure.tennis"
        default: return "figure.strengthtraining.functional"
        }
    }
    
    var name: String {
        switch self {
        case .americanFootball:             return "American Football"
        case .archery:                      return "Archery"
        case .australianFootball:           return "Australian Football"
        case .badminton:                    return "Badminton"
        case .baseball:                     return "Baseball"
        case .basketball:                   return "Basketball"
        case .bowling:                      return "Bowling"
        case .boxing:                       return "Boxing"
        case .climbing:                     return "Climbing"
        case .crossTraining:                return "Cross Training"
        case .curling:                      return "Curling"
        case .cycling:                      return  "Cycling"
        case .dance:                        return "Dance"
        case .danceInspiredTraining:        return "Dance Inspired Training"
        case .elliptical:                   return "Elliptical"
        case .equestrianSports:             return "Equestrian Sports"
        case .fencing:                      return "Fencing"
        case .fishing:                      return "Fishing"
        case .functionalStrengthTraining:   return "Functional Strength Training"
        case .golf:                         return "Golf"
        case .gymnastics:                   return "Gymnastics"
        case .handball:                     return "Handball"
        case .hiking:                       return "Hiking"
        case .hockey:                       return "Hockey"
        case .hunting:                      return "Hunting"
        case .lacrosse:                     return "Lacrosse"
        case .martialArts:                  return "Martial Arts"
        case .mindAndBody:                  return "Mind and Body"
        case .mixedMetabolicCardioTraining: return "Mixed Metabolic Cardio Training"
        case .paddleSports:                 return "Paddle Sports"
        case .play:                         return "Play"
        case .preparationAndRecovery:       return "Preparation and Recovery"
        case .racquetball:                  return "Racquetball"
        case .rowing:                       return "Rowing"
        case .rugby:                        return "Rugby"
        case .running:                      return "Running"
        case .sailing:                      return "Sailing"
        case .skatingSports:                return "Skating Sports"
        case .snowSports:                   return "Snow Sports"
        case .soccer:                       return "Soccer"
        case .softball:                     return "Softball"
        case .squash:                       return "Squash"
        case .stairClimbing:                return "Stair Climbing"
        case .surfingSports:                return "Surfing Sports"
        case .swimming:                     return "Swimming"
        case .tableTennis:                  return "Table Tennis"
        case .tennis:                       return "Tennis"
        case .trackAndField:                return "Track and Field"
        case .traditionalStrengthTraining:  return "Traditional Strength Training"
        case .volleyball:                   return "Volleyball"
        case .walking:                      return "Walking"
        case .waterFitness:                 return "Water Fitness"
        case .waterPolo:                    return "Water Polo"
        case .waterSports:                  return "Water Sports"
        case .wrestling:                    return "Wrestling"
        case .yoga:                         return "Yoga"
            
            // iOS 10
        case .barre:                        return "Barre"
        case .coreTraining:                 return "Core Training"
        case .crossCountrySkiing:           return "Cross Country Skiing"
        case .downhillSkiing:               return "Downhill Skiing"
        case .flexibility:                  return "Flexibility"
        case .highIntensityIntervalTraining:    return "High Intensity Interval Training"
        case .jumpRope:                     return "Jump Rope"
        case .kickboxing:                   return "Kickboxing"
        case .pilates:                      return "Pilates"
        case .snowboarding:                 return "Snowboarding"
        case .stairs:                       return "Stairs"
        case .stepTraining:                 return "Step Training"
        case .wheelchairWalkPace:           return "Wheelchair Walk Pace"
        case .wheelchairRunPace:            return "Wheelchair Run Pace"
            
            // iOS 11
        case .taiChi:                       return "Tai Chi"
        case .mixedCardio:                  return "Mixed Cardio"
        case .handCycling:                  return "Hand Cycling"
            
            // iOS 13
        case .discSports:                   return "Disc Sports"
        case .fitnessGaming:                return "Fitness Gaming"
            
            // Catch-all
        default:                            return "Other"
        }
    }
}

extension UseCaseError {
    var message: String {
        switch self {
        case .noData: return "Health data is not available."
        }
    }
}
