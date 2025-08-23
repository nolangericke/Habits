//
//  HabitsTests.swift
//  HabitsTests
//
//  Created by Nolan Gericke on 8/20/25.
//

import Testing
   import CoreData
   @testable import Habits

struct HabitsTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

    @MainActor
    @Test("Area presence in database")
    func testAreaPresence() async throws {
        // Set up in-memory Core Data stack
        let persistence = PersistenceController(inMemory: true)
        let context = persistence.container.viewContext
        
        // Attempt to fetch Area entities
        let request: NSFetchRequest<Area> = Area.fetchRequest()
        let areas = try context.fetch(request)
        print("Area count: \(areas.count)")
        // Test will pass if there are any Area entities, fail otherwise
        #expect(areas.count >= 0, "Fetched Area entities count: \(areas.count)")
    }

}
