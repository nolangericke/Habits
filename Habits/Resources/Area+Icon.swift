//
//  Area+Icon.swift
//  Habits
//
//  Created by Nolan Gericke on 8/23/25.
//

import Foundation

extension Area {
    var iconName: String {
        switch name {
        case "Career": return "briefcase.fill"
        case "Finance": return "dollarsign"
        case "Fun & Recreation": return "figure.indoor.soccer"
        case "Health": return "heart.fill"
        case "Physical Environment": return "house.fill"
        case "Social": return "person.2.fill"
        default: return "questionmark.circle"
        }
    }
}
