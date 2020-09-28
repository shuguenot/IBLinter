//
//  LocalizationRule.swift
//  IBLinterKit
//
//  Created by Séraphin Huguenot on 27/04/2020.
//

import IBDecodable

extension Rules {
    
    struct LocalizationRule: Rule {
        
        static let identifier = "localization"
        static let description = "Display error when localization string attribute does not correspond to an existing string of Localizable.strings file"

        private let strings: [String]
        
        init(context: Context) {
            guard let inputPath = context.config.localizationRule?.path else {
                strings = []
                return
            }
            let path = context.workDirectory.appendingPathComponent(inputPath)
            do {
                let text = try String(contentsOf: path, encoding: .utf8)
                strings = text.matches(for: "\"(.*)\".*=.*")
            } catch let error {
                strings = []
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
            let violation: [Violation] = {
                if let userDefinedAttributes = view.userDefinedRuntimeAttributes {
                    for attribute in userDefinedAttributes {
                        if attribute.keyPath.starts(with: "locKey") {
                            if let value = attribute.value as? String, !value.isEmpty {
                                if !strings.contains(value) {
                                    let message = "\(viewName(of: view)) unknown localization key: \(value)"
                                    return [Violation(pathString: file.pathString, message: message, level: .error)]
                                }
                            } else {
                                let message = "\(viewName(of: view)) invalid localization key"
                                return [Violation(pathString: file.pathString, message: message, level: .error)]
                            }
                        }
                    }
                }
                return []
            }()
            return violation + (view.subviews?.flatMap { validate(for: $0.view, file: file) } ?? [])
        }
    }
}
