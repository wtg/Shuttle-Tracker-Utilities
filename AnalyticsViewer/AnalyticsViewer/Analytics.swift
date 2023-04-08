//
//  Analytics.swift
//  AnalyticsViewer
//
//  Created by Aidan Flaherty on 4/4/23.
//

import Foundation

public enum Analytics {
    
    enum EventType: Codable, Hashable {
        
        case coldLaunch
        
        case boardBusTapped
        
        case leaveBusTapped
        
        case boardBusActivated(manual: Bool)
        
        case boardBusDeactivated(manual: Bool)
        
        case busSelectionCanceled
        
        case announcementsListOpened
        
        case announcementViewed(id: UUID)
        
        case permissionsSheetOpened
        
        case networkToastPermissionsTapped
        
        case colorBlindModeToggled(enabled: Bool)
        
        case debugModeToggled(enabled: Bool)
        
        case serverBaseURLChanged(url: URL)
        
        case locationAuthorizationStatusDidChange(authorizationStatus: Int)
        
        case locationAccuracyAuthorizationDidChange(accuracyAuthorization: Int)
        
    }
    
    struct UserSettings: Codable, Hashable, Equatable {
        
        let colorScheme: String?
        
        let colorBlindMode: Bool
        
        let debugMode: Bool?
        
        let logging: Bool?
        
        let maximumStopDistance: Int?
        
        let serverBaseURL: URL?
        
    }
    
    struct Entry: Hashable, Codable, Identifiable {
        
        enum ClientPlatform: String, Codable, Hashable, Equatable {
            
            case ios, macos
            
        }
        
        let id: UUID
        
        let userID: UUID
        
        let date: Date
        
        let clientPlatform: ClientPlatform
        
        let clientPlatformVersion: String
        
        let appVersion: String
        
        let boardBusCount: Int?
        
        let userSettings: UserSettings
        
        let eventType: EventType
    }
}
