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


let containerIdentifier = "iCloud.net.applewriter.planify";

@MainActor class Schedule: ObservableObject {
    @Published private(set) var periods: [Period]
    let saveKey = "SavedData"
    var currentSortKey = SortingKey.startTime
    var usingiCloud = true
    var fm = FileManager.default
    var iCloudToken: (any NSCoding & NSCopying & NSObjectProtocol)?
    var iCloudQuery: NSMetadataQuery
    
    var iCloudSavePath: URL?
        

    
    init() {
        
        let nc = NotificationCenter.default
        
        var filename: URL
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let baseURL = paths[0]
        
        filename = baseURL.appendingPathComponent(saveKey)
        iCloudToken = fm.ubiquityIdentityToken
        
        if usingiCloud && iCloudToken != nil {
            
            //if let containerUrl = fm.url(forUbiquityContainerIdentifier: containerIdentifier)?.appendingPathComponent("Documents/") {
                
                let fileUrl =  fm.url(forUbiquityContainerIdentifier: containerIdentifier)?.appendingPathComponent(saveKey)
                
                iCloudSavePath = fileUrl
                

           // }
            
            if let iCloudURL = iCloudSavePath {
                filename = iCloudURL
                
                if !FileManager.default.fileExists(atPath: filename.path, isDirectory: nil) {
                    do {
                        try fm.createDirectory(at: filename, withIntermediateDirectories: true, attributes: nil)
                    }
                    catch {
                        print(error.localizedDescription)
                    }
                }
            }
            
            do {
                try fm.startDownloadingUbiquitousItem(at: filename)
            } catch {
                print(error.localizedDescription)
            }
            
        }


        do {
            let data = try Data(contentsOf: filename)
            //print(String(data: data, encoding: .utf8))
            periods = try JSONDecoder().decode([Period].self, from: data)
        } catch {
            print("Unable to load data. \(error.localizedDescription)")
            self.periods = []
        }
        
        iCloudQuery = NSMetadataQuery()
        iCloudQuery.searchScopes = [NSMetadataQueryUbiquitousDataScope]
        let predicate = NSPredicate(format: "%K like '*'", NSMetadataItemFSNameKey)
        iCloudQuery.predicate = predicate
        
        let started = iCloudQuery.start()
        
        if !started {
            print("there was a problem...")
        }
        
        nc.addObserver(self, selector: #selector(updateFromCloud), name: NSNotification.Name.NSMetadataQueryDidUpdate, object: nil)
        nc.addObserver(self, selector: #selector(updateFromCloud), name: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: nil)
        
    }
    
    @objc func updateFromCloud() {
        
        iCloudQuery.stop()
        
        if let filename = iCloudSavePath {
            do {
                let data = try Data(contentsOf: filename)
                //print(String(data: data, encoding: .utf8))
                periods = try JSONDecoder().decode([Period].self, from: data)
            } catch {
                print("iCloud Update Error. \(error.localizedDescription)")
            }
        }
        
        iCloudQuery = NSMetadataQuery()
        iCloudQuery.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        let predicate = NSPredicate(format: "%K like '*'", NSMetadataItemFSNameKey)
        iCloudQuery.predicate = predicate
        
        let started = iCloudQuery.start()
        
        if !started {
            print("there was a problem...")
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

        do {
            var filename: URL
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let baseURL = paths[0]
            filename = baseURL.appendingPathComponent(saveKey)
            
            let data = try JSONEncoder().encode(periods)
            
            if usingiCloud {
                if let iCloudPath = iCloudSavePath {
                    try data.write(to: iCloudPath)
                }
            } else {
                try data.write(to: filename, options: [.atomicWrite])
            }

            if usingiCloud && fm.fileExists(atPath: filename.absoluteString) {
                do {
                    try fm.setUbiquitous(true, itemAt: filename, destinationURL: iCloudSavePath!)
                } catch {
                    print(error.localizedDescription)
                }
            }
            
        } catch {
            print("Unable to save data: \(error.localizedDescription)")
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
            let length = endTime.timeIntervalSince(startTime) / 60
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
