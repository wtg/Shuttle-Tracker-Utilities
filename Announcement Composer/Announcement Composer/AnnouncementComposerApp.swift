//
//  AnnouncementComposerApp.swift
//  Announcement Composer
//
//  Created by Gabriel Jacoby-Cooper on 11/16/21.
//

import SwiftUI

@main struct AnnouncementComposerApp: App {
	
	var body: some Scene {
		WindowGroup {
			ContentView()
		}
			.handlesExternalEvents(matching: [WindowManager.Window.main.rawValue])
		WindowGroup {
			KeyManagerView()
				.frame(width: 400, height: 500)
		}
			.handlesExternalEvents(matching: [WindowManager.Window.keyManager.rawValue])
			.windowToolbarStyle(.unifiedCompact)
			.commands {
				CommandGroup(replacing: .newItem) {
					EmptyView()
				}
				CommandGroup(replacing: .pasteboard) {
					EmptyView()
				}
			}
	}
	
}
