//
//  Settings.swift
//  FitNotes
//
//  Created by Myles Verdon on 30/12/2023.
//

import SwiftUI

enum WeightUnitSetting: String, CaseIterable {
    case kg = "Kilograms"
    case lb = "Pounds"
}

enum DistanceUnitSetting: String, CaseIterable {
    case miles = "Miles"
    case kilometers = "Kilometers"
    case meters = "Meters"
}

enum TimeUnitSetting: String, CaseIterable {
    case seconds = "Seconds"
    case minutes = "Minutes"
}

struct SettingsView: View {
    @AppStorage("defaultWeightIncrement") var defaultWeightIncrement: Double = 2.5
    @AppStorage("defaultDistanceIncrement") var defaultDistanceIncrement: Double = 1
    @AppStorage("defaultTimeIncrement") var defaultTimeIncrement: Double = 1
    
    @AppStorage("defaultWeightUnit") var defaultWeightUnit: WeightUnitSetting = WeightUnitSetting.kg
    @AppStorage("defaultDistanceUnit") var defaultDistanceUnit: DistanceUnitSetting = DistanceUnitSetting.kilometers
    @AppStorage("defaultTimeUnit") var defaultTimeUnit: TimeUnitSetting = TimeUnitSetting.seconds
    
    @AppStorage("defaultRestTime") var defaultRestTime: Int = 90
    
    @State private var isManagingExercisesPresented = false
    @State private var isManagingCategoriesPresented = false
    
    var body: some View {
        NavigationView {
            List {
                
                Section {
                    HStack {
                        NavigationLink(value: "ImportFromAndroid") {
                            Text("Import from FitNotes Android")
                        }
                    }
                }
                
                Section {
                    HStack {
                        NavigationLink(destination: ManageExerciseView()) {
                            Text("Manage Exercises")
                        }
                    }
                    HStack {
                        NavigationLink(value: "EditCategoriesView") {
                            Text("Manage Categories")
                        }
                    }
                }
                
                
                Section(header: Text("Increments")) {
                    
                    HStack {
                        Text("Weight Increment")
                        Spacer()
                        TextField("Weight Increment", value: $defaultWeightIncrement, formatter: NumberFormatter())
                        
                    }
                    TextField("Distance Increment", value: $defaultDistanceIncrement, formatter: NumberFormatter())
                    TextField("Weight Increment", value: $defaultTimeIncrement, formatter: NumberFormatter())
                    
                }
                
                Section(header: Text("Default Units")) {
                    Picker("Default Weight Unit", selection: $defaultWeightUnit) {
                        ForEach(WeightUnitSetting.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    
                    Picker("Default Distance Unit", selection: $defaultDistanceUnit) {
                        ForEach(DistanceUnitSetting.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    
                    Picker("Default Time Unit", selection: $defaultTimeUnit) {
                        ForEach(TimeUnitSetting.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                }
                
                Section(header: Text("Rest Time")) {
                    Stepper(value: $defaultRestTime, in: 0...300, step: 5) {
                        Text("Default Rest Time: \(defaultRestTime) seconds")
                    }
                }
                
                Section(header: Text("Manage")) {
                    Button(action: {
                        isManagingExercisesPresented.toggle()
                    }) {
                        Text("Manage Exercises")
                    }
                    .sheet(isPresented: $isManagingExercisesPresented) {
                        // Replace with your manage exercises view
                        Text("Manage Exercises")
                    }
                    
                    Button(action: {
                        isManagingCategoriesPresented.toggle()
                    }) {
                        Text("Manage Categories")
                    }
                    .sheet(isPresented: $isManagingCategoriesPresented) {
                        // Replace with your manage categories view
                        Text("Manage Categories")
                    }
                }
            }
        }
    }
}


#Preview {
    
    NavigationStack {
        SettingsView()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
    }
    
}
