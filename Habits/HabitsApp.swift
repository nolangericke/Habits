import SwiftUI
import CoreData

@main
struct HabitApp: App {
    
    init() {
        HealthKitService.shared.requestAuthorization { success, error in
            if success {
                print("HealthKit authorization granted.")
            } else {
                print("HealthKit authorization denied or failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
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
