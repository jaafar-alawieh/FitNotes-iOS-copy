//
//  SwiftUIView.swift
//  FitNotes
//
//  Created by Myles Verdon on 22/12/2023.
//

import SwiftUI
import SwiftData

struct WorkoutView: View {
    
    @Environment(\.modelContext) private var modelContext

    @Binding var date: Date
    
    @State private var isCalendarPresented = false
    
    //    @AppStorage("initialized") var initialized: Bool = false
    
    var body: some View {
        VStack {
            
            if (isCalendarPresented) {
                DatePicker(
                    "Start Date",
                    selection: $date,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
            }
            
            // Date left/right
            HStack {
                Button(action: {
                    date = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? .now
                }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(dateFormatter.string(from: date))
                    .onTapGesture {
                        date = .now
                    }
                Spacer()
                Button(action: {
                    date = Calendar.current.date(byAdding: .day, value: 1, to: date) ?? .now
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            ScrollView {
                ExerciseGroupListView(date: date)
                Spacer()
            }
            Spacer()
            
            // Track exercise button
            NavigationLink(value: "SelectExercise", label: {
                HStack {
                    Text("Track Exercise").foregroundStyle(Color.white)
                    Image(systemName: "plus").foregroundStyle(Color.white)
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            })
        }
        .navigationBarTitle("Workout", displayMode: .inline)
        .navigationBarItems(
            leading: NavigationLink(value: "Settings")  {
                Image(systemName: "gear")
            },
            trailing: Button(action: {
                isCalendarPresented.toggle()
            }) {
                Image(systemName: "calendar")
            }
        )
    }
}


private var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE d MMM YYYY"
    return formatter
}


func compareDatesIgnoringTime(date1: Date, date2: Date) -> ComparisonResult {
    let calendar = Calendar.current
    
    let components1 = calendar.dateComponents([.year, .month, .day], from: date1)
    let components2 = calendar.dateComponents([.year, .month, .day], from: date2)
    
    guard let newDate1 = calendar.date(from: components1),
          let newDate2 = calendar.date(from: components2) else {
        return .orderedSame
    }
    
    return newDate1.compare(newDate2)
}
