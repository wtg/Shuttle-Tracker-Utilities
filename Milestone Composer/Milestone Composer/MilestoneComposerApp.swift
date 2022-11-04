//
//  MilestoneComposerApp.swift
//  Milestone Composer
//
//  Created by Gabriel Jacoby-Cooper on 3/15/22.
//

import KeyManagement
import SwiftUI

@main
struct MilestoneComposerApp: App {
	
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
			MilestoneManagerView()
				.frame(width: 700, height: 500)
		}
			.handlesExternalEvents(matching: [WindowManager.Window.milestoneManager.rawValue])
			.windowToolbarStyle(.unifiedCompact)
	}
	
}
