//
//  HabitViewModel.swift
//  Habits
//
//  Created by Nolan Gericke on 8/22/25.
//

import Foundation
import Combine
import SwiftUI
import CoreData

class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var completions: [HabitCompletion] = []
    @Published var areas: [Area] = []
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchHabits()
        fetchCompletions()
        fetchAreas()
    }
    
    // MARK: - Habit CRUD
    func fetchHabits() {
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        do {
            habits = try context.fetch(request)
        } catch {
            print("Error fetching habits: \(error)")
        }
    }
    func addHabit(name: String, area: Area) {
        let habit = Habit(context: context)
        habit.name = name
        habit.id = UUID()
        habit.createdAt = Date()
        habit.area = area
        save()
        fetchHabits()
    }
    func updateHabit(_ habit: Habit, name: String) {
        habit.name = name
        save()
        fetchHabits()
    }
    func deleteHabit(_ habit: Habit) {
        context.delete(habit)
        save()
        fetchHabits()
    }
    
    // MARK: - HabitCompletion CRUD
    func fetchCompletions() {
        let request: NSFetchRequest<HabitCompletion> = HabitCompletion.fetchRequest()
        do {
            completions = try context.fetch(request)
        } catch {
            print("Error fetching completions: \(error)")
        }
    }
    func addCompletion(for habit: Habit, date: Date = Date()) {
        let completion = HabitCompletion(context: context)
        completion.date = date
        completion.habit = habit
        save()
        fetchCompletions()
    }
    func deleteCompletion(_ completion: HabitCompletion) {
        context.delete(completion)
        save()
        fetchCompletions()
    }
    
    // MARK: - Area CRUD
    func fetchAreas() {
        let request: NSFetchRequest<Area> = Area.fetchRequest()
        do {
            areas = try context.fetch(request)
        } catch {
            print("Error fetching areas: \(error)")
        }
    }
    func addArea(name: String) {
        let area = Area(context: context)
        area.name = name
        area.id = UUID()
        save()
        fetchAreas()
    }
    func updateArea(_ area: Area, name: String) {
        area.name = name
        save()
        fetchAreas()
    }
    func deleteArea(_ area: Area) {
        context.delete(area)
        save()
        fetchAreas()
    }
    
    
    // MARK: - Save Helper
    private func save() {
        do {
            try context.save()
        } catch {
            print("Core Data save error: \(error)")
            context.rollback()
        }
    }
}

