//
//  SidebarView.swift
//  LessonPlan
//
//  Created by Christopher Fouts on 2/1/22.
//

import SwiftUI

struct SidebarView: View {
    
    @EnvironmentObject var currentState : CurrentState
    @State private var selection: String? = nil
    
    var body: some View {
        NavigationLink(destination: StackScheduleView().environmentObject(currentState), tag: "Schedule", selection: $selection) { EmptyView() }
        
        DatePicker("Choose a Date", selection: $currentState.selectedDay, displayedComponents: .date)
            .datePickerStyle(GraphicalDatePickerStyle())

        Button("Go to Date") {
           selection = "Schedule"
        }
        Spacer()
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView()
    }
}
