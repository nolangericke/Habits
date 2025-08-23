import SwiftUI
import CoreData

@main
struct HabitApp: App {
    
    init() {
        print("HabitApp is starting up!")
    }
    
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            let habitViewModel = HabitViewModel(context: persistenceController.container.viewContext)
            HabitListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(habitViewModel)
        }
    }
}
