//
//  ColorThemeRule.swift
//  IBLinterKit
//
//  Created by Séraphin Huguenot on 27/04/2020.
//

import IBDecodable
import Yams

extension Rules {

    struct ColorThemeRule: Rule {

        static let identifier = "color_theme"
        static let description = "Display error when color attribute does not correspond to a Theme file color"

        private let enforceComponentTheming: Bool
        private let themeApplicationColors: [String]
        private let themeGroups: [String]
        private let themeControllers: [String]
        private let themeComponents: [String: [String]]

        init(context: Context) {
            guard let config = context.config.colorThemeRule else {
                enforceComponentTheming = false
                themeApplicationColors = []
                themeGroups = []
                themeControllers = []
                themeComponents = [:]
                return
            }
            enforceComponentTheming = config.enforce
            let path = context.workDirectory.appendingPathComponent(config.path)
            do {
                let text = try String(contentsOf: path, encoding: .utf8)
                let yaml = try Yams.load(yaml: text) as! [String: Any]

                if let applicationTheme = yaml["application_theme"] as? [String: Any] {
                    themeApplicationColors = applicationTheme.compactMap { $0.key.snakeToCamelCase }
                } else {
                    themeApplicationColors = []
                }
                if let groups = yaml["groups"] as? [String: Any] {
                    themeGroups = groups.compactMap { $0.key.snakeToCamelCase }
                } else {
                    themeGroups =  []
                }
                if let controllers = yaml["controllers"] as? [String: Any] {
                    themeControllers = controllers.compactMap { $0.key.snakeToCamelCase }
                } else {
                    themeControllers = []
                }
                if let components = yaml["components"] as? [String: [String: Any]] {
                    let rawComponents = components.compactMapValues({ yaml -> [String] in Array(yaml.keys) }).map({key, value in (key, value)})
                    themeComponents = Dictionary(uniqueKeysWithValues: rawComponents.map { ($0.snakeToCamelCase, $1.map { $0.snakeToCamelCase }) })
                } else {
                    themeComponents = [:]
                }
            } catch let error {
                themeApplicationColors = []
                themeGroups = []
                themeControllers = []
                themeComponents = [:]
                print("Cannot read file at path \(path): \(error)")
            }
        }

        func validate(xib: XibFile) -> [Violation] {
            guard let views = xib.document.views else { return [] }
            return views.flatMap { validate(for: $0.view, file: xib) }
        }

        func validate(storyboard: StoryboardFile) -> [Violation] {
            guard let scenes = storyboard.document.scenes else { return [] }
            let views = scenes.compactMap { $0.viewController?.viewController.rootView }
            return views.flatMap { validate(for: $0, file: storyboard) }
        }

        private func validate<T: InterfaceBuilderFile>(for view: ViewProtocol, file: T) -> [Violation] {
            var violations = [Violation]()
            guard !themeComponents.isEmpty else {
                return violations
            }
            if enforceComponentTheming {
                if view.backgroundColor != nil {
                    let message = "\(viewName(of: view)) backgroundColor is hard-coded"
                    violations += [Violation(pathString: file.pathString, message: message, level: .warning)]
                }
                if view.tintColor != nil {
                    let message = "\(viewName(of: view)) tintColor is hard-coded"
                    violations += [Violation(pathString: file.pathString, message: message, level: .warning)]
                }
                if let view = view as? Label {
                    if view.textColor != nil {
                        let message = "\(viewName(of: view)) textColor is hard-coded"
                        violations += [Violation(pathString: file.pathString, message: message, level: .warning)]
                    }
                }
                if let view = view as? Switch {
                    if view.onTintColor != nil {
                        let message = "\(viewName(of: view)) onTintColor is hard-coded"
                        violations += [Violation(pathString: file.pathString, message: message, level: .warning)]
                    }
                }
                if let view = view as? TextView {
                    if view.textColor != nil {
                        let message = "\(viewName(of: view)) textColor is hard-coded"
                        violations += [Violation(pathString: file.pathString, message: message, level: .warning)]
                    }
                }
            }
            if let userDefinedAttributes = view.userDefinedRuntimeAttributes {
                for attribute in userDefinedAttributes {
                    if attribute.keyPath.hasSuffix("ColorName") {
                        if let value = attribute.value as? String, !value.isEmpty {
                            if value.contains(".") {
                                let message = "\(viewName(of: view)) legacy color format: \(value)"
                                violations += [Violation(pathString: file.pathString, message: message, level: .error)]
                            } else if !themeApplicationColors.contains(value) {
                                let message = "\(viewName(of: view)) unknown color: \(value)"
                                violations += [Violation(pathString: file.pathString, message: message, level: .error)]
                            }
                        } else {
                            let message = "\(viewName(of: view)) invalid color key"
                            violations += [Violation(pathString: file.pathString, message: message, level: .error)]
                        }
                    } else if attribute.keyPath == "themeParent" {
                        if let value = attribute.value as? String, !value.isEmpty {
                            if !(themeGroups + themeControllers).contains(value) {
                                let message = "\(viewName(of: view)) unknown parent theme: \(value)"
                                violations += [Violation(pathString: file.pathString, message: message, level: .error)]
                            }
                        } else {
                            let message = "\(viewName(of: view)) invalid parent theme"
                            violations += [Violation(pathString: file.pathString, message: message, level: .error)]
                        }
                    } else if attribute.keyPath == "themeStyle" {
                        if let value = attribute.value as? String, !value.isEmpty {
                            if let component = view.customClass {
                                if component == "CustomLabel" {
                                    if !themeComponents["label"]!.contains(value) {
                                        let message = "\(viewName(of: view)) unknown theme style: \(value)"
                                        violations += [Violation(pathString: file.pathString, message: message, level: .error)]
                                    }
                                } else if component == "LargeButton"  {
                                    if !themeComponents["largeButton"]!.contains(where: { $0.lowercased().contains(value)}) {
                                        let message = "\(viewName(of: view)) unknown theme style: \(value)"
                                        violations += [Violation(pathString: file.pathString, message: message, level: .error)]
                                    }
                                } else {
                                    let message = "Theme style check not implemented for class: \(component)"
                                    violations += [Violation(pathString: file.pathString, message: message, level: .error)]
                                }
                            }
                        } else {
                            let message = "\(viewName(of: view)) invalid parent theme"
                            violations += [Violation(pathString: file.pathString, message: message, level: .error)]
                        }
                    }
                }
            }
            return violations + (view.subviews?.flatMap { validate(for: $0.view, file: file) } ?? [])
        }
    }
}
