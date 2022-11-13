//
//  LogRetrievalAssistantApp.swift
//  Log Retrieval Assistant
//
//  Created by Gabriel Jacoby-Cooper on 11/3/22.
//

import KeyManagement
import SwiftUI

@main
struct LogRetrievalAssistantApp: App {
	
	var body: some Scene {
		WindowGroup {
			ContentView()
		}
			.handlesExternalEvents(matching: [WindowManager.Window.main.rawValue])
			.commands {
				SidebarCommands()
			}
		WindowGroup {
			KeyManagerView()
				.frame(width: 400, height: 500)
		}
			.handlesExternalEvents(matching: [WindowManager.Window.keyManager.rawValue])
			.windowToolbarStyle(.unifiedCompact)
			.windowResizability(.contentSize)
	}
	
}
