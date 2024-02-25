//
//  ContentView.swift
//  FitNotes
//
//  Created by Myles Verdon on 27/12/2023.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @State var path: NavigationPath = NavigationPath()
    @State var date: Date = .now
    
    var body: some View {
        NavigationStack(path: $path) {
            WorkoutView(date: $date)
                .navigationDestination(for: String.self) { str in
                    switch (str) {
                    case "SelectExercise":
                        SelectExercise(path: $path, date: date)
                            .navigationTitle("Select Exercise")
                            .navigationBarTitleDisplayMode(.inline)
                    case "Settings":
                        SettingsView()
                            .navigationTitle("Settings")
                    case "ImportFromAndroid":
                        DataDeleteWarningView(path: $path)
                    default:
                        Text("Unknown path")
                    }
                }
                .navigationDestination(for: WorkoutGroup.self) { group in
                    TrackView(path: $path, group: group)
                }
                .onAppear {
                    path.append("ImportFromAndroid")
                }
        }
    }
}


#Preview {
    ContentView()
        .modelContainer(previewContainer)
}
