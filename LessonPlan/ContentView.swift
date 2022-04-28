//
//  ContentView.swift
//  LessonPlan
//
//  Created by Christopher Fouts on 1/31/22.
//

import SwiftUI

struct ContentView: View {

    @StateObject var currentState = CurrentState()
    
    var body: some View {
        NavigationView {
            
            SidebarView()
                .environmentObject(currentState)
            StackScheduleView()
                .navigationTitle("Schedule")
                .environmentObject(currentState)


        }

    }
}

class CurrentState: ObservableObject, Equatable {
    @Published var selectedDay = Date()
    
    static func == (lhs: CurrentState, rhs: CurrentState) -> Bool {
        return lhs.selectedDay == rhs.selectedDay
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

