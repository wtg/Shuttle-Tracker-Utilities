//
//  WindowManager.swift
//  Milestone Composer
//
//  Created by Gabriel Jacoby-Cooper on 3/29/22.
//

import AppKit

enum WindowManager {
	
	enum Window: String {
		
		case main = "ContentView"
		
		case keyManager = "KeyManagerView"
		
		case milestoneManager = "MilestoneManagerView"
		
	}
	
	static func show(_ window: Window) {
		for nsWindow in NSApplication.shared.windows {
			guard let nsWindowIdentifier = nsWindow.identifier else {
				continue
			}
			if nsWindowIdentifier.rawValue.contains(window.rawValue) {
				nsWindow.makeKeyAndOrderFront(nil)
				return
			}
		}
		let url = URL(string: "milestonecomposer://\(window.rawValue)")!
		NSWorkspace.shared.open(url)
	}
	
}
