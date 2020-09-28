//
//  String+Regex.swift
//  IBLinterKit
//
//  Created by Séraphin Huguenot on 27/04/2020.
//

import Foundation

extension String {

    func matches(for regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
            return results.map {
                let range = Swift.Range($0.range(at: 1), in: self)!
                return String(self[range])
            }
        } catch let error {
            fatalError("Parse error: \(error)")
        }
    }
}
