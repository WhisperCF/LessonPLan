//
//  PeriodView.swift
//  LessonPlan
//
//  Created by Christopher Fouts on 1/31/22.
//

import SwiftUI

struct PeriodView: View {
    @ObservedObject var period: Period
    @ObservedObject var schedule: Schedule
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var currentState: CurrentState
    
    
    var body: some View {
        Form {
            TextField("Subject", text: $period.subject)
            TextField("Plan Details", text: $period.planDetails)
            DatePicker("Start", selection: $period.startTime)
            DatePicker("End", selection: $period.endTime)
            ColorPalette(selection: $period.color)
            
            Section {
                Button("Close") {
                    
                    self.presentationMode.wrappedValue.dismiss()
                }
                .disabled(period.subject.isEmpty)
            }
            Section {
                Button(role: .destructive) {
                    schedule.delete(period)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
            
        }
        .navigationTitle("Edit Schedule Item")
    }
}

//struct PeriodView_Previews: PreviewProvider {
//    static var previews: some View {
//
//        PeriodView(period: Period.example)
//    }
//}
