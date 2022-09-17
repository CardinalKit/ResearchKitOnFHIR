//
// This source file is part of the ResearchKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2022 CardinalKit and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest


final class ExampleUITests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        continueAfterFailure = false
    }
    
    
    func testQuestionnaireJSON() throws {
        let app = XCUIApplication()
        app.launch()
        
        let skipLogicExampleButton = app.collectionViews.buttons["Skip Logic Example"]
        
        // Open context menu and view JSON
        skipLogicExampleButton.press(forDuration: 1.0)
        app.collectionViews.buttons["View JSON"].tap()
        app.swipeDown(velocity: XCUIGestureVelocity.fast)
    }
    
    func testSkipLogicExample() throws {
        let app = XCUIApplication()
        app.launch()
        
        let skipLogicExampleButton = app.collectionViews.buttons["Skip Logic Example"]
        
        // First run through questionnaire
        skipLogicExampleButton.tap()
        app.tables.staticTexts["Yes"].tap()
        app.tables.buttons["Next"].tap()
        app.tables.staticTexts["Chocolate"].tap()
        app.tables.staticTexts["Next"].tap()
        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "August")
        app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "31")
        app.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: "2021")
        app.buttons["Done"].tap()

        
        // Second run through questionnaire
        skipLogicExampleButton.tap()
        app.tables.staticTexts["No"].tap()
        app.buttons["Done"].tap()
        
        // Open context menu and view results
        skipLogicExampleButton.press(forDuration: 1.0)
        app.collectionViews.buttons["View Responses"].tap()
        
        let buttonsInResultView = app.collectionViews.allElementsBoundByIndex[1].buttons
        XCTAssertEqual(buttonsInResultView.count, 2)
        
        // First result
        buttonsInResultView.allElementsBoundByIndex[0].tap()
        app.navigationBars.buttons["Back"].tap()
        
        // Second result
        buttonsInResultView.allElementsBoundByIndex[1].tap()
        app.navigationBars.buttons["Back"].tap()
        
        // Dismiss results view
        app.swipeDown(velocity: XCUIGestureVelocity.fast)
    }

    func testContainedValueSetExample() throws {
        let app = XCUIApplication()
        app.launch()

        let containedValueSetExampleButton = app.collectionViews.buttons["Contained ValueSet Example"]

        // Complete questionnaire
        containedValueSetExampleButton.tap()
        app.tables.staticTexts["Yes"].tap()
        app.buttons["Done"].tap()

        // Open context menu and view results
        containedValueSetExampleButton.press(forDuration: 1.0)
        app.collectionViews.buttons["View Responses"].tap()

        // Check results
        let buttonsInResultView = app.collectionViews.allElementsBoundByIndex[1].buttons
        XCTAssertEqual(buttonsInResultView.count, 1)
        buttonsInResultView.allElementsBoundByIndex[0].tap()
        app.navigationBars.buttons["Back"].tap()

        // Dismiss results view
        app.swipeDown(velocity: XCUIGestureVelocity.fast)
    }

    func testNumberExample() throws {
        let app = XCUIApplication()
        app.launch()

        let numberExampleButton = app.collectionViews.buttons["Number Example"]

        // Open questionnaire
        numberExampleButton.tap()

        // Fill in integer field
        let integerField = app.textFields.element
        integerField.tap()
        integerField.typeText("1")
        app.buttons["Next"].tap()

        // Fill in decimal field
        let decimalField = app.textFields.element
        decimalField.tap()
        decimalField.typeText("1.5")
        app.buttons["Next"].tap()

        // Fill in quantity field
        let quantityField = app.textFields.element
        quantityField.tap()
        quantityField.typeText("2.5")

        // Finish questionnaire
        let doneButton = app.buttons.matching(identifier: "Done").element(boundBy: 1)
        doneButton.tap()

        // Open context menu and view results
        numberExampleButton.press(forDuration: 1.0)
        app.collectionViews.buttons["View Responses"].tap()

        // Check results
        let buttonsInResultView = app.collectionViews.allElementsBoundByIndex[1].buttons
        XCTAssertEqual(buttonsInResultView.count, 1)
        buttonsInResultView.allElementsBoundByIndex[0].tap()
        app.navigationBars.buttons["Back"].tap()

        // Dismiss results view
        app.swipeDown(velocity: XCUIGestureVelocity.fast)
    }

    func textValidationExample() throws {
        let app = XCUIApplication()
        app.launch()

        let textValidationExampleButton = app.collectionViews.buttons["Text Validation Example"]

        // Open questionnaire
        textValidationExampleButton.tap()

        // Fill in email
        let emailField = app.textFields.element
        emailField.tap()
        emailField.typeText("vishnu@cardinalkit.org")

        // Finish survey
        let doneButton = app.buttons.matching(identifier: "Done").element(boundBy: 1)
        doneButton.tap()

        // Open context menu and view results
        textValidationExampleButton.press(forDuration: 1.0)
        app.collectionViews.buttons["View Responses"].tap()

        // Check results
        let buttonsInResultView = app.collectionViews.allElementsBoundByIndex[1].buttons
        XCTAssertEqual(buttonsInResultView.count, 1)
        buttonsInResultView.allElementsBoundByIndex[0].tap()
        app.navigationBars.buttons["Back"].tap()

        // Dismiss results view
        app.swipeDown(velocity: XCUIGestureVelocity.fast)
    }

    func testPHQ9Example() throws {
        let app = XCUIApplication()
        app.launch()

        let phq9ExampleButton = app.collectionViews.buttons["Patient Health Questionnaire - 9 Item"]

        // Open questionnaire
        phq9ExampleButton.tap()

        // Answer all 9 questions
        let options = ["Not at all", "Several days", "More than half the days", "Nearly every day"]

        for i in 0...8 {
            let buttonQuery = app.tables.staticTexts.matching(identifier: options.randomElement()!).element(boundBy: i)
            buttonQuery.tap()
        }

        // Finish survey
        app.buttons["Done"].tap()

        // Open context menu and view results
        phq9ExampleButton.press(forDuration: 1.0)
        app.collectionViews.buttons["View Responses"].tap()

        // Check results
        let buttonsInResultView = app.collectionViews.allElementsBoundByIndex[1].buttons
        XCTAssertEqual(buttonsInResultView.count, 1)
        buttonsInResultView.allElementsBoundByIndex[0].tap()
        app.navigationBars.buttons["Back"].tap()

        // Dismiss results view
        app.swipeDown(velocity: XCUIGestureVelocity.fast)
    }

    func testGCSExample() throws {
        let app = XCUIApplication()
        app.launch()

        let gcsExampleButton = app.collectionViews.buttons["Glasgow Coma Score"]

        // Open questionnaire
        gcsExampleButton.tap()

        // Answer questions
        app.tables.staticTexts["Oriented"].tap()
        app.buttons["Next"].tap()

        app.tables.staticTexts["Obeys commands"].tap()
        app.buttons["Next"].tap()

        app.tables.staticTexts["Eyes open spontaneously"].tap()
        app.buttons["Done"].tap()

        // Open context menu and view results
        gcsExampleButton.press(forDuration: 1.0)
        app.collectionViews.buttons["View Responses"].tap()

        // Check results
        let buttonsInResultView = app.collectionViews.allElementsBoundByIndex[1].buttons
        XCTAssertEqual(buttonsInResultView.count, 1)
        buttonsInResultView.allElementsBoundByIndex[0].tap()
        app.navigationBars.buttons["Back"].tap()

        // Dismiss results view
        app.swipeDown(velocity: XCUIGestureVelocity.fast)
    }
}
