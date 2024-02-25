//
//  FitNotesApp.swift
//  FitNotes
//
//  Created by Myles Verdon on 22/12/2023.
//

import SwiftUI
import SwiftData

@main
struct FitNotesApp: App {
    
    var body: some Scene {
        
        WindowGroup {
            ContentView()
        }
        .modelContainer(AppModelContainer)
    }
}
