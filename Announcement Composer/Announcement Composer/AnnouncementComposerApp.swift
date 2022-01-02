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
				.frame(minWidth: 800, minHeight: 600)
		}
			.handlesExternalEvents(matching: [WindowManager.Window.main.rawValue])
			.commands {
				CommandGroup(replacing: .newItem) {
					EmptyView()
				}
			}
		WindowGroup {
			KeyManagerView()
				.frame(width: 400, height: 500)
		}
			.handlesExternalEvents(matching: [WindowManager.Window.keyManager.rawValue])
			.windowToolbarStyle(.unifiedCompact)
		WindowGroup {
			AnnouncementManagerView()
				.frame(width: 700, height: 500)
		}
			.handlesExternalEvents(matching: [WindowManager.Window.announcementManager.rawValue])
			.windowToolbarStyle(.unifiedCompact)
	}
	
}
