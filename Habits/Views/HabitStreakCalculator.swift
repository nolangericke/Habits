//  HabitStreakCalculator.swift
//  Habits
//
//  Created by Assistant on 8/23/25.

import Foundation

struct HabitStreakCalculator {
    /// Calculates the current streak for the given habit and completions, including 'grace time' (today counts if streak can still be saved).
    /// - Parameters:
    ///   - habit: The habit to check streak for.
    ///   - completions: All completions (should include all for this habit, not filtered by day).
    ///   - calendar: Calendar to use, defaults to current.
    ///   - now: Current date, defaults to now. Useful for testing.
    /// - Returns: The number of consecutive days with completion, including 'grace' for today if streak can still be saved.
    static func streak(for habit: Habit, completions: [HabitCompletion], calendar: Calendar = .current, now: Date = Date()) -> Int {
        guard let habitId = habit.id else { return 0 }
        // Extract all completion dates for this habit, stripped to day-granularity
        let compDates: Set<Date> = Set(
            completions
                .filter { $0.habit?.id == habitId && $0.date != nil }
                .compactMap { $0.date }
                .map { calendar.startOfDay(for: $0) }
        )
        let today = calendar.startOfDay(for: now)
        var streak = 0
        var day = today
        
        if compDates.contains(day) {
            // Today completed, count it and count backwards
            streak += 1
            while true {
                guard let prevDay = calendar.date(byAdding: .day, value: -1, to: day) else { break }
                if compDates.contains(prevDay) {
                    streak += 1
                    day = prevDay
                } else {
                    break
                }
            }
        } else {
            // Today not completed, check if yesterday completed to allow 'grace time'
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return 0 }
            if compDates.contains(yesterday) {
                streak += 1
                day = yesterday
                // Count backwards from yesterday
                while true {
                    guard let prevDay = calendar.date(byAdding: .day, value: -1, to: day) else { break }
                    if compDates.contains(prevDay) {
                        streak += 1
                        day = prevDay
                    } else {
                        break
                    }
                }
            } else {
                // No streak possible if yesterday also missed
                streak = 0
            }
        }
        
        return streak
    }
    
    /// Calculates the consecutive day streak for which ALL habits were completed.
    /// - Parameters:
    ///   - habits: The list of habits to consider.
    ///   - completions: All completions.
    ///   - calendar: Calendar to use, defaults to current.
    ///   - now: Current date, defaults to now. Useful for testing.
    /// - Returns: The number of consecutive days where all habits were completed.
    static func dailyStreakForAllHabits(habits: [Habit], completions: [HabitCompletion], calendar: Calendar = .current, now: Date = Date()) -> Int {
        guard !habits.isEmpty else { return 0 }
        let habitIds = habits.compactMap { $0.id }
        let completionDict = Dictionary(grouping: completions, by: {
            calendar.startOfDay(for: $0.date ?? Date.distantPast)
        })
        var streak = 0
        var day = calendar.startOfDay(for: now)
        var graceDayChecked = false
        while true {
            // For each habit, did it get a completion for this day?
            let dailyCompletions = completionDict[day] ?? []
            let completedHabitIds = Set(dailyCompletions.compactMap { $0.habit?.id })
            // If all habit IDs are in completedHabitIds, streak continues
            if Set(habitIds).isSubset(of: completedHabitIds) {
                streak += 1
            } else if !graceDayChecked {
                // Allow 'grace' for today: If today was missed but yesterday met the condition, allow the streak to continue (if savable)
                graceDayChecked = true
                if let prevDay = calendar.date(byAdding: .day, value: -1, to: day) {
                    day = prevDay
                    continue
                }
            } else {
                break
            }
            if let prevDay = calendar.date(byAdding: .day, value: -1, to: day) {
                day = prevDay
            } else {
                break
            }
        }
        return streak
    }
}
