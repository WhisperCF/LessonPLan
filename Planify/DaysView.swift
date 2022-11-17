//
//  DaysView.swift
//  LessonPlan
//
//  Created by Christopher Fouts on 1/31/22.
//

import SwiftUI



struct DaysView: View {
    
    @EnvironmentObject var currentState: CurrentState
    
    @State private var date = Date.now
    @State private var days = [0]
    @State private var selectedDay = 0
    @State private var month = ""
    @State private var circleSize: CGFloat = 30
    @State private var sizeModifier: CGFloat = 1
    let columns = [GridItem(spacing: 0)]
    
    var body: some View {
        Group {
            VStack {
//                Text(month)
//                    .font(.subheadline)
//                    .fontWeight(.semibold)
                
                ScrollView(.horizontal) {
                    ScrollViewReader { value in
                        LazyHGrid(rows: columns, spacing: 10) {
                            ForEach(days, id:\.self) { day in
                                ZStack {
                                    if selectedDay == day {
                                        Circle()
                                            .foregroundColor(.blue)
                                            .frame(width: circleSize )
                                            .scaleEffect(sizeModifier)
                                            .animation(.easeInOut(duration: 0.3), value: sizeModifier)
                                            
                                        Text("\(day)")
                                            .foregroundColor(.white)
                                        
                                    } else {
                                        Circle()
                                            .foregroundColor(.blue)
                                            .frame(width: circleSize, height: circleSize)
                                            .opacity(0.7)
                                        
                                        Text("\(day)")
                                            .foregroundColor(.white)
                                    }

                                }
                                .minimumScaleFactor(0.2)
                                .onChange(of: currentState.selectedDay) { newValue in
                                    date = newValue
                                    update()
                                }
                                .onTapGesture {
                                    sizeModifier = 1
                                    selectDay(day)
                                }

                            }
                        }
                        .padding(.horizontal)
                        .onChange(of:selectedDay) { action in
                            value.scrollTo(selectedDay)
                            sizeModifier = 1.4
                        }
                    }
                }
                .padding(.horizontal, 30)
                .onAppear{
                    date = currentState.selectedDay
                    update()
                }
            }
        }
    }
    
    func update() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        
        let calendar = Calendar.current
        
        let range = calendar.range(of: .day, in: .month, for: date)
        
        if let unwrapped = range {
            days =  Array(unwrapped)
        }
        
        let components  = calendar.dateComponents([.day], from: date)
        selectedDay = components.day ?? 1
        
        currentState.selectedDay = date
        month = formatter.string(from: date)
    }
    
    func selectDay(_ day: Int) {
        var components = Calendar.current.dateComponents([.hour, .minute, .day, .month, .year], from: Date.now)
        components.day = day
        let newDate = Calendar.current.date(from: components) ?? Date.now
        
        date = newDate
        
        selectedDay = day
        currentState.selectedDay = date
        
        
    }
    
    
}

struct DaysView_Previews: PreviewProvider {
    static var previews: some View {
        DaysView()
    }
}
