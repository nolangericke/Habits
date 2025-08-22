//
//  HabitListView.swift
//  Habits
//
//  Created by Nolan Gericke on 8/20/25.
//

import SwiftUI

struct HabitListView: View {
    var body: some View {
        NavigationStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .toolbar {
                ToolbarSpacer(placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        print("Add Habit Pressed")
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    HabitListView()
}
