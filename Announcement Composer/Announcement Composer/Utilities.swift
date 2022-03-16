//
//  Utilities.swift
//  Announcement Composer
//
//  Created by Gabriel Jacoby-Cooper on 11/16/21.
//

import Foundation

enum DefaultsUtilities {
	
	static let store = UserDefaults(suiteName: "SYBLH277NF.com.gerzer.shuttletracker.composers")
	
}

protocol IdentifiableByHashValue: Identifiable, Hashable { }

extension IdentifiableByHashValue {
	
	var id: Int {
		get {
			return self.hashValue
		}
	}
	
}

protocol RawRepresentableByString {
	
	var rawValue: String { get }
	
}
