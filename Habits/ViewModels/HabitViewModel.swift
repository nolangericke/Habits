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

extension Habit {
    var habitTypeEnum: HabitType {
        get { HabitType(rawValue: self.type ?? "generic") ?? .generic }
        set { self.type = newValue.rawValue }
    }
}

enum HabitType: String {
    case generic
    case calorie
    // Add more as needed, e.g. time, steps
}

class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var completions: [HabitCompletion] = []
    @Published var areas: [Area] = []
    @Published var routines: [Routine] = []
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchHabits()
        fetchCompletions()
        fetchAreas()
        fetchRoutines()
        seedDefaultAreasIfNeeded()
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
    func addHabit(name: String, area: Area, routine: Routine?, type: HabitType = .generic, targetValue: Double? = nil) {
        let habit = Habit(context: context)
        habit.name = name
        habit.id = UUID()
        habit.createdAt = Date()
        habit.area = area
        habit.routine = routine // routine is optional
        habit.type = type.rawValue
        save()
        if type == .calorie, let val = targetValue {
            addHabitTarget(to: habit, value: val)
        } else {
            fetchHabits()
        }
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
    
    func updateHabitType(_ habit: Habit, to newType: HabitType) {
        habit.habitTypeEnum = newType
        save()
        fetchHabits()
    }
    
    func setCurrentHabitTarget(for habit: Habit, value: Double, startDate: Date = Date()) {
        // End any current target
        if let current = currentTarget(for: habit) {
            current.endDate = startDate
        }
        // Add new target
        addHabitTarget(to: habit, value: value, startDate: startDate)
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
    
    private func seedDefaultAreasIfNeeded() {
        let request: NSFetchRequest<Area> = Area.fetchRequest()
        do {
            let existingAreas = try context.fetch(request)
            if existingAreas.isEmpty {
                for defaultInfo in DefaultArea.all {
                    let area = Area(context: context)
                    area.id = defaultInfo.id
                    area.name = defaultInfo.name
                }
                save()
                fetchAreas()
            }
        } catch {
            print("Error seeding default areas: \(error)")
        }
    }
    
    // MARK: - Routine CRUD
    
    func fetchRoutines() {
        let request: NSFetchRequest<Routine> = Routine.fetchRequest()
        do {
            routines = try context.fetch(request)
        } catch {
            print("Error fetching routines: \(error)")
        }
    }

    func addRoutine(name: String) {
        let routine = Routine(context: context)
        routine.name = name
        routine.id = UUID()
        save()
        fetchRoutines()
    }

    func updateRoutine(_ routine: Routine, name: String) {
        routine.name = name
        save()
        fetchRoutines()
    }

    func deleteRoutine(_ routine: Routine) {
        context.delete(routine)
        save()
        fetchRoutines()
    }
    
    // MARK: - Habit Completion Functions
    
    func isHabitCompletedToday(_ habit: Habit) -> Bool {
        guard let habitId = habit.id else { return false }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return completions.contains(where: { completion in
            completion.habit?.id == habitId &&
            completion.date != nil &&
            calendar.isDate(completion.date!, inSameDayAs: today)
        })
    }
    
    func toggleHabitCompletion(_ habit: Habit) {
        if let completion = completions.first(where: { comp in
            comp.habit?.id == habit.id && comp.date != nil && Calendar.current.isDateInToday(comp.date!)
        }) {
            deleteCompletion(completion)
        } else {
            addCompletion(for: habit)
        }
    }
    
    // MARK: - HabitTarget CRUD
    func addHabitTarget(to habit: Habit, value: Double, startDate: Date = Date(), endDate: Date? = nil) {
        let target = HabitTarget(context: context)
        target.value = value
        target.startDate = startDate
        target.endDate = endDate
        target.habit = habit
        save()
        fetchHabits()
    }
    
    func updateHabitTarget(_ target: HabitTarget, value: Double, endDate: Date? = nil) {
        target.value = value
        if let end = endDate {
            target.endDate = end
        }
        save()
        fetchHabits()
    }
    
    func deleteHabitTarget(_ target: HabitTarget) {
        context.delete(target)
        save()
        fetchHabits()
    }
    
    func currentTarget(for habit: Habit) -> HabitTarget? {
        let now = Date()
        let targets = (habit.habitTarget as? Set<HabitTarget>) ?? []
        return targets.first(where: { $0.endDate == nil || ($0.endDate ?? now) > now })
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

