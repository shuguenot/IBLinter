//
//  String+Case.swift
//  IBLinterKit
//
//  Created by Séraphin Huguenot on 27/04/2020.
//

import Foundation

extension String {

    var snakeToCamelCase: String {
        let buffer = capitalized.replacingOccurrences(of: "(\\w{0,1})_", with: "$1", options: .regularExpression, range: nil) as NSString
        return buffer.replacingCharacters(in: NSMakeRange(0,1), with: buffer.substring(to: 1).lowercased()) as String
    }
}
