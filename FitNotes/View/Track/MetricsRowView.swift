//
//  MetricsViews.swift
//  FitNotes
//
//  Created by Myles Verdon on 06/01/2024.
//

import SwiftUI

var doubleFormatter: NumberFormatter {
    let formatter = NumberFormatter()
    formatter.maximumFractionDigits = 2
    formatter.nilSymbol = "-"
    return formatter
}


struct MetricsRow: View {
    
    var set: WorkoutSet
    var exercise: Exercise {
        self.set.group!.exercise!
    }
    
    var numActive: Int {
        return exercise.uses_reps.intValue + exercise.uses_time.intValue + exercise.uses_distance.intValue + exercise.uses_time.intValue
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                
                RepsMetricView(set: set)
                    .textScale(Text.Scale.secondary, isEnabled: numActive > 2)
                    .frame(maxWidth: geometry.size.width / CGFloat(numActive), maxHeight: geometry.size.height, alignment: .center)
                
                WeightMetricView(set: set)
                    .textScale(Text.Scale.secondary, isEnabled: numActive > 2)
                    .frame(maxWidth: geometry.size.width / CGFloat(numActive), maxHeight: geometry.size.height, alignment: .center)
                
                DistanceMetricView(set: set)
                    .textScale(Text.Scale.secondary, isEnabled: numActive > 2)
                    .frame(maxWidth: geometry.size.width / CGFloat(numActive), maxHeight: geometry.size.height, alignment: .center)
                
                TimeMetricView(set: set)
                    .textScale(Text.Scale.secondary, isEnabled: numActive > 2)
                    .frame(maxWidth: geometry.size.width / CGFloat(numActive), maxHeight: geometry.size.height, alignment: .center)
                
            }
        }
    }
    
}

struct RepsMetricView: View {

    var set: WorkoutSet
    var exercise: Exercise {
        self.set.group!.exercise!
    }
    
    var body: some View {
        MetricView(value: doubleFormatter.string(from: set.reps as NSNumber) ?? "Error",
                   visible: exercise.uses_reps,
                   label: "Reps")
        
    }
}

struct WeightMetricView: View {

    var set: WorkoutSet
    var exercise: Exercise {
        self.set.group!.exercise!
    }
    
    @AppStorage("defaultWeightUnit") var defaultWeightUnit: WeightUnitSetting = WeightUnitSetting.kg
    
    var weight: String {
        doubleFormatter.string(from: exercise.weight_unit.fromMetric(weight: set.weightKilograms, defaultUnit: defaultWeightUnit) as NSNumber) ?? "Error"}
        
    var body: some View {
        MetricView(value: weight,
                   visible: exercise.uses_weight,
                   label: exercise.weight_unit.resolve(defaultUnit: defaultWeightUnit))
        
    }
}

struct DistanceMetricView: View {

    var set: WorkoutSet
    var exercise: Exercise {
        self.set.group!.exercise!
    }
    
    @AppStorage("defaultDistanceUnit") var defaultDistanceUnit: DistanceUnitSetting = DistanceUnitSetting.kilometers
    
    var distance: String {
        doubleFormatter.string(from: exercise.distance_unit.fromMetric(distance: set.distanceMeters, defaultUnit: defaultDistanceUnit) as NSNumber) ?? "Error"
    }
    
    var body: some View {
        MetricView(value: distance,
                   visible: exercise.uses_distance,
                   label: exercise.distance_unit.resolve(defaultUnit: defaultDistanceUnit))
    }
}

struct TimeMetricView: View {

    var set: WorkoutSet
    var exercise: Exercise {
        self.set.group!.exercise!
    }
    
    @AppStorage("defaultTimeUnit") var defaultTimeUnit: TimeUnitSetting = TimeUnitSetting.seconds
    
    var time: String {
        doubleFormatter.string(from: exercise.time_unit.fromMetric(time: set.timeSeconds, defaultUnit: defaultTimeUnit) as NSNumber) ?? "Error"
    }
    
    var body: some View {
        MetricView(value: time,
                   visible: exercise.uses_time,
                   label: exercise.time_unit.resolve(defaultUnit: defaultTimeUnit))
    }
}


struct MetricView: View {
    
    var value: String
    var visible: Bool
    var label: String
    
    var body: some View {
        if (visible) {
            HStack {
                Text(value)
                    .font(.title2)
                    .bold()
                
                Text(label)
                    .font(.system(size: 14))
            }
        }
        
        
    }
    
}
