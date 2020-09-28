//
//  ColorThemeConfig.swift
//  IBLinterKit
//
//  Created by Séraphin Huguenot on 27/04/2020.
//

import Foundation

public struct ColorThemeConfig: Codable {
    public let path: String

    enum CodingKeys: String, CodingKey {
        case path = "path"
    }

    init(path: String) {
        self.path = path
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        path = try container.decode(String.self, forKey: .path)
    }
}
