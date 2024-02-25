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
    
    
    @Query var queriedGroups: [WorkoutGroup]
    var numGroupsInDay: Int {
        queriedGroups.filter({ Calendar.current.compare($0.date, to: date, toGranularity: .day) == .orderedSame }).count
    }
    
    @State var searchText = ""
    
    @Query var exercises: [Exercise]
    var searchResults: [Exercise] {
        if searchText.isEmpty {
            return exercises
        } else {
            return exercises.filter { $0.name.contains(searchText) }
        }
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
            }).onTapGesture {
                let newGroup = WorkoutGroup(dayGroupId: numGroupsInDay, date: date, exercise: exercise)
                modelContext.insert(newGroup)
                path = NavigationPath([newGroup])
            }
        }
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
    }
    
}

#Preview {
    @State var navPath = NavigationPath()
    
    return NavigationStack {
        SelectExercise(path: $navPath, date: .now)
            .modelContainer(previewContainer)
    }
}
