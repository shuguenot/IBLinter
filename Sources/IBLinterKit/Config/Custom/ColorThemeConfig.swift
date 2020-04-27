//
//  ColorThemeConfig.swift
//  IBLinterKit
//
//  Created by Séraphin Huguenot on 27/04/2020.
//

import Foundation

public struct ColorThemeConfig: Codable {
    public let path: String
    public let enforce: Bool

    enum CodingKeys: String, CodingKey {
        case path = "path"
        case enforce = "enforce_component_theming"
    }

    init(path: String, enforce: Bool) {
        self.path = path
        self.enforce = enforce
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        path = try container.decode(String.self, forKey: .path)
        enforce = try container.decode(Bool.self, forKey: .enforce)
    }
}
