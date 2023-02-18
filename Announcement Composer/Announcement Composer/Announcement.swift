//
//  Announcement.swift
//  Announcement Composer
//
//  Created by Gabriel Jacoby-Cooper on 11/16/21.
//

import KeyManagement

struct Announcement: Codable, Hashable, Identifiable, Signable {
	
	typealias DeletionRequest = SimpleDeletionRequest
	
	enum ScheduleType: String, Codable {
		
		case none, startOnly, endOnly, startAndEnd
		
	}
	
	enum InterruptionLevel: String, Codable, Identifiable {
		
		case passive, active, timeSensitive, critical
		
		var id: Self {
			get {
				return self
			}
		}
		
	}
	
	let id: UUID
	
	var subject = "" {
		willSet {
			self.signature = nil
		}
	}
	
	var body = "" {
		willSet {
			self.signature = nil
		}
	}
	
	var start = Date.now
	
	var end = Date.now + 86400
	
	private(set) var scheduleType = ScheduleType.none
	
	var interruptionLevel: InterruptionLevel = .passive
	
	var signature: Data?
	
	var dataToSign: Data? {
		get {
			return (self.subject + self.body).data(using: .utf8)
		}
	}
	
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
	
	var startString: String {
		get {
			let formatter = RelativeDateTimeFormatter()
			formatter.formattingContext = .dynamic
			return formatter.localizedString(for: self.start, relativeTo: .now)
		}
	}
	
	var endString: String {
		get {
			let formatter = RelativeDateTimeFormatter()
			formatter.formattingContext = .dynamic
			return formatter.localizedString(for: self.end, relativeTo: .now)
		}
	}
	
	init() {
		self.id = UUID()
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
	
	static func == (lhs: Announcement, rhs: Announcement) -> Bool {
		return lhs.id == rhs.id && lhs.subject == rhs.subject && lhs.body == rhs.body && lhs.start == rhs.start && lhs.end == rhs.end && lhs.scheduleType == rhs.scheduleType && lhs.interruptionLevel == rhs.interruptionLevel
	}
	
}
