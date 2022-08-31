//
// This source file is part of the ResearchKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2022 CardinalKit and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable duplicate_imports
import Foundation
import ModelsR4
@_exported import class ModelsR4.Questionnaire
import ResearchKit
@_exported import class ResearchKit.ORKCompletionStep
@_exported import class ResearchKit.ORKNavigableOrderedTask


/// An error that is thrown when translating a FHIR `Questionnaire` to an `ORKNavigableOrderedTask`
public enum FHIRToResearchKitConversionError: Error, CustomStringConvertible {
    case noItems
    case noId
    case unsupportedOperator(QuestionnaireItemOperator)
    case unsupportedAnswer(QuestionnaireItemEnableWhen.AnswerX)
    case noOptions
    case invalidDate(FHIRPrimitive<FHIRDate>)
    
    
    public var description: String {
        switch self {
        case .noItems:
            return "The parsed FHIR Questionaire didn't contain any items"
        case .noId:
            return "This FHIR Questionnaire does not have an id"
        case let .unsupportedOperator(fhirOperator):
            return "An unsupported operator was used: \(fhirOperator)"
        case let .unsupportedAnswer(answer):
            return "An unsupported answer type was used: \(answer)"
        case .noOptions:
            return "No Option was provided."
        case let .invalidDate(date):
            return "Encountered an invalid date when parsing the questionaire: \(date)"
        }
    }
}


/// A class that converts FHIR Questionnaires to ResearchKit ORKOrderedTasks
extension ORKNavigableOrderedTask {
    /// Supported FHIR extensions
    private enum SupportedExtensions {
        static let questionaireUnit = "http://hl7.org/fhir/StructureDefinition/questionnaire-unit"
        static let regex = "http://hl7.org/fhir/StructureDefinition/regex"
        static let validationMessage = "http://cardinalkit.org/fhir/StructureDefinition/validationtext"
        static let maxDecimalPlaces = "http://hl7.org/fhir/StructureDefinition/maxDecimalPlaces"
        static let minValue = "http://hl7.org/fhir/StructureDefinition/minValue"
        static let maxValue = "http://hl7.org/fhir/StructureDefinition/maxValue"
    }
    
    
    /// Create a `ORKNavigableOrderedTask` by parsing a FHIR `Questionnaire`. Throws a `FHIRToResearchKitConversionError` if an error happens during the parsing.
    /// - Parameters:
    ///  - title: The title of the questionnaire. If you pass in a `String` the translation overrides the title that might be provided in the FHIR `Questionnaire`.
    ///  - questionnaire: The FHIR `Questionnaire` used to create the `ORKNavigableOrderedTask`.
    ///  - summaryStep: An optional `ORKCompletionStep` that can be displayed at the end of the ResearchKit survey.
    public convenience init(
        title: String? = nil,
        questionnaire: Questionnaire,
        summaryStep: ORKCompletionStep? = nil
    ) throws {
        guard let item = questionnaire.item else {
            throw FHIRToResearchKitConversionError.noItems
        }

        guard let id = questionnaire.id?.value?.string else {
            throw FHIRToResearchKitConversionError.noId
        }

        // Convert each FHIR Questionnaire Item to an ORKStep
        var steps = ORKNavigableOrderedTask.fhirQuestionnaireItemsToORKSteps(items: item, title: (title ?? questionnaire.title?.value?.string) ?? "")
        
        // Add a summary step at the end of the task if defined
        if let summaryStep = summaryStep {
            steps.append(summaryStep)
        }

        self.init(identifier: id, steps: steps)
        // If any questions have defined skip logic, convert to ResearchKit navigation rules
        try constructNavigationRules(questions: item)
    }
    

    /// Converts FHIR `QuestionnaireItems` (questions) to ResearchKit `ORKSteps`.
    /// - Parameters:
    ///   - questions: An array of FHIR `QuestionnaireItems`.
    ///   - title: A `String` that will be rendered above the questions by ResearchKit.
    /// - Returns:An `Array` of ResearchKit `ORKSteps`.
    private static func fhirQuestionnaireItemsToORKSteps(items: [QuestionnaireItem], title: String) -> [ORKStep] {
        var surveySteps: [ORKStep] = []
        surveySteps.reserveCapacity(items.count)
        
        for question in items {
            guard let questionType = question.type.value else {
                continue
            }
            
            switch questionType {
            case QuestionnaireItemType.group:
                // multiple questions in a group
                if let groupStep = fhirGroupToORKFormStep(question: question, title: title) {
                    surveySteps.append(groupStep)
                }
            case QuestionnaireItemType.display:
                // a string to display that does not take an answer
                if let instructionStep = fhirDisplayToORKInstructionStep(question: question, title: title) {
                    surveySteps.append(instructionStep)
                }
            default:
                // individual questions
                if let step = fhirQuestionnaireItemToORKQuestionStep(question: question, title: title) {
                    if let required = question.required?.value?.bool {
                        step.isOptional = !required
                    }
                    surveySteps.append(step)
                }
            }
        }
        
        return surveySteps
    }

    /// Converts a FHIR `QuestionnaireItem` to a ResearchKit `ORKQuestionStep`.
    /// - Parameters:
    ///   - question: A FHIR `QuestionnaireItem` object (a single question or a set of questions in a group).
    ///   - title: A `String` that will be displayed above the question when rendered by ResearchKit.
    /// - Returns: An `ORKQuestionStep` object (a ResearchKit question step containing the above question).
    private static func fhirQuestionnaireItemToORKQuestionStep(question: QuestionnaireItem, title: String) -> ORKQuestionStep? {
        guard let questionText = question.text?.value?.string,
              let identifier = question.linkId.value?.string else {
            return nil
        }

        let answer = try? fhirQuestionnaireItemToORKAnswerFormat(question: question)
        return ORKQuestionStep(identifier: identifier, title: title, question: questionText, answer: answer)
    }

    /// Converts a FHIR QuestionnaireItem that contains a group of question items into a ResearchKit form (ORKFormStep).
    /// - Parameters:
    ///   - question: A FHIR QuestionnaireItem object which contains a group of nested questions.
    ///   - title: A String that will be displayed at the top of the form when rendered by ResearchKit.
    /// - Returns: An ORKFormStep object (a ResearchKit form step containing all of the nested questions).
    private static func fhirGroupToORKFormStep(question: QuestionnaireItem, title: String) -> ORKFormStep? {
        guard let id = question.linkId.value?.string,
              let nestedQuestions = question.item else {
            return nil
        }

        let formStep = ORKFormStep(identifier: id)
        formStep.title = title
        var formItems = [ORKFormItem]()

        for question in nestedQuestions {
            guard let questionId = question.linkId.value?.string,
                  let questionText = question.text?.value?.string,
                  let answerFormat = try? fhirQuestionnaireItemToORKAnswerFormat(question: question) else {
                continue
            }
            
            let formItem = ORKFormItem(identifier: questionId, text: questionText, answerFormat: answerFormat)
            if let required = question.required?.value?.bool {
                formItem.isOptional = required
            }
            
            formItems.append(formItem)
        }

        formStep.formItems = formItems
        return formStep
    }

    /// Converts FHIR `QuestionnaireItem` display type to `ORKInstructionStep`
    /// - Parameters:
    ///   - question: A FHIR `QuestionnaireItem` object.
    ///   - title: A `String` to display at the top of the view rendered by ResearchKit.
    /// - Returns: A ResearchKit `ORKInstructionStep`.
    private static func fhirDisplayToORKInstructionStep(question: QuestionnaireItem, title: String) -> ORKInstructionStep? {
        guard let id = question.linkId.value?.string,
              let text = question.text?.value?.string else {
            return nil
        }

        let instructionStep = ORKInstructionStep(identifier: id)
        instructionStep.title = title
        instructionStep.detailText = text
        return instructionStep
    }

    /// Converts FHIR QuestionnaireItem answer types to the corresponding ResearchKit answer types (ORKAnswerFormat).
    /// - Parameter question: A FHIR `QuestionnaireItem` object.
    /// - Returns: An object of type `ORKAnswerFormat` representing the type of answer this question accepts.
    private static func fhirQuestionnaireItemToORKAnswerFormat(question: QuestionnaireItem) throws -> ORKAnswerFormat {
        switch question.type.value {
        case .boolean:
            return ORKBooleanAnswerFormat.booleanAnswerFormat()
        case .choice:
            let answerOptions = fhirChoicesToORKTextChoice(question)
            guard !answerOptions.isEmpty else {
                throw FHIRToResearchKitConversionError.noOptions
            }
            return ORKTextChoiceAnswerFormat(style: ORKChoiceAnswerStyle.singleChoice, textChoices: answerOptions)
        case .date:
            return ORKDateAnswerFormat(style: ORKDateAnswerStyle.date)
        case .decimal:
            let answerFormat = ORKNumericAnswerFormat.decimalAnswerFormat(withUnit: "")
            answerFormat.maximumFractionDigits = getMaximumDecimalPlaces(question)
            answerFormat.minimum = getMinValue(question)
            answerFormat.maximum = getMaxValue(question)
            return answerFormat
        case .integer:
            let answerFormat = ORKNumericAnswerFormat.integerAnswerFormat(withUnit: "")
            answerFormat.minimum = getMinValue(question)
            answerFormat.maximum = getMaxValue(question)
            return answerFormat
        case .quantity: // a numeric answer with an included unit to be displayed
            let answerFormat = ORKNumericAnswerFormat.decimalAnswerFormat(withUnit: getUnit(question))
            answerFormat.maximumFractionDigits = getMaximumDecimalPlaces(question)
            answerFormat.minimum = getMinValue(question)
            answerFormat.maximum = getMaxValue(question)
            return answerFormat
        case .text, .string:
            let validationRegularExpression = getValidationRegularExpression(question)
            let validationMessage = getValidationMessage(question)
            let maximumLength = Int(question.maxLength?.value?.integer ?? 0)

            let answerFormat = ORKTextAnswerFormat(maximumLength: maximumLength)
            answerFormat.validationRegularExpression = validationRegularExpression
            answerFormat.invalidMessage = validationMessage
            return answerFormat
        case .time:
            return ORKDateAnswerFormat(style: ORKDateAnswerStyle.dateAndTime)
        default:
            return ORKTextAnswerFormat()
        }
    }

    /// Converts FHIR text answer choices to ResearchKit `ORKTextChoice`.
    /// - Parameter question: A FHIR `QuestionnaireItem`.
    /// - Returns: An array of `ORKTextChoice` objects, each representing a textual answer option.
    private static func fhirChoicesToORKTextChoice(_ question: QuestionnaireItem) -> [ORKTextChoice] {
        var choices: [ORKTextChoice] = []
        guard let answerOptions = question.answerOption else {
            return choices
        }
        
        for option in answerOptions {
            guard case let .coding(coding) = option.value,
                  let display = coding.display?.value?.string,
                  let code = coding.code?.value?.string else {
                continue
            }
            
            choices.append(ORKTextChoice(text: display, value: code as NSCoding & NSCopying & NSObjectProtocol))
        }
        
        return choices
    }
    
    
    // MARK: FHIR Extensions

    /// Gets the minimum value for a numerical answer.
    /// - Parameter question: A FHIR `QuestionnaireItem` with a numerical answer type (integer, decimal).
    /// - Returns: An optional `NSNumber` containing the minimum value allowed.
    private static func getMinValue(_ question: QuestionnaireItem) -> NSNumber? {
        guard let minValueExtension = getExtensionInQuestionnaireItem(question: question, url: SupportedExtensions.minValue),
              case let .integer(integerValue) = minValueExtension.value,
              let minValue = integerValue.value?.integer as? Int32 else {
            return nil
        }
        return NSNumber(value: minValue)
    }

    /// Gets the maximum value for a numerical answer.
    /// - Parameter question: A FHIR `QuestionnaireItem` with a numerical answer type (integer, decimal).
    /// - Returns: An optional `NSNumber` containing the maximum value allowed.
    private static func getMaxValue(_ question: QuestionnaireItem) -> NSNumber? {
        guard let maxValueExtension = getExtensionInQuestionnaireItem(question: question, url: SupportedExtensions.maxValue),
              case let .integer(integerValue) = maxValueExtension.value,
              let maxValue = integerValue.value?.integer as? Int32 else {
            return nil
        }
        return NSNumber(value: maxValue)
    }

    /// Gets the maximum number of decimal palces for a decimal answer.
    /// - Parameter question: A FHIR `QuestionnaireItem` with a decimal answer type.
    /// - Returns: An optional `NSNumber` representing the maximum number of digits to the right of the decimal place.
    private static func getMaximumDecimalPlaces(_ question: QuestionnaireItem) -> NSNumber? {
        guard let maxDecimalPlacesExtension = getExtensionInQuestionnaireItem(question: question, url: SupportedExtensions.maxDecimalPlaces),
              case let .integer(integerValue) = maxDecimalPlacesExtension.value,
              let maxDecimalPlaces = integerValue.value?.integer as? Int32 else {
                return nil
        }
        return NSNumber(value: maxDecimalPlaces)
    }
    
    /// Gets the unit of a quantity answer type.
    /// - Parameter question: A FHIR `QuestionnaireItem` with a quantity answer type.
    /// - Returns: An optional `String` containing the unit (i.e. cm) if it was provided.
    private static func getUnit(_ question: QuestionnaireItem) -> String? {
        guard let unitExtension = getExtensionInQuestionnaireItem(question: question, url: SupportedExtensions.questionaireUnit),
              case let .coding(coding) = unitExtension.value else {
            return nil
        }
        return coding.code?.value?.string
    }

    /// Checks a QuestionnaireItem for an extension matching the given URL and then return it if it exists.
    /// - Parameters:
    ///   - question: A FHIR `QuestionnaireItem`.
    ///   - url: A `String` identifying the extension.
    /// - Returns: an optional Extension if it was found.
    private static func getExtensionInQuestionnaireItem(question: QuestionnaireItem, url: String) -> Extension? {
        question.`extension`?.first(where: { $0.url.value?.url.absoluteString == url })
    }

    /// Gets the regular expression specified for validating a text input in a question.
    /// - Parameter question: A FHIR `QuestionnaireItem` with a text or string input that contains a regular expression for validation.
    /// - Returns: An optional `String` containing the regular expression, if it exists.
    private static func getValidationRegularExpression(_ question: QuestionnaireItem) -> NSRegularExpression? {
        guard let regexExtension = getExtensionInQuestionnaireItem(question: question, url: SupportedExtensions.regex),
              case let .string(regex) = regexExtension.value,
              let stringRegularExpression = regex.value?.string else {
            return nil
        }
        return try? NSRegularExpression(pattern: stringRegularExpression)
    }
    
    /// Gets the validation message for a question.
    /// - Parameter question: A FHIR `QuestionnaireItem` with a text or string input that contains a validation message
    /// - Returns: An optional `String` containing the validation message, if it exists.
    private static func getValidationMessage(_ question: QuestionnaireItem) -> String? {
        guard let validationMessageExtension = getExtensionInQuestionnaireItem(question: question, url: SupportedExtensions.validationMessage),
              case let .string(message) = validationMessageExtension.value,
              let stringMessage = message.value?.string else {
            return nil
        }
        return stringMessage
    }
}