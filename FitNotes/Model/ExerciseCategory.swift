//
//  Category.swift
//  FitNotes
//
//  Created by Myles Verdon on 26/12/2023.
//

import Foundation
import SwiftUI
import SwiftData

@Model
class ExerciseCategory {
    
    init(name: String, colour: String = "#FFFFFF") {
        self.name = name
        self.colour = colour
        self.exercises = [Exercise]()
    }
    
    
    @Attribute(.unique) var name: String
    var colour: String
    
    @Relationship(deleteRule: .nullify, inverse: \Exercise.category)
    var exercises: [Exercise]
    
}

// Default categories
var ShoulderCategory = ExerciseCategory(name: "Shoulders", colour: "#F54336")
var TricepCategory = ExerciseCategory(name: "Triceps", colour: "#EE2C2C")
var BicepCategory = ExerciseCategory(name: "Biceps", colour: "#FF00FF")
var ChestCategory = ExerciseCategory(name: "Chest", colour: "#FDB813")
var BackCategory = ExerciseCategory(name: "Back", colour: "#E5053A")
var LegsCategory = ExerciseCategory(name: "Legs", colour: "#D7DF01")
var AbsCategory = ExerciseCategory(name: "Abs", colour: "#FF00CC")
var CardioCategory = ExerciseCategory(name: "Cardio", colour: "#FFD300")
