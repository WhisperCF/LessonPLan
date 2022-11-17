//
//  StackScheduleView.swift
//  LessonPlan
//
//  Created by Christopher Fouts on 2/1/22.
//

import SwiftUI

struct StackScheduleView: View {
    
    @EnvironmentObject var currentState : CurrentState
    
    var body: some View {
        VStack {
            DaysView()
                .frame(height:100)
            ScheduleView()
                .navigationTitle(currentMonth)

        }
    }
    
    var currentMonth: String {
        let date = currentState.selectedDay
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        
        return formatter.string(from: date)
    }
}

struct StackScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        StackScheduleView()
    }
}
