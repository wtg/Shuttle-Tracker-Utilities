//
//  Announcement.swift
//  Announcement Composer
//
//  Created by Gabriel Jacoby-Cooper on 11/16/21.
//

import Foundation

struct Announcement: Codable, Hashable, Identifiable {
	
	enum ScheduleType: String, Codable {
		
		case none = "none"
		
		case startOnly = "startOnly"
		
		case endOnly = "endOnly"
		
		case startAndEnd = "startAndEnd"
		
	}
	
	let id: UUID
	
	var subject = "" {
		didSet {
			self.signature = nil
		}
	}
	
	var body = "" {
		didSet {
			self.signature = nil
		}
	}
	
	var start = Date.now {
		didSet {
			self.signature = nil
		}
	}
	
	var end = Date.now + 86400 {
		didSet {
			self.signature = nil
		}
	}
	
	private(set) var scheduleType = ScheduleType.none {
		didSet {
			self.signature = nil
		}
	}
	
	private var signature: Data?
	
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
			if #available(iOS 15, macOS 12, *) {
				return formatter.localizedString(for: self.start, relativeTo: .now)
			} else {
				return formatter.localizedString(for: self.start, relativeTo: Date())
			}
		}
	}
	
	var endString: String {
		get {
			let formatter = RelativeDateTimeFormatter()
			formatter.formattingContext = .dynamic
			if #available(iOS 15, macOS 12, *) {
				return formatter.localizedString(for: self.end, relativeTo: .now)
			} else {
				return formatter.localizedString(for: self.end, relativeTo: Date())
			}
		}
	}
	
	init() {
		self.id = UUID()
	}
	
	static func == (_ lhs: Announcement, _ rhs: Announcement) -> Bool {
		return lhs.id == rhs.id && lhs.subject == rhs.subject && lhs.body == rhs.body && lhs.start == rhs.start && lhs.end == rhs.end && lhs.scheduleType == rhs.scheduleType
	}
	
	mutating func sign(using keyPair: KeyPair) throws {
		guard let data = (self.subject + self.body).data(using: .utf8) else {
			throw SignatureError.dataConversionFailed
		}
		self.signature = try keyPair.signature(for: data)
	}
	
	func signatureForDeletion(using keyPair: KeyPair) throws -> Data {
		guard let data = self.id.uuidString.data(using: .utf8) else {
			throw SignatureError.dataConversionFailed
		}
		return try keyPair.signature(for: data)
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
	
}
