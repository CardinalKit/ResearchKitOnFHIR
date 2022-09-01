//
// This source file is part of the ResearchKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2022 CardinalKit and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
@_exported import class ModelsR4.Questionnaire


extension Questionnaire {
    /// A FHIR questionaire demonstrating enableWhen conditions that are converted to ResearchKit skip logic
    public static var skipLogicExample: Questionnaire = loadQuestionnaire(withName: "SkipLogicExample")

    /// A FHIR questionnaire demonstrating the use of a regular expression to validate an email address
    public static var textValidationExample: Questionnaire = loadQuestionnaire(withName: "TextValidationExample")
    
    
    private static func loadQuestionnaire(withName name: String) -> Questionnaire {
        guard let resourceURL = Bundle.module.url(forResource: name, withExtension: "json") else {
            fatalError("Could not find the resource \"\(name)\".json in the FHIRQuestionnaires Resources folder.")
        }
        
        do {
            let resourceData = try Data(contentsOf: resourceURL)
            return try JSONDecoder().decode(Questionnaire.self, from: resourceData)
        } catch {
            fatalError("Could not decode the FHIR questionnaire named \"\(name).json\": \(error)")
        }
    }
}