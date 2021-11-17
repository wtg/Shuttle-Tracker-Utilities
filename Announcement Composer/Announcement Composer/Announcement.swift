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
	
	private var scheduleType = ScheduleType.none {
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
	
	mutating func sign(with keyPair: KeyPair) throws {
		guard let data = (self.subject + self.body).data(using: .utf8) else {
			throw SignatureError.dataConversionFailed
		}
		self.signature = try keyPair.sign(data)
	}
	
}
