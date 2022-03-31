//
//  Milestone.swift
//  Milestone Composer
//
//  Created by Gabriel Jacoby-Cooper on 3/29/22.
//

import SwiftUI
import KeyManagement

struct Milestone: Codable, Hashable, Identifiable {
	
	enum ProgressType: String, Codable, IdentifiableByHashValue {
		
		case boardBusCount = "BoardBusCount"
		
		static let all: [ProgressType] = [.boardBusCount]
		
	}
	
	struct DeletionRequest: Encodable {
		
		let signature: Data
		
	}
	
	final class GoalHandle: Comparable, Identifiable {
		
		let goal: Int
		
		let index: Int
		
		fileprivate init(_ goal: Int, index: Int) {
			self.goal = goal
			self.index = index
		}
		
		static func == (_ lhs: GoalHandle, _ rhs: GoalHandle) -> Bool {
			return lhs.index == rhs.index
		}
		
		static func < (_ lhs: GoalHandle, _ rhs: GoalHandle) -> Bool {
			return lhs.goal < rhs.goal
		}
		
	}
	
	let id: UUID
	
	var name = "" {
		willSet {
			self.signature = nil
		}
	}
	
	var extendedDescription = "" {
		willSet {
			self.signature = nil
		}
	}
	
	var progress: Int = 0
	
	var progressType: ProgressType? {
		willSet {
			self.signature = nil
		}
	}
	
	var goals: [Int] = [] {
		willSet {
			self.signature = nil
		}
	}
	
	var goalHandles: [GoalHandle] {
		get {
			return self.goals
				.enumerated()
				.map { (index, goal) in
					return GoalHandle(goal, index: index)
				}
		}
	}
	
	private(set) var signature: Data?
	
	init() {
		self.id = UUID()
	}
	
	private init(asSignedVersionOf unsignedMilestone: Milestone, using keyPair: KeyPair) throws {
		self = unsignedMilestone
		guard let data = (self.name + self.extendedDescription + self.goals.description).data(using: .utf8) else {
			throw SignatureError.dataConversionFailed
		}
		self.signature = try keyPair.signature(for: data)
	}
	
	func signed(using keyPair: KeyPair) throws -> Milestone {
		return try Milestone(asSignedVersionOf: self, using: keyPair)
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

extension Array where Element == Int {
	
	mutating func ensurePositive() {
		for index in self.indices {
			if self[index] <= 0 {
				self[index] = 1
			}
		}
	}
	
}
