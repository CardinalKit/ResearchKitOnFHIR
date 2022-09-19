//
//  NavigationRulesTests.swift
//  
//
//  Created by Vishnu Ravi on 9/18/22.
//

import XCTest
@testable import ResearchKitOnFHIR
import ResearchKit
import ModelsR4

final class NavigationRulesTests: XCTestCase {
    private func createORKNavigableOrderedTask(firstItemID: String,
                                               secondItemID: String,
                                               enableWhen: QuestionnaireItemEnableWhen) throws -> ORKNavigableOrderedTask {
        let questionnaire = Questionnaire(status: FHIRPrimitive(PublicationStatus.draft))
        questionnaire.url = FHIRPrimitive(FHIRURI(stringLiteral: "http://cardinalkit.org/fhir/questionnaire/navigation-rule-test"))
        let questionnaireItemFirst = QuestionnaireItem(linkId: FHIRPrimitive(FHIRString(firstItemID)),
                                                       type: FHIRPrimitive(QuestionnaireItemType.integer))
        let questionnaireItemSecond = QuestionnaireItem(enableWhen: [enableWhen],
                                                        linkId: FHIRPrimitive(FHIRString(secondItemID)),
                                                        type: FHIRPrimitive(QuestionnaireItemType.integer))
        questionnaire.item = [questionnaireItemFirst, questionnaireItemSecond]
        let orkNavigableOrderedTask = try ORKNavigableOrderedTask(questionnaire: questionnaire)
        return orkNavigableOrderedTask
    }

    func testIntegerEqual() throws {
        let firstItemID = UUID().uuidString, secondItemID = UUID().uuidString
        let enableWhen = QuestionnaireItemEnableWhen(answer: .integer(100),
                                                     operator: FHIRPrimitive(QuestionnaireItemOperator.equal),
                                                     question: FHIRPrimitive(FHIRString(firstItemID)))

        let task = try createORKNavigableOrderedTask(firstItemID: firstItemID,
                                                     secondItemID: secondItemID,
                                                     enableWhen: enableWhen)
        XCTAssertNotNil(task.skipNavigationRule(forStepIdentifier: secondItemID))
    }

    func testIntegerNotEqual() throws {
        let firstItemID = UUID().uuidString, secondItemID = UUID().uuidString
        let enableWhen = QuestionnaireItemEnableWhen(answer: .integer(100),
                                                     operator: FHIRPrimitive(QuestionnaireItemOperator.notEqual),
                                                     question: FHIRPrimitive(FHIRString(firstItemID)))

        let task = try createORKNavigableOrderedTask(firstItemID: firstItemID,
                                                     secondItemID: secondItemID,
                                                     enableWhen: enableWhen)
        XCTAssertNotNil(task.skipNavigationRule(forStepIdentifier: secondItemID))
    }

    func testIntegerLessThanOrEqual() throws {
        let firstItemID = UUID().uuidString, secondItemID = UUID().uuidString
        let enableWhen = QuestionnaireItemEnableWhen(answer: .integer(100),
                                                     operator: FHIRPrimitive(QuestionnaireItemOperator.lessThanOrEqual),
                                                     question: FHIRPrimitive(FHIRString(firstItemID)))

        let task = try createORKNavigableOrderedTask(firstItemID: firstItemID,
                                                     secondItemID: secondItemID,
                                                     enableWhen: enableWhen)
        XCTAssertNotNil(task.skipNavigationRule(forStepIdentifier: secondItemID))
    }

    func testIntegerGreaterThanOrEqual() throws {
        let firstItemID = UUID().uuidString, secondItemID = UUID().uuidString
        let enableWhen = QuestionnaireItemEnableWhen(answer: .integer(100),
                                                     operator: FHIRPrimitive(QuestionnaireItemOperator.greaterThanOrEqual),
                                                     question: FHIRPrimitive(FHIRString(firstItemID)))

        let task = try createORKNavigableOrderedTask(firstItemID: firstItemID,
                                                     secondItemID: secondItemID,
                                                     enableWhen: enableWhen)
        XCTAssertNotNil(task.skipNavigationRule(forStepIdentifier: secondItemID))
    }

    func testDecimalEqual() throws {
        let firstItemID = UUID().uuidString, secondItemID = UUID().uuidString
        let enableWhen = QuestionnaireItemEnableWhen(answer: .decimal(100.0),
                                                     operator: FHIRPrimitive(QuestionnaireItemOperator.equal),
                                                     question: FHIRPrimitive(FHIRString(firstItemID)))

        let task = try createORKNavigableOrderedTask(firstItemID: firstItemID,
                                                     secondItemID: secondItemID,
                                                     enableWhen: enableWhen)
        XCTAssertNotNil(task.skipNavigationRule(forStepIdentifier: secondItemID))
    }

    func testDecimalNotEqual() throws {
        let firstItemID = UUID().uuidString, secondItemID = UUID().uuidString
        let enableWhen = QuestionnaireItemEnableWhen(answer: .decimal(100.0),
                                                     operator: FHIRPrimitive(QuestionnaireItemOperator.notEqual),
                                                     question: FHIRPrimitive(FHIRString(firstItemID)))

        let task = try createORKNavigableOrderedTask(firstItemID: firstItemID,
                                                     secondItemID: secondItemID,
                                                     enableWhen: enableWhen)
        XCTAssertNotNil(task.skipNavigationRule(forStepIdentifier: secondItemID))
    }

    func testDecimalGreaterThanOrEqual() throws {
        let firstItemID = UUID().uuidString, secondItemID = UUID().uuidString
        let enableWhen = QuestionnaireItemEnableWhen(answer: .decimal(100.0),
                                                     operator: FHIRPrimitive(QuestionnaireItemOperator.greaterThanOrEqual),
                                                     question: FHIRPrimitive(FHIRString(firstItemID)))

        let task = try createORKNavigableOrderedTask(firstItemID: firstItemID,
                                                     secondItemID: secondItemID,
                                                     enableWhen: enableWhen)
        XCTAssertNotNil(task.skipNavigationRule(forStepIdentifier: secondItemID))
    }

    func testDecimalLessThanOrEqual() throws {
        let firstItemID = UUID().uuidString, secondItemID = UUID().uuidString
        let enableWhen = QuestionnaireItemEnableWhen(answer: .decimal(100.0),
                                                     operator: FHIRPrimitive(QuestionnaireItemOperator.lessThanOrEqual),
                                                     question: FHIRPrimitive(FHIRString(firstItemID)))

        let task = try createORKNavigableOrderedTask(firstItemID: firstItemID,
                                                     secondItemID: secondItemID,
                                                     enableWhen: enableWhen)
        XCTAssertNotNil(task.skipNavigationRule(forStepIdentifier: secondItemID))
    }

    func testDateLessThan() throws {
        let firstItemID = UUID().uuidString, secondItemID = UUID().uuidString
        let enableWhen = QuestionnaireItemEnableWhen(answer: .date(FHIRPrimitive(try FHIRDate(date: Date()))),
                                                     operator: FHIRPrimitive(QuestionnaireItemOperator.lessThan),
                                                     question: FHIRPrimitive(FHIRString(firstItemID)))

        let task = try createORKNavigableOrderedTask(firstItemID: firstItemID,
                                                     secondItemID: secondItemID,
                                                     enableWhen: enableWhen)
        XCTAssertNotNil(task.skipNavigationRule(forStepIdentifier: secondItemID))
    }

    func testDateGreaterThan() throws {
        let firstItemID = UUID().uuidString, secondItemID = UUID().uuidString
        let enableWhen = QuestionnaireItemEnableWhen(answer: .date(FHIRPrimitive(try FHIRDate(date: Date()))),
                                                     operator: FHIRPrimitive(QuestionnaireItemOperator.greaterThan),
                                                     question: FHIRPrimitive(FHIRString(firstItemID)))

        let task = try createORKNavigableOrderedTask(firstItemID: firstItemID,
                                                     secondItemID: secondItemID,
                                                     enableWhen: enableWhen)
        XCTAssertNotNil(task.skipNavigationRule(forStepIdentifier: secondItemID))
    }

    func testCodingEqual() throws {
        let firstItemID = UUID().uuidString, secondItemID = UUID().uuidString
        let coding = Coding(code: FHIRPrimitive(FHIRString("testCode")),
                            system: FHIRPrimitive(FHIRURI("http://cardinalkit.org/fhir/system/testSystem")))
        let enableWhen = QuestionnaireItemEnableWhen(answer: .coding(coding),
                                                     operator: FHIRPrimitive(QuestionnaireItemOperator.equal),
                                                     question: FHIRPrimitive(FHIRString(firstItemID)))
        let task = try createORKNavigableOrderedTask(firstItemID: firstItemID,
                                                     secondItemID: secondItemID,
                                                     enableWhen: enableWhen)
        XCTAssertNotNil(task.skipNavigationRule(forStepIdentifier: secondItemID))
    }
}