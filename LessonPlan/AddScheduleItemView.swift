//
//  AddScheduleItemView.swift
//  LessonPlan
//
//  Created by Christopher Fouts on 2/1/22.
//

import SwiftUI

struct AddScheduleItemView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var currentState: CurrentState
    @ObservedObject var schedule: Schedule
    
    @State private var startDate = Date.now
    @State private var endDate = Date.now.addingTimeInterval(60*60)
    @State private var subject = ""
    @State private var planDetails = ""
    @State private var color = Color.blue
    
    var body: some View {
        Form {
            TextField("Subject", text: $subject)
            TextField("Plan Details", text: $planDetails)
            DatePicker("Start", selection: $startDate)
            DatePicker("End", selection: $endDate)
                .onAppear(perform: adjustDate)
            ColorPalette(selection: $color)
            
            Section {
                Button("Save") {
                    let newPeriod = Period()
                    newPeriod.subject = subject
                    newPeriod.planDetails = planDetails
                    newPeriod.startTime = startDate
                    newPeriod.endTime = endDate
                    newPeriod.color = color
                    
                    schedule.add(newPeriod)
                    
                    self.presentationMode.wrappedValue.dismiss()
                }
                .disabled(subject.isEmpty)
                
                Button("Cancel") {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
            
        }
        .navigationTitle("Add Schedule Item")

    }
    
    func adjustDate() {
        var components = Calendar.current.dateComponents([.hour, .minute, .day, .month, .year], from: currentState.selectedDay)
        components.hour = 8
        components.minute = 0
        let newDate = Calendar.current.date(from: components) ?? Date.now
        startDate = newDate
        endDate = startDate.addingTimeInterval(60*60)
    }
}

struct AddScheduleItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddScheduleItemView(schedule: Schedule.example)
    }
}
