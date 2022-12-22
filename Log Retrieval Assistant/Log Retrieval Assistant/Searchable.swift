//
//  Searchable.swift
//  Log Retrieval Assistant
//
//  Created by Gabriel Jacoby-Cooper on 12/21/22.
//

/// A type instances of which can be matched by specific search text in a particular search scope.
protocol Searchable {
	
	associatedtype SearchScope
	
	/// Checks whether the instance is matched by the search text within the given search scope.
	/// - Parameters:
	///   - searchText: The search text.
	///   - scope: The scope in which to check for a match.
	/// - Returns: `true` if the instance is matched by the search text; otherwise, `false`.
	func isMatched(by searchText: some StringProtocol, in scope: SearchScope) -> Bool
	
}

extension RandomAccessCollection where Element: Searchable {
	
	/// Returns an array containing, in order, the elements of the collection that are matched by the given search text in the given scope.
	///
	/// The empty string matches all elements.
	/// - Complexity: O(_m_ × _n_), where _m_ is the length of the collection and _n_ is the complexity of `Element`’s implementation of ``Searchable/isMatched(by:in:)``.
	/// - Parameters:
	///   - searchText: The search text.
	///   - scope: The scope in which to check for matches.
	/// - Returns: An array of the elements that are matched by `searchText` in `scope`
	func filter(on searchText: some StringProtocol, in scope: Element.SearchScope) -> [Element] {
		guard !searchText.isEmpty else {
			return Array(self)
		}
		return self.filter { (element) in
			return element.isMatched(by: searchText, in: scope)
		}
	}
	
}

extension StringProtocol {
	
	/// Returns the normalized version of the string for the purpose of search matching.
	///
	/// Commonly interchanged characters like “smart quotes” are replaced with standardized representations. As a result, the returned string is not suitable for display to the user.
	/// - Important: The string is neither uppercased nor lowercased, so additional processing is necessary to achieve case insensitivity.
	/// - Complexity: O(_n_), where _n_ is the length of the string.
	/// - Returns: The normalized version of the string.
	func normalizedForSearch() -> String {
		return self
			.replacingOccurrences(of: "‘", with: "'")
			.replacingOccurrences(of: "’", with: "'")
			.replacingOccurrences(of: "“", with: "\"")
			.replacingOccurrences(of: "”", with: "\"")
			.replacingOccurrences(of: "…", with: "...")
	}
	
}
