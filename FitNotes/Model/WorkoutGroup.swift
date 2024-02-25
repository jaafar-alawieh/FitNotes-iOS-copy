//
//  Set.swift
//  FitNotes
//
//  Created by Myles Verdon on 30/12/2023.
//

import Foundation
import SwiftData

@Model
class WorkoutGroup {
    
    init(dayGroupId: Int, date: Date = .now, exercise: Exercise, notes: String? = nil) {
        self.dayGroupId = dayGroupId
        self.date = date
        self.exercise = exercise
        self.notes = notes
        self.entries = []
    }
    
    var dayGroupId: Int
    
    var date: Date
    
    var exercise: Exercise?
    
    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.group)
    var entries: [WorkoutSet]

    var notes: String?
    
}
