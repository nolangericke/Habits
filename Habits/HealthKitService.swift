//
//  HealthKitService.swift
//  Habits
//
//  Created by Assistant on 8/26/25.
//

import Foundation
import HealthKit

final class HealthKitService {
    static let shared = HealthKitService()
    private let healthStore = HKHealthStore()
    private let energyType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
    
    private init() {}
    
    // Request authorization to read dietary energy (calories)
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        let typesToRead: Set = [energyType]
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    
    // Fetch total calories consumed in a date range
    func fetchCaloriesConsumed(start: Date, end: Date = Date(), completion: @escaping (Double?, Error?) -> Void) {
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: energyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            if let error = error {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            let calories = result?.sumQuantity()?.doubleValue(for: .kilocalorie())
            DispatchQueue.main.async {
                completion(calories, nil)
            }
        }
        healthStore.execute(query)
    }
}

