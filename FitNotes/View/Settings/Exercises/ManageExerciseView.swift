//
//  ManageExerciseView.swift
//  FitNotes
//
//  Created by Myles Verdon on 22/03/2024.
//

import SwiftUI
import SwiftData

struct ManageExerciseView: View {
    
    @State var searchText = ""
    @State private var selectedCategories: Set<ExerciseCategory> = []
    
    @Query var exercises: [Exercise]
    
    var searchResults: [Exercise] {
        if searchText.isEmpty {
            return selectedCategories.isEmpty ? exercises : exercises.filter { selectedCategories.contains($0.category!) }
        } else {
            return exercises.filter { $0.name.contains(searchText) && (selectedCategories.isEmpty || selectedCategories.contains($0.category!)) }
        }
    }
    
    var body: some View {
        List(searchResults) { exercise in
            NavigationLink(destination: AddEditExerciseView(exercise: exercise), label: {
                HStack {
                    Circle()
                        .fill(Color.init(hex: exercise.category?.colour ?? "FFFFFF"))
                        .frame(width: 10, height: 10)
                    Text(exercise.name)
                }
            })
        }
        .navigationTitle("Manage Exercises")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar() {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: AddEditExerciseView()) {
                    Text("Add")
                }
            }
        }
        
    }
}

#Preview {
    @State var navPath = NavigationPath()
    
    return NavigationStack {
        ManageExerciseView()
            .modelContainer(previewContainer)
    }
}
