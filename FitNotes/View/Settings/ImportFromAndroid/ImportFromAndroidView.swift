//
//  ImportFromAndroidView.swift
//  FitNotes
//
//  Created by Myles Verdon on 14/01/2024.
//

import SwiftUI
import SwiftData

import UniformTypeIdentifiers
import SQLite3

struct ImportFromAndroidView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Binding var path: NavigationPath
    
    @State private var importedSets: [WorkoutSet] = []
    @State private var importedGroups: [WorkoutGroup] = []
    @State private var importedCategories: [ExerciseCategory] = []
    
    @State private var importing = false
    @State private var importFinished = false
    @State private var errorMsg: String? = nil
    
    var body: some View {
        
        VStack(spacing: 0) {
            if (!importFinished) {
                
                VStack(spacing: 10) {
                    Text("\(Text("Select the FitNotes_backup.fitnotes file that you wish to import.")) _See [here](https://www.fitnotesapp.com/settings/) for how to create a backup._")
                        .multilineTextAlignment(.center)
                        .font(.footnote)
                        .padding(.horizontal, 20)
                        .padding(.top)
                        .padding(.bottom, 8)
                    
                    Button {
                        importing = true
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Choose file to import")
                        }
                    }
                    .fileImporter(
                        isPresented: $importing,
                        allowedContentTypes: [UTType("com.verdoncreative.FitNotes-androidDB")!]
                    ) { result in
                        importing = false
                        switch result {
                        case .success(let file):
                            do {
                                parseDatabase(filePath: file.absoluteString)
                                importFinished = true
                            }
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                    .padding(.bottom)
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity)
                .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
            }
            
            if (errorMsg != nil) {
                Label(
                    title: { Text(errorMsg ?? "-") },
                    icon: { Image(systemName: "exclamationmark.triangle") }
                )
                .foregroundStyle(.red)
                .padding(.vertical, 40)
                
            } else if (importedCategories.count > 0) {
                NavigationView {
                    VStack {
                        Text("Import successful!")
                        List(importedCategories) { category in
                            Section {
                                ForEach(category.exercises) { exercise in
                                    
                                    let sets = exercise.groups.flatMap({ $0.entries }).count
                                    
                                    HStack {
                                        Text(exercise.name)
                                        Spacer()
                                        Text(String(sets))
                                    }
                                }
                            } header: {
                                HStack {
                                    Circle()
                                        .fill(Color.init(hex: category.colour))
                                        .frame(width: 10, height: 10)
                                    Text(category.name)
                                    Spacer()
                                    Text("Sets")
                                }
                            }
                        }
                    }
                }
            }
            
            
            Spacer()
        }
        .navigationTitle("Import Android Data")
    }
    
    func parseDatabase(filePath: String) {
        
        var db: OpaquePointer?
        
        guard sqlite3_open(filePath, &db) == SQLITE_OK else {
            sqlite3_close(db)
            db = nil
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Match the format of your date string
        
        // ============ Import categories =============
        let categoryQueryString = "SELECT * FROM Category"
        var categoryQueryStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, categoryQueryString, -1, &categoryQueryStatement, nil) == SQLITE_OK {
            
            
            while (sqlite3_step(categoryQueryStatement) == SQLITE_ROW) {
                let categoryId = sqlite3_column_int(categoryQueryStatement, 0)
                let colour = sqlite3_column_int(categoryQueryStatement, 2)
                guard let name = sqlite3_column_text(categoryQueryStatement, 1) else {
                    errorMsg = "Error reading name of category"
                    return
                }
                let category = ExerciseCategory(name: String(cString: name),
                                                colour: hexStringFromColor(rgb: Int(colour)))
                modelContext.insert(category)
                importedCategories.append(category)
                
                // ============ Import exercises =============
                let exerciseQueryString = "SELECT _id, name FROM exercise WHERE category_id=\(categoryId)"
                var exerciseQueryStatement: OpaquePointer?
                if sqlite3_prepare_v2(db, exerciseQueryString, -1, &exerciseQueryStatement, nil) == SQLITE_OK {
                    while (sqlite3_step(exerciseQueryStatement) == SQLITE_ROW) {
                        let exerciseId = sqlite3_column_int(exerciseQueryStatement, 0)
                        guard let exerciseName = sqlite3_column_text(exerciseQueryStatement, 1) else {
                            errorMsg = "Error reading exercise name"
                            sqlite3_finalize(exerciseQueryStatement)
                            return
                        }
                        let newExercise = Exercise(name: String(cString: exerciseName))
                        category.exercises.append(newExercise)
                        
                        // ============ Import sets / groups =============
                        let setsQueryString = "SELECT date, metric_weight, reps, distance, duration_seconds FROM training_log WHERE exercise_id=\(exerciseId) ORDER BY _id"
                        var setsQueryStatement: OpaquePointer?
                        var groupDict: [Date: [WorkoutSet]] = [:]
                        if sqlite3_prepare_v2(db, setsQueryString, -1, &setsQueryStatement, nil) == SQLITE_OK {
                            while (sqlite3_step(setsQueryStatement) == SQLITE_ROW) {
                                guard let _date = dateFormatter.date(from: String(cString: sqlite3_column_text(setsQueryStatement, 0))) else {
                                    errorMsg = String(cString: sqlite3_errmsg(db))
                                    sqlite3_finalize(setsQueryStatement)
                                    sqlite3_finalize(exerciseQueryStatement)
                                    sqlite3_finalize(categoryQueryStatement)
                                    return
                                }
                                
                                let metricWeight = sqlite3_column_double(setsQueryStatement, 2)
                                let reps = sqlite3_column_double(setsQueryStatement, 3)
                                let distance = sqlite3_column_double(setsQueryStatement, 4)
                                let duration = sqlite3_column_double(setsQueryStatement, 5)
                                
                                // Logic to handle the sets
                                if var existingSets = groupDict[_date] {
                                    let id = existingSets.count // ID is the index in the existing array
                                    let set = WorkoutSet(id: id, reps: reps, weightKilograms: metricWeight, distanceMeters: distance, timeSeconds: duration)
                                    existingSets.append(set)
                                    groupDict[_date] = existingSets
                                } else {
                                    let set = WorkoutSet(id: 0) // First set in a new group
                                    groupDict[_date] = [set]
                                }
                            }
                            for (groupDate, sets) in groupDict {
                                let newGroup = WorkoutGroup(dayGroupId: 0, date: groupDate)
                                newExercise.groups.append(newGroup)
                                for newSet in sets {
                                    newGroup.entries.append(newSet)
                                }
                            }
                            
                        } else {
                            errorMsg = String(cString: sqlite3_errmsg(db))
                            sqlite3_finalize(exerciseQueryStatement)
                            sqlite3_finalize(categoryQueryStatement)
                            return
                        }
                    }
                } else {
                    errorMsg = String(cString: sqlite3_errmsg(db))
                    sqlite3_finalize(categoryQueryStatement)
                    return
                }
            }
        }
        
        func hexStringFromColor(rgb: Int) -> String {
            let red = (rgb >> 16) & 0xFF
            let green = (rgb >> 8) & 0xFF
            let blue = rgb & 0xFF
            
            return String(format: "%02X%02X%02X", red, green, blue)
        }
        
        
        #Preview {
            @State var path = NavigationPath(["ImportFromAndroid"])
            
            return NavigationStack(path: $path) {
                EmptyView()
                    .navigationDestination(for: String.self) { dest in
                        switch dest {
                        case "ImportFromAndroid":
                            ImportFromAndroidView(path: $path)
                                .navigationBarTitleDisplayMode(.inline)
                        default:
                            Text("no view found")
                        }
                    }
            }
        }
        
    }
}
