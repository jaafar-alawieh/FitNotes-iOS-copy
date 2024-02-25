//
//  SwiftDataModelContainer.swift
//  FitNotes
//
//  Created by Myles Verdon on 27/12/2023.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
let AppModelContainer: ModelContainer = {
    do {
        
        @AppStorage("initialized") var initialised: Bool = false
        
        let container = try ModelContainer(for: ExerciseCategory.self, Exercise.self, WorkoutSet.self, WorkoutGroup.self)
        
        // If already initialised, return container
        guard !initialised else {
            return container
        }
        
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
        
        return container
        
    } catch {
        
        fatalError("Failed to create container")
    }
}()


