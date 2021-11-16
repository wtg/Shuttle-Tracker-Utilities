//
//  Announcement.swift
//  Announcement Composer
//
//  Created by Gabriel Jacoby-Cooper on 11/16/21.
//

import Foundation

struct Announcement {
	
	enum ScheduleType {
		
		case none, startOnly, endOnly, startAndEnd
		
	}
	
	var subject = ""
	
	var body = ""
	
	var start = Date.now
	
	var end = Date.now + 86400
	
	var scheduleType = ScheduleType.none
	
	var hasStart: Bool {
		get {
			switch self.scheduleType {
			case .startOnly, .startAndEnd:
				return true
			default:
				return false
			}
		}
		set {
			if newValue {
				switch self.scheduleType {
				case .none:
					self.scheduleType = .startOnly
				case .endOnly:
					self.scheduleType = .startAndEnd
				default:
					break
				}
			} else {
				switch self.scheduleType {
				case .startOnly:
					self.scheduleType = .none
				case .startAndEnd:
					self.scheduleType = .endOnly
				default:
					break
				}
			}
		}
	}
	
	var hasEnd: Bool {
		get {
			switch self.scheduleType {
			case .endOnly, .startAndEnd:
				return true
			default:
				return false
			}
		}
		set {
			if newValue {
				switch self.scheduleType {
				case .none:
					self.scheduleType = .endOnly
				case .startOnly:
					self.scheduleType = .startAndEnd
				default:
					break
				}
			} else {
				switch self.scheduleType {
				case .endOnly:
					self.scheduleType = .none
				case .startAndEnd:
					self.scheduleType = .startOnly
				default:
					break
				}
			}
		}
	}
	
}
