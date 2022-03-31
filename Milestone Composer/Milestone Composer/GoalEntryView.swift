//
//  GoalEntryView.swift
//  Milestone Composer
//
//  Created by Gabriel Jacoby-Cooper on 3/30/22.
//

import SwiftUI

struct GoalEntryView: View {
	
	@State private var goal: Int
	
	@Binding private var goals: [Int]
	
	private let index: Int
	
	var body: some View {
		Group {
			Button {
				self.goals.remove(at: self.index)
			} label: {
				Label("Remove Goal", systemImage: "xmark.circle.fill")
					.labelStyle(.iconOnly)
			}
				.buttonStyle(.borderless)
			TextField("Goal Value", value: self.$goal, format: .number)
				.frame(width: 50)
				.onSubmit {
					self.goals[self.index] = self.goal
					self.goals.ensurePositive()
				}
		}
			.labelsHidden()
	}
	
	init(goals: Binding<[Int]>, index: Int) {
		self.index = index
		self._goals = goals
		self._goal = State(initialValue: goals[index].wrappedValue)
	}
	
}
