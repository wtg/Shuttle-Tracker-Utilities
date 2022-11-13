//
//  AnnouncementManagerView.swift
//  Announcement Composer
//
//  Created by Gabriel Jacoby-Cooper on 11/21/21.
//

import KeyManagement
import ServerSelection
import SwiftUI

struct AnnouncementManagerView: View {
	
	enum SheetType: Int, IdentifiableByRawValue {
		
		case serverSelection
		
		typealias ID = RawValue
		
	}
	
	@State
	private var sheetType: SheetType?
	
	@State
	private var announcements: [Announcement]?
	
	@State
	private var selectedAnnouncement: Announcement?
	
	@State
	private var baseURL = URL(string: "https://shuttletracker.app")!
	
	@State
	private var error: WrappedError?
	
	var body: some View {
		NavigationView {
			Group {
				Group {
					if let announcements = self.announcements {
						if announcements.isEmpty {
							Text("No Announcements")
								.font(.callout)
								.multilineTextAlignment(.center)
								.foregroundColor(.secondary)
								.padding()
						} else {
							VStack {
								List(announcements, selection: self.$selectedAnnouncement) { (announcement) in
									NavigationLink(announcement.subject) {
										AnnouncementDetailView(announcement: announcement, baseURL: self.baseURL) {
											await self.refresh()
										}
									}
								}
									.listStyle(.inset(alternatesRowBackgrounds: true))
							}
						}
					} else {
						ProgressView("Loading")
							.font(.callout)
							.textCase(.uppercase)
							.foregroundColor(.secondary)
							.padding()
					}
				}
					.toolbar {
						Button {
							self.sheetType = .serverSelection
						} label: {
							Label("Select Server", systemImage: "server.rack")
						}
						Button {
							Task {
								await self.refresh()
							}
						} label: {
							Label("Refresh", systemImage: "arrow.clockwise")
						}
					}
				Text("No Announcement Selected")
					.font(.title2)
					.multilineTextAlignment(.center)
					.foregroundColor(.secondary)
					.padding()
					.toolbar {
						ToolbarItem {
							Button { } label: {
								Label("Delete", systemImage: "trash")
							}
								.disabled(true)
						}
					}
			}
				.frame(minWidth: 200)
				.navigationTitle("Announcement Manager")
		}
			.alert(isPresented: self.$error.isNotNil, error: self.error) {
				Button("Continue") { }
			}
			.sheet(item: self.$sheetType) {
				Task {
					await self.refresh()
				}
			} content: { (sheetType) in
				switch sheetType {
				case .serverSelection:
					ServerSelectionSheet(baseURL: self.$baseURL, sheetType: self.$sheetType)
				}
			}
			.task {
				await self.refresh()
			}
	}
	
	private func refresh() async {
		self.selectedAnnouncement = nil
		self.announcements = nil
		let url = self.baseURL.appendingPathComponent("announcements")
		do {
			let (data, _) = try await URLSession.shared.data(from: url)
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .iso8601
			self.announcements = try decoder.decode([Announcement].self, from: data)
		} catch let newError {
			self.error = WrappedError(newError)
		}
	}
	
}

struct AnnouncementManagerViewPreviews: PreviewProvider {
	
	static var previews: some View {
		AnnouncementManagerView()
	}
	
}
