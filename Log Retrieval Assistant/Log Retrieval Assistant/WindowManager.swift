//
//  WindowManager.swift
//  Log Retrieval Assistant
//
//  Created by Gabriel Jacoby-Cooper on 11/3/22.
//

import AppKit

enum WindowManager {
	
	enum Window: String {
		
		case main = "ContentView"
		
		case keyManager = "KeyManagerView"
		
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
		let url = URL(string: "logretrievalassistant://\(window.rawValue)")!
		NSWorkspace.shared.open(url)
	}
	
}
