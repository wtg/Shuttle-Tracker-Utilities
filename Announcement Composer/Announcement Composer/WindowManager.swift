//
//  WindowManager.swift
//  Announcement Composer
//
//  Created by Gabriel Jacoby-Cooper on 11/16/21.
//

import AppKit

enum WindowManager {
	
	enum Window: String {
		
		case main = "ContentView"
		
		case keyManager = "KeyManagerView"
		
	}
	
	static func open(_ window: Window) {
		for nsWindow in NSApplication.shared.windows {
			guard let nsWindowIdentifier = nsWindow.identifier else {
				continue
			}
			if nsWindowIdentifier.rawValue.contains(window.rawValue) {
				nsWindow.makeKeyAndOrderFront(nil)
				return
			}
		}
		let url = URL(string: "announcementcomposer://\(window.rawValue)")!
		NSWorkspace.shared.open(url)
	}
	
}
