//
//  DefaultArea.swift
//  Habits
//
//  Created by Nolan Gericke on 8/22/25.
//


// DefaultAreas.swift
import Foundation

struct DefaultArea {
    static let careerID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    static let financeID = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
    static let funID = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
    static let healthID = UUID(uuidString: "00000000-0000-0000-0000-000000000004")!
    static let physicalEnvironmentID = UUID(uuidString: "00000000-0000-0000-0000-000000000005")!
    static let socialID = UUID(uuidString: "00000000-0000-0000-0000-000000000006")!

    static let all: [(id: UUID, name: String)] = [
        (careerID, "Career"),
        (financeID, "Finance"),
        (funID, "Fun & Recreation"),
        (healthID, "Health"),
        (physicalEnvironmentID, "Physical Environment"),
        (socialID, "Social")
    ]
}
