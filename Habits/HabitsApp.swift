//
//  HabitsApp.swift
//  Habits
//
//  Created by Nolan Gericke on 8/20/25.
//

import SwiftUI
import CoreData

@main
struct HabitsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
