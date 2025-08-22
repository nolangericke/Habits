//
//  HabitListView.swift
//  Habits
//
//  Created by Nolan Gericke on 8/20/25.
//

import SwiftUI

struct HabitListView: View {
    
    @State private var showingAddHabit = false
    
    var body: some View {
        NavigationStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .toolbar {
                ToolbarSpacer(placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        showingAddHabit = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView()
            }
        }
    }
}

#Preview {
    HabitListView()
}
