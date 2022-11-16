//
//  XCUITestsAppFlowTests.swift
//

import XCTest

class XCUITestsAppFlowTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAppFlow() throws {
        let app = XCUIApplication()
        app.launch()

        let timeInterval = 15
        
        // Check for error alert and cancel action
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let cancelAlertBtn = springboard.buttons["Cancel"]
        if cancelAlertBtn.waitForExistence(timeout: 5) {
            cancelAlertBtn.tap()
        }
        
        // Tap on HSA Tab
        let hsaTab = app.tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(hsaTab.waitForExistence(timeout: TimeInterval(timeInterval)))
        hsaTab.tap()
        
        // Check for error alert and cancel action
        let cancelAlertBtn1 = springboard.buttons["Cancel"]
        if cancelAlertBtn1.waitForExistence(timeout: 5) {
            cancelAlertBtn1.tap()
        }
        
        // Tap on Dashboard Tab
        let dashboardTab = app.tabBars.buttons.element(boundBy: 0)
        XCTAssertTrue(dashboardTab.waitForExistence(timeout: TimeInterval(timeInterval)))
        dashboardTab.tap()
        
        // Check for error alert and cancel action
        let cancelAlertBtn2 = springboard.buttons["Cancel"]
        if cancelAlertBtn2.waitForExistence(timeout: 5) {
            cancelAlertBtn2.tap()
        }
        
        // Open Transaction History screen
        let seeAllText = app.buttons["See all"]
        XCTAssertTrue(seeAllText.waitForExistence(timeout: TimeInterval(timeInterval)))
        seeAllText.tap()
                
        // Close Transaction History Screen
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssertTrue(backButton.waitForExistence(timeout: TimeInterval(timeInterval)))
        backButton.tap()
        
        // Open menu
        let menuButton = app.buttons["menu"]
        XCTAssertTrue(menuButton.waitForExistence(timeout: TimeInterval(timeInterval)))
        menuButton.tap()
        
        // Open Contactus screen
        let contactUsText = app.staticTexts["Contact us"]
        XCTAssertTrue(contactUsText.waitForExistence(timeout: TimeInterval(timeInterval)))
        contactUsText.tap()
        
        // Close Contactus Screen
        let closeContactUsButton = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssertTrue(closeContactUsButton.waitForExistence(timeout: TimeInterval(timeInterval)))
        closeContactUsButton.tap()
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
