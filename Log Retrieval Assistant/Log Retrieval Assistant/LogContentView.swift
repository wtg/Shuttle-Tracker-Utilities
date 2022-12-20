//
//  LogContentView.swift
//  Log Retrieval Assistant
//
//  Created by Gabriel Jacoby-Cooper on 12/11/22.
//

import SwiftUI

struct LogContentView: View {
	
	let log: Log
	
	let doShowID: Bool
	
	var body: some View {
		VStack(alignment: .leading) {
			if self.doShowID {
				Text(self.log.id.uuidString)
					.bold()
			}
			Text(self.log.content)
				.multilineTextAlignment(.leading)
		}
			.fontDesign(.monospaced)
			.textSelection(.enabled)
	}
	
	init(log: Log, doShowID: Bool = false) {
		self.log = log
		self.doShowID = doShowID
	}
	
}
