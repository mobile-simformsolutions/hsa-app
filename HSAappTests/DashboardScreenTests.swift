//
//  DashboardScreenTests.swift
//

import XCTest
@testable import HSAapp
import Resolver

final class DashboardScreenTests: XCTestCase {

    // MARK: - Dependencies
    //
    @Injected private var networkStatusService: NetworkStatusService
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - API Test Functions
    //
    func testDashboardAPI() throws {
        // Check network connectivity
        try XCTSkipUnless(
            networkStatusService.connected,
            "Network connectivity needed for this test."
        )
        
        let promise = expectation(description: "Dashboard API called successfully.")
        
        Sync.shared.start { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed: \(error)")
            case .success:
                promise.fulfill()
            }
        }
        
        self.wait(for: [promise], timeout: 50)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
