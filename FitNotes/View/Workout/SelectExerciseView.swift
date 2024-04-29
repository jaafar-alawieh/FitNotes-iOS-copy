//
//  SelectExercise.swift
//  FitNotes
//
//  Created by Myles Verdon on 26/12/2023.
//

import SwiftUI
import SwiftData

struct SelectExercise: View {
    
    @Environment(\.modelContext) var modelContext
    
    @Binding var path: NavigationPath
    var date: Date
    
    @Query var exercises: [Exercise]

    @State var searchText = ""
    @State var selectedCategories: Set<ExerciseCategory> = []
    
    var searchResults: [Exercise] {
        if searchText.isEmpty {
            return selectedCategories.isEmpty ? exercises : exercises.filter { selectedCategories.contains($0.category!) }
        } else {
            return exercises.filter { $0.name.contains(searchText) && (selectedCategories.isEmpty || selectedCategories.contains($0.category!)) }
        }
    }
    
    @Query var queriedGroups: [WorkoutGroup]
    var numGroupsInDay: Int {
        queriedGroups.filter({ Calendar.current.compare($0.date, to: date, toGranularity: .day) == .orderedSame }).count
    }
    
    
    
    var body: some View {
        List(searchResults) { exercise in
            NavigationLink(destination: {}, label: {
                HStack {
                    Circle()
                        .fill(Color.init(hex: exercise.category?.colour ?? "FFFFFF"))
                        .frame(width: 10, height: 10)
                    Text(exercise.name)
                }
            })
            .onTapGesture {
                let newGroup = WorkoutGroup(dayGroupId: numGroupsInDay, date: date)
                exercise.groups.append(newGroup)
                try! modelContext.save()
                
                path = NavigationPath([newGroup])
            }
        }
        .navigationBarTitleDisplayMode(.large)
        
        ExerciseSearchView(selectedCategories: $selectedCategories, searchText: $searchText)
    }
    
}

#Preview {
    @State var navPath = NavigationPath()
    
    return NavigationStack {
        SelectExercise(path: $navPath, date: .now)
            .modelContainer(previewContainer)
    }
}
