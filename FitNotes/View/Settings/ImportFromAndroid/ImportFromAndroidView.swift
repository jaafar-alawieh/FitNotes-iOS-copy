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
    
    @Binding var path: NavigationPath
    
    @State private var importedSets: [WorkoutSet] = []
    @State private var importedGroups: [WorkoutGroup] = []
    @State private var importedExercises: [Exercise] = []
    @State private var importedCategories: [ExerciseCategory] = []
    
    @State private var importing = false
    
    @State private var errorMsg: String? = nil
    
    var body: some View {
        
        VStack(spacing: 0) {
            
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
                        parseDatabase(filePath: file.absoluteString)
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
                        List{
                            Section("Categories") {
                                ForEach(importedCategories) { category in
                                    HStack {
                                        Circle()
                                            .fill(Color(hex: category.colour))
                                            .frame(width: 12, height: 12)
                                        Text(category.name)
                                    }
                                }
                            }
                            
                            Section("Exercises") {
                                ForEach(importedExercises) { exercise in
                                    HStack {
                                        Circle()
                                            .fill(Color(hex: exercise.category?.colour ?? "000000"))
                                            .frame(width: 12, height: 12)
                                        
                                    }
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
        
        // Import categories
        var queryString = "SELECT * FROM Category"
        var queryStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
            
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                let id = sqlite3_column_int(queryStatement, 0)
                let colour = sqlite3_column_int(queryStatement, 2)
                guard let name = sqlite3_column_text(queryStatement, 1) else {
                    errorMsg = "Error reading name of category"
                    return
                }
                print("ID: \(id), Name: \(String(cString: name)), Colour: \(hexStringFromColor(rgb: Int(colour)))")
                importedCategories.append(ExerciseCategory(name: String(cString: name),
                                                           colour: hexStringFromColor(rgb: Int(colour))
                                                          ))
            }
        } else {
            errorMsg = String(cString: sqlite3_errmsg(db))
        }
        sqlite3_finalize(queryStatement)
        
        // Import exercises
        queryString = "SELECT exercise.name, Category.name FROM exercise JOIN Category ON exercise.category_id=Category._id"
        if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                guard let exerciseName = sqlite3_column_text(queryStatement, 0),
                      let categoryName = sqlite3_column_text(queryStatement, 1)
                else {
                    errorMsg = "Error reading exercise or category name"
                    return
                }
                
                print("Exercise name: \(String(cString: exerciseName)), Category name: \(String(cString: categoryName))")
                guard let category = importedCategories.first(where: { cat in
                    cat.name == String(cString: categoryName)
                }) else {
                    errorMsg = "Category for exercise \(String(cString: exerciseName)) doesn't exist"
                    return
                }
                print("Category: \(category.name)")
                importedExercises.append(Exercise(name: String(cString: exerciseName), category: category))
            }
        } else {
            errorMsg = String(cString: sqlite3_errmsg(db))
        }
        sqlite3_finalize(queryStatement)
        
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

