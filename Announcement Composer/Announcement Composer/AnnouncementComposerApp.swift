//
//  AnnouncementComposerApp.swift
//  Announcement Composer
//
//  Created by Gabriel Jacoby-Cooper on 11/16/21.
//

import KeyManagement
import ServerSelection
import SwiftUI

@main
struct AnnouncementComposerApp: App {
	
	private static let serverSelectionAppGroupID = "SYBLH277NF.com.gerzer.shuttletracker.serverselection"
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.frame(minWidth: 800, minHeight: 600)
				.serverSelection(appGroupID: Self.serverSelectionAppGroupID)
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
			.windowResizability(.contentSize)
		WindowGroup {
			AnnouncementManagerView()
				.frame(width: 700, height: 500)
				.serverSelection(appGroupID: Self.serverSelectionAppGroupID)
		}
			.handlesExternalEvents(matching: [WindowManager.Window.announcementManager.rawValue])
			.windowToolbarStyle(.unifiedCompact)
			.windowResizability(.contentSize)
	}
	
}
