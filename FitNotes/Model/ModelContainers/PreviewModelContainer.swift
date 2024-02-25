//
//  PreviewModelContainer.swift
//  FitNotes
//
//  Created by Myles Verdon on 29/12/2023.
//

import SwiftUI
import SwiftData


@MainActor
let previewContainer: ModelContainer = {
    do {
        
        let container = try ModelContainer(for: Exercise.self, ExerciseCategory.self, WorkoutSet.self, WorkoutGroup.self,
                                           configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        
        // Add default exercise categories
        container.mainContext.insert(ShoulderCategory)
        container.mainContext.insert(TricepCategory)
        container.mainContext.insert(BicepCategory)
        container.mainContext.insert(ChestCategory)
        container.mainContext.insert(BackCategory)
        container.mainContext.insert(LegsCategory)
        container.mainContext.insert(AbsCategory)
        container.mainContext.insert(CardioCategory)
        
        
        for exercise in ExerciseDefaultData {
            container.mainContext.insert(exercise)
        }
        
        
        let group = WorkoutGroup(dayGroupId: 0, exercise: try! ExerciseDefaultData.filter(#Predicate<Exercise> { exercise in
            exercise.name == "Deadlift"
        })[0])
        container.mainContext.insert(group)
        
        group.entries.append(WorkoutSet(id: 1, reps: 1, weightKilograms: 100, is_personal_record: false))
        group.entries.append(WorkoutSet(id: 2, reps: 2, weightKilograms: 100, is_personal_record: false))
        group.entries.append(WorkoutSet(id: 3, reps: 3, weightKilograms: 100, is_personal_record: false))
        
        return container
    } catch {
        fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
    }
}()

