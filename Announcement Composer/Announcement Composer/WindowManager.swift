//
//  WindowManager.swift
//  Announcement Composer
//
//  Created by Gabriel Jacoby-Cooper on 11/16/21.
//

import AppKit

enum WindowManager {
	
	enum Window: String {
		
		case main = "main"
		
		case keyManager = "keymanager"
		
	}
	
	static func open(_ window: Window) {
		let url = URL(string: "announcementcomposer://\(window.rawValue)")!
		NSWorkspace.shared.open(url)
	}
	
}
