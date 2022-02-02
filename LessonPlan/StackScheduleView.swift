//
//  StackScheduleView.swift
//  LessonPlan
//
//  Created by Christopher Fouts on 2/1/22.
//

import SwiftUI

struct StackScheduleView: View {
    var body: some View {
        VStack {
            DaysView()
                .frame(height:100)
            ScheduleView()
        }
    }
}

struct StackScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        StackScheduleView()
    }
}
