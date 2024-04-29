//
//  SwiftUIView.swift
//  FitNotes
//
//  Created by Myles Verdon on 27/12/2023.
//

import SwiftUI
import SwiftData

struct TrackView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Binding var path: NavigationPath
    var group: WorkoutGroup
    
    @AppStorage("defaultWeightUnit") var defaultWeightUnit: WeightUnitSetting = WeightUnitSetting.kg
    @AppStorage("defaultDistanceUnit") var defaultDistanceUnit: DistanceUnitSetting = DistanceUnitSetting.kilometers
    @AppStorage("defaultTimeUnit") var defaultTimeUnit: TimeUnitSetting = TimeUnitSetting.seconds
    
    @State var reps: Double? = 0
    @State var weight: Double? = 0
    @State var distance: Double? = 0
    @State var time: Double? = 0
    
    @State var selectedSet: WorkoutSet? = nil
    
    @State var isEditExerciseSheetOpen: Bool = false
    
    @Query var sets: [WorkoutSet]
    
    var exercise: Exercise
    
    init(path: Binding<NavigationPath>, group: WorkoutGroup) {
        
        if (group.exercise == nil) {
            path.wrappedValue.removeLast()
        }
        self.exercise = group.exercise!
        
        _path = path
        
        self.group = group
        let groupID = group.persistentModelID
        self._sets = Query(filter: #Predicate<WorkoutSet> { set in
            set.group?.persistentModelID == groupID
        }, sort: \WorkoutSet.id)
        
        
    }
    
    private func save() {
        let newSet = WorkoutSet(id: sets.count + 1,
                                reps: reps ?? 0,
                                weightKilograms: exercise.weight_unit.toMetric(weight: weight ?? 0, defaultUnit: defaultWeightUnit),
                                distanceMeters: exercise.distance_unit.toMetric(distance: distance ?? 0, defaultUnit: defaultDistanceUnit),
                                timeSeconds: exercise.time_unit.toMetric(time: time ?? 0, defaultUnit: defaultTimeUnit),
                                is_personal_record: false)
        group.entries.append(newSet)
        
    }
    
    private func update() {
        
        if (selectedSet == nil) { return }
        
        // Update values if used by exercise
        selectedSet!.reps = exercise.uses_reps ? reps ?? 0 : selectedSet!.reps
        selectedSet!.weightKilograms = exercise.uses_weight ? exercise.weight_unit.toMetric(weight: weight ?? 0, defaultUnit: defaultWeightUnit) : selectedSet!.weightKilograms
        selectedSet!.distanceMeters = exercise.uses_distance ? exercise.distance_unit.toMetric(distance: distance ?? 0, defaultUnit: defaultDistanceUnit) : selectedSet!.distanceMeters
        selectedSet!.timeSeconds = exercise.uses_distance ? exercise.time_unit.toMetric(time: time ?? 0, defaultUnit: defaultTimeUnit) : selectedSet!.timeSeconds
        
        selectedSet = nil
    }
    
    private func delete() {
        hideKeyboard()
        if (selectedSet != nil) {
            var i = 1
            for set in sets {
                if (set != selectedSet) {
                    set.id = i
                    i += 1
                }
            }
            modelContext.delete(selectedSet!)
            selectedSet = nil
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                VStack {
                    
                    HStack {
                        if (exercise.uses_reps) {
                            NumericInputView(value: $reps, title: "Reps", incrementAmount: 1)
                        }
                        if (exercise.uses_distance) {
                            NumericInputView(value: $distance, title: "Distance", incrementAmount: exercise.distance_increment ?? 2.5)
                        }
                    }
                    
                    HStack {
                        if (exercise.uses_weight) {
                            NumericInputView(value: $weight, title: "Weight", incrementAmount: exercise.weight_increment ?? 2.5)
                        }
                        if (exercise.uses_time) {
                            NumericInputView(value: $time, title: "Time", incrementAmount: exercise.time_increment ?? 2.5)
                        }
                    }
                    
                    // Action buttons
                    HStack {
                        if (selectedSet != nil) {
                            Button(action: delete) {
                                Text("Delete")
                                    .frame(width: 125, height: 40)
                                    .background(.purple)
                                    .cornerRadius(8)
                            }
                            Button(action: {
                                hideKeyboard()
                                update()
                            }) {
                                Text("Update")
                                    .frame(width: 125, height: 40)
                                    .background(.blue)
                                    .cornerRadius(8)
                                    .disabled(reps == nil || weight == nil || distance == nil || time == nil)
                            }
                            
                        } else {
                            Button(action: {
                                hideKeyboard()
                                save()
                            }) {
                                Text("Save")
                                    .frame(width: 200, height: 40)
                                    .background(.green)
                                    .cornerRadius(8)
                                    .disabled(reps == nil || weight == nil || distance == nil || time == nil)
                            }
                        }
                    }
                    .padding(.top, 12)
                    .font(.system(size: 18))
                    .bold()
                    .foregroundColor(.white)
                }
                .padding(.vertical, 8)
                
                // List of sets complete (todo: upcoming)
                SetListView(group: group, sets: sets, selectedSet: $selectedSet)
                    .onChange(of: selectedSet) { _, set in
                        if (selectedSet != nil) {
                            reps = set!.reps
                            weight = exercise.weight_unit.fromMetric(weight: set!.weightKilograms, defaultUnit: defaultWeightUnit)
                            distance = exercise.distance_unit.fromMetric(distance: set!.distanceMeters, defaultUnit: defaultDistanceUnit)
                            time = exercise.time_unit.fromMetric(time: set!.timeSeconds, defaultUnit: defaultTimeUnit)
                        }
                    }
            }
            .onAppear {
                print("HEREHRERE")
            }
            .frame(width: geometry.size.width)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar() {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        if (group.entries.isEmpty) {
                            modelContext.delete(group)
                        }
                        path = NavigationPath()
                    } label: {
                        HStack(spacing: 2) {
                            Image(systemName: "chevron.left")
                            Text("Workout")
                        }
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(exercise.name)
                        .bold()
                        .onTapGesture {
                            isEditExerciseSheetOpen.toggle()
                        }
                }
                //                ToolbarItemGroup(placement: .keyboard) {
                //                    Spacer()
                //                    Button("Done") {
                //                        hideKeyboard()
                //                    }
                //                }
                
            }.sheet(isPresented: $isEditExerciseSheetOpen, content: {
                ManageExerciseView()
            })
            .background(
                Rectangle()
                    .fill(.black.opacity(0))
                    .contentShape(.rect)
                    .frame(width: geometry.size.width)
                    .onTapGesture {
                        hideKeyboard()
                        selectedSet = nil
                    })
        }
    }
}
