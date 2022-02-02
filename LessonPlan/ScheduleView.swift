//
//  ScheduleView.swift
//  LessonPlan
//
//  Created by Christopher Fouts on 1/31/22.
//

import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var currentState: CurrentState
    
    @StateObject var schedule = Schedule()
    @State private var showingAddScreen = false
    let columns = [GridItem(spacing: 0, alignment:.topLeading)]
    
    var body: some View {
        
        Group {
            ScrollView {
                if (filteredSchedule.isEmpty) {
                    Text("Nothing Scheduled Yet")
                }
                LazyVGrid(columns: columns) {
                    ForEach(filteredSchedule) { period in
                        NavigationLink(destination: PeriodView(period: period, schedule: schedule)) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 25)
                                    .frame(height: max(110, period.wrappedLength * 2.5))
                                    .foregroundColor(period.color)
                                    .padding(.horizontal)
                                    .opacity(0.5)
                                VStack(alignment:.leading) {
                                    Text(period.subject)
                                        .foregroundColor(.primary)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Text(period.timeSummary)
                                        .foregroundColor(.primary)
                                        .font(.subheadline)
                                    Text(period.planDetails)
                                        .foregroundColor(.primary)
                                        .font(.subheadline)
                                        .frame(maxWidth:.infinity, idealHeight: period.wrappedLength, alignment:.topLeading)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding(30)
                            }
                            .onAppear {
                                schedule.save()
                            }
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    self.showingAddScreen.toggle()
                }, label: {
                    Image(systemName: "plus")
                })
            }
//            ToolbarItem(placement: .navigationBarLeading) {
//                EditButton()
//            }
        }
        .sheet(isPresented: $showingAddScreen) {
            AddScheduleItemView(schedule: schedule)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    var filteredSchedule : [Period] {
        let date = currentState.selectedDay
        let newArray = schedule.periods.filter { $0.dateMatches(date) }
        return newArray.sorted{ $0.startTime < $1.startTime}
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        
        ScheduleView(schedule: Schedule.example)
    }
}

struct Lorem {
    
    static var lorems = ["Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras sagittis ornare lacus. Aenean convallis, tellus at molestie fringilla, elit tortor pharetra lorem, at auctor purus urna ac orci. Donec in dui dictum, facilisis orci nec, consectetur arcu. Ut laoreet dolor id mattis aliquam. Pellentesque quis tempus ex, id interdum libero. Cras imperdiet, felis non interdum elementum, risus nulla cursus orci, non varius dui ex in mi. Integer a tortor in dui accumsan tincidunt nec quis nisl. Sed mollis leo sed massa luctus laoreet. Donec quis velit ut nibh bibendum scelerisque. Cras quis ante diam. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Nulla id felis finibus odio auctor hendrerit eget a sem. Proin tempus vulputate eros, eget porttitor sem congue nec. Etiam vulputate iaculis euismod",
        "Praesent at nulla quis ipsum sollicitudin facilisis. Vestibulum malesuada erat fermentum ultricies gravida. Pellentesque rutrum dui tortor, vitae posuere nisl tempus sed. Proin commodo malesuada diam, vel dictum elit sagittis eu. Quisque sit amet diam metus. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Donec ac sollicitudin sem. Quisque vestibulum dui sit amet augue consequat, sit amet porta ex accumsan. Phasellus efficitur ullamcorper nisi sit amet vestibulum. Etiam lobortis posuere mi, sit amet sodales neque ultrices nec. Ut quis risus leo. Etiam sit amet quam ex. Vestibulum ac nisl purus. Etiam consequat dolor vitae sapien congue tristique. Maecenas porttitor urna orci, nec dapibus metus accumsan eget. Nulla facilisi.",
        "Sed ac quam quis erat molestie aliquet vestibulum sit amet dolor. Morbi rhoncus turpis ac faucibus euismod. Integer dignissim sagittis est, ac ornare dui feugiat sed. Vivamus nec venenatis ex. Aenean posuere congue rutrum. Donec ut nisl diam. Curabitur sit amet mauris bibendum ante pulvinar molestie. Donec felis quam, volutpat et eros a, vehicula pharetra nulla. Curabitur finibus vel magna nec dictum. Cras consequat vehicula tincidunt. Donec ultrices vitae augue non sollicitudin. Sed a varius tortor. Duis sed ipsum ac erat tristique suscipit. Quisque nec lacus feugiat, bibendum diam id, auctor mi.",
        "Nunc non ornare nibh, luctus feugiat ex. Sed vestibulum nisl orci, eu accumsan nisl fringilla et. Vivamus convallis cursus justo. Pellentesque at interdum sem. Mauris non pulvinar leo. Duis vehicula turpis dui, et cursus ipsum malesuada sed. In scelerisque aliquam libero, pretium rutrum odio lacinia posuere. Curabitur fermentum sodales tellus, in malesuada neque finibus vitae.",
        "Morbi lacinia eros vitae nulla consectetur lacinia. Sed sit amet vulputate ipsum. Phasellus faucibus fermentum nulla nec mattis. Donec egestas, massa ut ultricies pulvinar, elit lacus fermentum mi, eget sagittis diam est vel lectus. Morbi feugiat consectetur lectus sit amet vulputate. Nunc consectetur nisi ac est ornare feugiat ac a lorem. Quisque at tortor gravida, tincidunt arcu quis, posuere erat. In tincidunt lorem non libero laoreet euismod. Maecenas justo justo, egestas rhoncus neque et, congue pulvinar erat. Phasellus ac consectetur lorem. Sed erat tortor, commodo id ex vitae, facilisis consequat risus."]
}
