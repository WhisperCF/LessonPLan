//
//  Period.swift
//  LessonPlan
//
//  Created by Christopher Fouts on 1/31/22.
//

import Foundation
import CoreGraphics
import SwiftUI


enum SortingKey {
    case startTime
}

@MainActor class Schedule: ObservableObject {
    @Published private(set) var periods: [Period]
    let saveKey = "SavedData"
    var currentSortKey = SortingKey.startTime
    
    init() {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let baseURL = paths[0]
        
        do {
            let filename = baseURL.appendingPathComponent(saveKey)
            let data = try Data(contentsOf: filename)
            periods = try JSONDecoder().decode([Period].self, from: data)
        } catch {
            print("Unable to load data.")
            self.periods = []
        }
    }
    
    func sortBy(_ key: SortingKey) {
        switch key {
        case .startTime:
            do {
                periods = periods.sorted { $0.startTime < $1.startTime}
                //currentSortKey = .startTime
            }
        }
    }
    
    func add(_ period: Period)
    {
        self.periods.append(period)
    }
    
    func delete(_ period: Period) {
        if let index = periods.firstIndex(of: period) {
          periods.remove(at: index)
        }
    }
    
    static var example: Schedule {
        let schedule = Schedule()
        let testPeriod = Period(startTime: Date(), endTime: Date().addingTimeInterval(60*50), subject: "Test Subject", planDetails: "Test Details", color: Color.red)
        
        schedule.add(testPeriod)
        return schedule
    }
    
    func save() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let baseURL = paths[0]
        
        do {
            let filename = baseURL.appendingPathComponent(saveKey)
            let data = try JSONEncoder().encode(periods)
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("Unable to save data.")
        }

    }
    
}


enum CodingKeys: String, CodingKey {
    case id, startTime, endTime, subject, planDetails, color
}

class Period: ObservableObject, Identifiable, Codable, Equatable {
    var id: UUID
    @Published var startTime: Date
    @Published var endTime: Date
    @Published var subject: String
    @Published var planDetails: String
    @Published var color: Color
    
    var wrappedLength: CGFloat {
        get {
            let length = startTime.timeIntervalSince(endTime) / 60
            return CGFloat(length)
        }
    }
    
    static func == (lhs: Period, rhs: Period) -> Bool {
        return lhs.id == rhs.id
    }
    
    var timeSummary: String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        
                
        return "\(formatter.string(from:startTime)) - \(formatter.string(from: endTime))"
    }
    
    func dateMatches(_ date: Date) -> Bool {
        
        let bool =  Calendar.current.isDate(date, equalTo: self.startTime, toGranularity: .day)
        return bool
    }
    
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(subject, forKey: .subject)
        try container.encode(planDetails, forKey: .planDetails)

        if #available(iOS 14.0, *)
        {
            let convertedColor = UIColor(color)
            let colorData = try NSKeyedArchiver.archivedData(withRootObject: convertedColor, requiringSecureCoding: false)
            try container.encode(colorData, forKey: .color)
        } else
        {
            // Fallback on earlier versions
        }
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        startTime = try container.decode(Date.self, forKey: .startTime)
        endTime = try container.decode(Date.self, forKey: .endTime)
        subject = try container.decode(String.self, forKey: .subject)
        planDetails = try container.decode(String.self, forKey: .planDetails)
        let colorData = try container.decode(Data.self, forKey: .color)
        if let uiColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            color = Color(uiColor: uiColor)
        } else {
            color = Color.white
        }
    }
    
    init(startTime: Date, endTime: Date, subject: String, planDetails: String, color: Color) {
        self.id = UUID()
        self.startTime = startTime
        self.endTime = endTime
        self.subject = subject
        self.planDetails = planDetails
        self.color = color
    }
    
    init()
    {
        self.id = UUID()
        self.startTime = Date()
        self.endTime = Date().addingTimeInterval(60*60)
        self.subject = ""
        self.planDetails = ""
        self.color = Color.blue
    }

    
    static var example = Period(startTime: Date(), endTime: Date(timeIntervalSinceNow: 60*60), subject: "Spanish",  planDetails: Lorem.lorems[4], color: .red)
}
