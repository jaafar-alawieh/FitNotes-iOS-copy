//
//  DeleteDataWarningView.swift
//  FitNotes
//
//  Created by Myles Verdon on 16/01/2024.
//

import SwiftUI
import SwiftData

struct DataDeleteWarningView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Binding var path: NavigationPath
    
    @Query private var sets: [WorkoutSet]
    @Query private var groups: [WorkoutGroup]
    @Query private var exercises: [Exercise]
    @Query private var categories: [ExerciseCategory]
    
    @State private var alertPresented = false
    @State private var confirmationString: String = ""
    @State private var isConfirmButtonEnabled = false
    @State private var shouldProgressView = false
    
    var body: some View {
        VStack(alignment: .center) {
            VStack {
                Text("Warning! This process will delete data")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                
                Text("\(sets.count) sets,  \(groups.count) groups, \(exercises.count) exercises, and \(categories.count) categories will be deleted.")
                    .multilineTextAlignment(.center)
                    .padding(30)
                
                Text("Are you sure you want to proceed? Type DELETE below to confirm.")
                    .multilineTextAlignment(.center)
                    .padding()
                    .bold()
                
                
                
                TextField("Type DELETE here", text: $confirmationString)
                    .background(Color(uiColor: .secondarySystemFill),
                                in: RoundedRectangle(cornerRadius: 5))
                    .autocapitalization(.none)
                    .multilineTextAlignment(.center)
                    .frame(width: 250)
                    .font(.title2)
                    .autocorrectionDisabled(true)
                
                
                Button("DELETE DATA", role: .destructive) {
                    alertPresented = true
                }
                .font(.title2)
                .padding()
                .buttonStyle(.borderedProminent)
                .disabled(confirmationString != "DELETE")
            
            }
            .padding()
            
        }
        .alert("Delete all data?", isPresented: $alertPresented) {
            
            Button("Cancel", role: .cancel) {}
            
            Button("Confirm Delete", role: .destructive) {
                do {
                    try modelContext.delete(model: ExerciseCategory.self)
                    try modelContext.delete(model: Exercise.self)
                    try modelContext.delete(model: WorkoutGroup.self)
                    try modelContext.delete(model: WorkoutSet.self)
                    alertPresented = false
                    shouldProgressView = true
                } catch {
                    print("Failed to delete")
                }
            }
        }
        .navigationDestination(isPresented: $shouldProgressView, destination: {
            ImportFromAndroidView(path: $path)
        })
        .navigationViewStyle(.stack)
    }
}

#Preview {
    @State var path = NavigationPath("ImportFromAndroid")
    
    return DataDeleteWarningView(path: $path)
        .modelContainer(previewContainer)
}
