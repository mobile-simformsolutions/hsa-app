//
//  XCUITestsFAQFlowTests.swift
//

import XCTest

final class XCUITestsFAQFlowTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Test FAQ flow
    //
    func testFAQflow() throws {
        let app = XCUIApplication()
        app.launch()

        var timeInterval = 5
        
        // Check for error alert and cancel action
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let cancelAlertBtn = springboard.buttons["Cancel"]
        if cancelAlertBtn.waitForExistence(timeout: TimeInterval(timeInterval)) {
            cancelAlertBtn.tap()
        }
        
        timeInterval = 15
        
        // Open menu
        let menuButton = app.buttons["menu"]
        XCTAssertTrue(menuButton.waitForExistence(timeout: TimeInterval(timeInterval)))
        menuButton.tap()
        
        // Open FAQ screen
        let faqText = app.staticTexts["FAQ"]
        XCTAssertTrue(faqText.waitForExistence(timeout: TimeInterval(timeInterval)))
        faqText.tap()
        
        timeInterval = 30
        
        // Close FAQ Screen
        let closeButton = app.buttons["Close"]
        if (closeButton.waitForExistence(timeout: TimeInterval(timeInterval))) {
            closeButton.tap()
        }
        
        timeInterval = 5
        
        // Close menu
        let closeMenuButton = app.buttons["closeLight"]
        XCTAssertTrue(closeMenuButton.waitForExistence(timeout: TimeInterval(timeInterval)))
        closeMenuButton.tap()
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}

