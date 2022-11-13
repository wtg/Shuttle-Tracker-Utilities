//
//  Milestone.swift
//  Milestone Composer
//
//  Created by Gabriel Jacoby-Cooper on 3/29/22.
//

import KeyManagement

struct Milestone: Codable, Hashable, Identifiable, Signable {
	
	typealias DeletionRequest = SimpleDeletionRequest
	
	enum ProgressType: String, CaseIterable, Codable, Identifiable {
		
		case boardBusCount = "BoardBusCount"
		
		var id: String {
			get {
				return self.rawValue
			}
		}
		
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
	
	var signature: Data?
	
	var dataToSign: Data? {
		get {
			return (self.name + self.extendedDescription + self.goals.description).data(using: .utf8)
		}
	}
	
	init() {
		self.id = UUID()
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
