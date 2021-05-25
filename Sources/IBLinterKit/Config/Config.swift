//
//  Config.swift
//  IBLinterKit
//
//  Created by SaitoYuta on 2017/12/13.
//

import Foundation
import Yams

public struct Config: Codable {
    public let disabledRules: [String]
    public let enabledRules: [String]
    public let excluded: [String]
    public let included: [String]
    public let customModuleRule: [CustomModuleConfig]
    public let useBaseClassRule: [UseBaseClassConfig]
    public let viewAsDeviceRule: ViewAsDeviceConfig?
    public let useTraitCollectionsRule: UseTraitCollectionsConfig?
    public let colorThemeRule: ColorThemeConfig?
    public let localizationRule: LocalizationConfig?
    public let reporter: String
    public let disableWhileBuildingForIB: Bool
    public let ignoreCache: Bool

    enum CodingKeys: String, CodingKey {
        case disabledRules = "disabled_rules"
        case enabledRules = "enabled_rules"
        case excluded = "excluded"
        case included = "included"
        case customModuleRule = "custom_module_rule"
        case useBaseClassRule = "use_base_class_rule"
        case viewAsDeviceRule = "view_as_device_rule"
        case useTraitCollectionsRule = "use_trait_collections_rule"
        case colorThemeRule = "color_theme_rule"
        case localizationRule = "localization_rule"
        case reporter = "reporter"
        case disableWhileBuildingForIB = "disable_while_building_for_ib"
        case ignoreCache = "ignore_cache"
    }

    public static let fileName = ".iblinter.yml"
    public static let `default` = Config.init()

    private init() {
        disabledRules = []
        enabledRules = []
        excluded = []
        included = []
        customModuleRule = []
        useBaseClassRule = []
        viewAsDeviceRule = nil
        useTraitCollectionsRule = nil
        colorThemeRule = nil
        localizationRule = nil
        reporter = "xcode"
        disableWhileBuildingForIB = true
        ignoreCache = false
    }

    init(disabledRules: [String] = [], enabledRules: [String] = [],
         excluded: [String] = [], included: [String] = [],
         customModuleRule: [CustomModuleConfig] = [],
         baseClassRule: [UseBaseClassConfig] = [],
         viewAsDeviceRule: ViewAsDeviceConfig? = nil,
         useTraitCollectionsRule: UseTraitCollectionsConfig? = nil,
         colorThemeRule: ColorThemeConfig? = nil,
         localizationRule: LocalizationConfig? = nil,
         reporter: String = "xcode", disableWhileBuildingForIB: Bool = true,
         ignoreCache: Bool = false) {
        self.disabledRules = disabledRules
        self.enabledRules = enabledRules
        self.excluded = excluded
        self.included = included
        self.customModuleRule = customModuleRule
        self.useBaseClassRule = baseClassRule
        self.useTraitCollectionsRule = useTraitCollectionsRule
        self.viewAsDeviceRule = viewAsDeviceRule
        self.colorThemeRule = colorThemeRule
        self.localizationRule = localizationRule
        self.reporter = reporter
        self.disableWhileBuildingForIB = disableWhileBuildingForIB
        self.ignoreCache = ignoreCache
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        disabledRules = try container.decodeIfPresent(Optional<[String]>.self, forKey: .disabledRules).flatMap { $0 } ?? []
        enabledRules = try container.decodeIfPresent(Optional<[String]>.self, forKey: .enabledRules).flatMap { $0 } ?? []
        excluded = try container.decodeIfPresent(Optional<[String]>.self, forKey: .excluded).flatMap { $0 } ?? []
        included = try container.decodeIfPresent(Optional<[String]>.self, forKey: .included).flatMap { $0 } ?? []
        customModuleRule = try container.decodeIfPresent(Optional<[CustomModuleConfig]>.self, forKey: .customModuleRule).flatMap { $0 } ?? []
        useBaseClassRule = try container.decodeIfPresent(Optional<[UseBaseClassConfig]>.self, forKey: .useBaseClassRule)?.flatMap { $0 } ?? []
        useTraitCollectionsRule = try container.decodeIfPresent(Optional<UseTraitCollectionsConfig>.self, forKey: .useTraitCollectionsRule) ?? nil
        viewAsDeviceRule = try container.decodeIfPresent(Optional<ViewAsDeviceConfig>.self, forKey: .viewAsDeviceRule) ?? nil
        colorThemeRule = try container.decodeIfPresent(Optional<ColorThemeConfig>.self, forKey: .colorThemeRule) ?? nil
        localizationRule = try container.decodeIfPresent(Optional<LocalizationConfig>.self, forKey: .localizationRule) ?? nil
        reporter = try container.decodeIfPresent(String.self, forKey: .reporter) ?? "xcode"
        disableWhileBuildingForIB = try container.decodeIfPresent(Bool.self, forKey: .disableWhileBuildingForIB) ?? true
        ignoreCache = try container.decodeIfPresent(Bool.self, forKey: .ignoreCache) ?? false
    }

    public init(url: URL) throws {
        self = try YAMLDecoder().decode(from: String.init(contentsOf: url))
    }

    public init(directoryURL: URL, fileName: String = fileName) throws {
        let url = directoryURL.appendingPathComponent(fileName)
        try self.init(url: url)
    }
}
