//
//  MilestoneManagerView.swift
//  Milestone Composer
//
//  Created by Gabriel Jacoby-Cooper on 3/30/22.
//

import SwiftUI

struct MilestoneManagerView: View {
	
	enum SheetType: IdentifiableByHashValue {
		
		case serverSelection
		
	}
	
	@State private var sheetType: SheetType?
	
	@State private var milestones: [Milestone]?
	
	@State private var selectedMilestone: Milestone?
	
	@State private var baseURL = URL(string: "https://shuttletracker.app")!
	
	@State private var error: WrappedError?
	
	var body: some View {
		NavigationView {
			Group {
				Group {
					if let milestones = self.milestones {
						if milestones.count > 0 {
							VStack {
								List(milestones, selection: self.$selectedMilestone) { (milestone) in
									NavigationLink(milestone.name) {
										MilestoneDetailView(milestone: milestone, baseURL: self.baseURL) {
											await self.refresh()
										}
									}
								}
								.listStyle(.inset(alternatesRowBackgrounds: true))
							}
						} else {
							Text("No Milestones")
								.font(.callout)
								.multilineTextAlignment(.center)
								.foregroundColor(.secondary)
								.padding()
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
						ToolbarItem {
							Button {
								self.sheetType = .serverSelection
							} label: {
								Label("Select Server", systemImage: "server.rack")
							}
						}
						ToolbarItem {
							Button {
								Task {
									await self.refresh()
								}
							} label: {
								Label("Refresh", systemImage: "arrow.clockwise")
							}
						}
					}
				Text("No Milestone Selected")
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
			.navigationTitle("Milestone Manager")
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
		self.selectedMilestone = nil
		self.milestones = nil
		let url = self.baseURL.appendingPathComponent("milestones")
		do {
			let (data, _) = try await URLSession.shared.data(from: url)
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .iso8601
			self.milestones = try decoder.decode([Milestone].self, from: data)
		} catch let newError {
			self.error = WrappedError(newError)
		}
	}
	
}

struct MilestoneManagerViewPreviews: PreviewProvider {
	
	static var previews: some View {
		MilestoneManagerView()
	}
	
}
