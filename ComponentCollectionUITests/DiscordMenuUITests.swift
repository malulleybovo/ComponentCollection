//
//  DiscordMenuUITests.swift
//  ComponentCollectionUITests
//
//  Created by malulleybovo on 30/01/22.
//  Copyright © 2022 malulleybovo. All rights reserved.
//

import XCTest
@testable import ComponentCollection

class DiscordMenuUITests: XCTestCase {
    
    var app = XCUIApplication()
    let expectedMenuOffsetX: CGFloat = 30
    
    var rootView: XCUIElement { app.children(matching: .any).element.children(matching: .any).element.children(matching: .any).element.children(matching: .any).element }

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        let expectedDiscordMenuTableCell = rootView.cells.element(boundBy: 0)
        expectedDiscordMenuTableCell.tap()
    }

    override func tearDownWithError() throws {
        
    }
    
    func testInitialState() throws {
        let views = rootView.children(matching: .any)
        XCTAssertTrue(views.count == 1, "Expected only mainController to be in the hierarchy initially but found: \(views.count) view(s)")
        let expectedMainView = views.element(boundBy: 0)
        XCTAssertTrue(expectedMainView.frame.origin.x == rootView.frame.origin.x, "Expected mainController to have origin X \(rootView.frame.origin.x) but got: \(expectedMainView.frame.origin.x)")
    }
    
    func testOpenLeftMenuPartially() throws {
        let initialGestureLocation = app.windows.firstMatch
            .coordinate(withNormalizedOffset: CGVector(dx: 0.05, dy: 0.5))
        let finalGestureLocation = app.windows.firstMatch
            .coordinate(withNormalizedOffset: CGVector(dx: 0.29, dy: 0.5))
        initialGestureLocation.press(forDuration: 0.1, thenDragTo: finalGestureLocation)
        let views = rootView.children(matching: .any)
        XCTAssertTrue(views.count == 1, "Expected only mainController to be in the hierarchy initially but found: \(views.count) view(s)")
        let expectedMainView = views.element(boundBy: 0)
        XCTAssertTrue(expectedMainView.frame.origin.x == rootView.frame.origin.x, "Expected mainController to have origin X \(rootView.frame.origin.x) but got: \(expectedMainView.frame.origin.x)")
    }
    
    func testOpenLeftMenuJustEnough() throws {
        let initialGestureLocation = app.windows.firstMatch
            .coordinate(withNormalizedOffset: CGVector(dx: 0.05, dy: 0.5))
        let finalGestureLocation = app.windows.firstMatch
            .coordinate(withNormalizedOffset: CGVector(dx: 0.30, dy: 0.5))
        initialGestureLocation.press(forDuration: 0.1, thenDragTo: finalGestureLocation)
        let views = rootView.children(matching: .any)
        XCTAssertTrue(views.count == 2, "Expected only mainController and leftMenuController to be in the hierarchy upon swiping right but found: \(views.count) view(s)")
        let expectedLeftMenuView = views.element(boundBy: 0)
        let expectedMainView = views.element(boundBy: 1)
        XCTAssertTrue(expectedLeftMenuView.frame.origin.x == rootView.frame.origin.x, "Expected only leftMenuController to have the same origin X as its parent view (\(rootView.frame.origin.x)) but got: \(expectedLeftMenuView.frame.origin.x)")
        XCTAssertTrue(expectedLeftMenuView.frame.width == rootView.frame.width - expectedMenuOffsetX, "Expected only leftMenuController to have width \(rootView.frame.width - expectedMenuOffsetX) but got: \(expectedLeftMenuView.frame.width)")
        XCTAssertTrue(expectedMainView.frame.origin.x == rootView.frame.origin.x + rootView.frame.width - expectedMenuOffsetX, "Expected mainController to have origin X \(rootView.frame.origin.x + rootView.frame.width - expectedMenuOffsetX) but got: \(expectedMainView.frame.origin.x)")
    }

    func testOpenLeftMenuCompletely() throws {
        let initialGestureLocation = app.windows.firstMatch
            .coordinate(withNormalizedOffset: CGVector(dx: 0.02, dy: 0.5))
        let finalGestureLocation = app.windows.firstMatch
            .coordinate(withNormalizedOffset: CGVector(dx: 0.98, dy: 0.5))
        initialGestureLocation.press(forDuration: 0.1, thenDragTo: finalGestureLocation)
        let views = rootView.children(matching: .any)
        XCTAssertTrue(views.count == 2, "Expected only mainController and leftMenuController to be in the hierarchy upon swiping right but found: \(views.count) view(s)")
        let expectedLeftMenuView = views.element(boundBy: 0)
        let expectedMainView = views.element(boundBy: 1)
        XCTAssertTrue(expectedLeftMenuView.frame.origin.x == rootView.frame.origin.x, "Expected only leftMenuController to have the same origin X as its parent view (\(rootView.frame.origin.x)) but got: \(expectedLeftMenuView.frame.origin.x)")
        XCTAssertTrue(expectedLeftMenuView.frame.width == rootView.frame.width - expectedMenuOffsetX, "Expected only leftMenuController to have width \(rootView.frame.width - expectedMenuOffsetX) but got: \(expectedLeftMenuView.frame.width)")
        XCTAssertTrue(expectedMainView.frame.origin.x == rootView.frame.origin.x + rootView.frame.width - expectedMenuOffsetX, "Expected mainController to have origin X \(rootView.frame.origin.x + rootView.frame.width - expectedMenuOffsetX) but got: \(expectedMainView.frame.origin.x)")
    }
    
    func testCloseLeftMenuPartially() throws {
        let initialGestureLocation = app.windows.firstMatch
            .coordinate(withNormalizedOffset: CGVector(dx: 0.05, dy: 0.5))
        let intermediateGestureLocation = app.windows.firstMatch
            .coordinate(withNormalizedOffset: CGVector(dx: 0.50, dy: 0.5))
        let finalGestureLocation = app.windows.firstMatch
            .coordinate(withNormalizedOffset: CGVector(dx: 0.21, dy: 0.5))
        initialGestureLocation.press(forDuration: 0.1, thenDragTo: intermediateGestureLocation)
        finalGestureLocation.press(forDuration: 0.1, thenDragTo: initialGestureLocation)
        let views = rootView.children(matching: .any)
        XCTAssertTrue(views.count == 2, "Expected only mainController and leftMenuController to be in the hierarchy upon swiping right but found: \(views.count) view(s)")
        let expectedLeftMenuView = views.element(boundBy: 0)
        let expectedMainView = views.element(boundBy: 1)
        XCTAssertTrue(expectedLeftMenuView.frame.origin.x == rootView.frame.origin.x, "Expected only leftMenuController to have the same origin X as its parent view (\(rootView.frame.origin.x)) but got: \(expectedLeftMenuView.frame.origin.x)")
        XCTAssertTrue(expectedLeftMenuView.frame.width == rootView.frame.width - expectedMenuOffsetX, "Expected only leftMenuController to have width \(rootView.frame.width - expectedMenuOffsetX) but got: \(expectedLeftMenuView.frame.width)")
        XCTAssertTrue(expectedMainView.frame.origin.x == rootView.frame.origin.x + rootView.frame.width - expectedMenuOffsetX, "Expected mainController to have origin X \(rootView.frame.origin.x + rootView.frame.width - expectedMenuOffsetX) but got: \(expectedMainView.frame.origin.x)")
    }
    
    func testCloseLeftMenuJustEnough() throws {
        let initialGestureLocation = app.windows.firstMatch
            .coordinate(withNormalizedOffset: CGVector(dx: 0.05, dy: 0.5))
        let finalGestureLocation = app.windows.firstMatch
            .coordinate(withNormalizedOffset: CGVector(dx: 0.30, dy: 0.5))
        initialGestureLocation.press(forDuration: 0.1, thenDragTo: finalGestureLocation)
        finalGestureLocation.press(forDuration: 0.1, thenDragTo: initialGestureLocation)
        let views = rootView.children(matching: .any)
        XCTAssertTrue(views.count == 1, "Expected only mainController to be in the hierarchy initially but found: \(views.count) view(s)")
        let expectedMainView = views.element(boundBy: 0)
        XCTAssertTrue(expectedMainView.frame.origin.x == rootView.frame.origin.x, "Expected mainController to have origin X \(rootView.frame.origin.x) but got: \(expectedMainView.frame.origin.x)")
    }
    
    func testCloseLeftMenuCompletely() throws {
        let initialGestureLocation = app.windows.firstMatch
            .coordinate(withNormalizedOffset: CGVector(dx: 0.02, dy: 0.5))
        let finalGestureLocation = app.windows.firstMatch
            .coordinate(withNormalizedOffset: CGVector(dx: 0.98, dy: 0.5))
        initialGestureLocation.press(forDuration: 0.1, thenDragTo: finalGestureLocation)
        finalGestureLocation.press(forDuration: 0.1, thenDragTo: initialGestureLocation)
        let views = rootView.children(matching: .any)
        XCTAssertTrue(views.count == 1, "Expected only mainController to be in the hierarchy initially but found: \(views.count) view(s)")
        let expectedMainView = views.element(boundBy: 0)
        XCTAssertTrue(expectedMainView.frame.origin.x == rootView.frame.origin.x, "Expected mainController to have origin X \(rootView.frame.origin.x) but got: \(expectedMainView.frame.origin.x)")
    }
    
    
    
    
    
    func testOpenRightMenuPartially() throws {
        let initialGestureLocation = app.windows.firstMatch
            .coordinate(withNormalizedOffset: CGVector(dx: 0.29, dy: 0.5))
        let finalGestureLocation = app.windows.firstMatch
            .coordinate(withNormalizedOffset: CGVector(dx: 0.05, dy: 0.5))
        initialGestureLocation.press(forDuration: 0.1, thenDragTo: finalGestureLocation)
        let views = rootView.children(matching: .any)
        XCTAssertTrue(views.count == 1, "Expected only mainController to be in the hierarchy initially but found: \(views.count) view(s)")
        let expectedMainView = views.element(boundBy: 0)
        XCTAssertTrue(expectedMainView.frame.origin.x == rootView.frame.origin.x, "Expected mainController to have origin X \(rootView.frame.origin.x) but got: \(expectedMainView.frame.origin.x)")
    }
    
    func testOpenRightMenuJustEnough() throws {
        let initialGestureLocation = app.windows.firstMatch
            .coordinate(withNormalizedOffset: CGVector(dx: 0.30, dy: 0.5))
        let finalGestureLocation = app.windows.firstMatch
            .coordinate(withNormalizedOffset: CGVector(dx: 0.05, dy: 0.5))
        initialGestureLocation.press(forDuration: 0.1, thenDragTo: finalGestureLocation)
        let views = rootView.children(matching: .any)
        XCTAssertTrue(views.count == 2, "Expected only mainController and rightMenuController to be in the hierarchy upon swiping right but found: \(views.count) view(s)")
        let expectedMainView = views.element(boundBy: 0)
        let expectedRightMenuView = views.element(boundBy: 1)
        XCTAssertTrue(expectedRightMenuView.frame.origin.x == rootView.frame.origin.x + expectedMenuOffsetX, "Expected only rightMenuController to have origin X \(rootView.frame.origin.x + expectedMenuOffsetX) but got: \(expectedRightMenuView.frame.origin.x)")
        XCTAssertTrue(expectedRightMenuView.frame.width == rootView.frame.width - expectedMenuOffsetX, "Expected only rightMenuController to have width \(rootView.frame.width - expectedMenuOffsetX) but got: \(expectedRightMenuView.frame.width)")
        XCTAssertTrue(expectedMainView.frame.origin.x == rootView.frame.origin.x - rootView.frame.width + expectedMenuOffsetX, "Expected mainController to have origin X \(rootView.frame.origin.x - rootView.frame.width + expectedMenuOffsetX) but got: \(expectedMainView.frame.origin.x)")
    }

    func testOpenRightMenuCompletely() throws {
        let initialGestureLocation = app.windows.firstMatch
            .coordinate(withNormalizedOffset: CGVector(dx: 0.98, dy: 0.5))
        let finalGestureLocation = app.windows.firstMatch
            .coordinate(withNormalizedOffset: CGVector(dx: 0.02, dy: 0.5))
        initialGestureLocation.press(forDuration: 0.1, thenDragTo: finalGestureLocation)
        let views = rootView.children(matching: .any)
        XCTAssertTrue(views.count == 2, "Expected only mainController and rightMenuController to be in the hierarchy upon swiping right but found: \(views.count) view(s)")
        let expectedMainView = views.element(boundBy: 0)
        let expectedRightMenuView = views.element(boundBy: 1)
        XCTAssertTrue(expectedRightMenuView.frame.origin.x == rootView.frame.origin.x + expectedMenuOffsetX, "Expected only rightMenuController to have origin X \(rootView.frame.origin.x + expectedMenuOffsetX) but got: \(expectedRightMenuView.frame.origin.x)")
        XCTAssertTrue(expectedRightMenuView.frame.width == rootView.frame.width - expectedMenuOffsetX, "Expected only rightMenuController to have width \(rootView.frame.width - expectedMenuOffsetX) but got: \(expectedRightMenuView.frame.width)")
        XCTAssertTrue(expectedMainView.frame.origin.x == rootView.frame.origin.x - rootView.frame.width + expectedMenuOffsetX, "Expected mainController to have origin X \(rootView.frame.origin.x - rootView.frame.width + expectedMenuOffsetX) but got: \(expectedMainView.frame.origin.x)")
    }
    
    func testCloseRightMenuPartially() throws {
        let initialGestureLocation = app.windows.firstMatch
            .coordinate(withNormalizedOffset: CGVector(dx: 0.50, dy: 0.5))
        let intermediateGestureLocation = app.windows.firstMatch
            .coordinate(withNormalizedOffset: CGVector(dx: 0.21, dy: 0.5))
        let finalGestureLocation = app.windows.firstMatch
            .coordinate(withNormalizedOffset: CGVector(dx: 0.05, dy: 0.5))
        initialGestureLocation.press(forDuration: 0.1, thenDragTo: intermediateGestureLocation)
        intermediateGestureLocation.press(forDuration: 0.1, thenDragTo: finalGestureLocation)
        let views = rootView.children(matching: .any)
        XCTAssertTrue(views.count == 2, "Expected only mainController and rightMenuController to be in the hierarchy upon swiping right but found: \(views.count) view(s)")
        let expectedMainView = views.element(boundBy: 0)
        let expectedRightMenuView = views.element(boundBy: 1)
        XCTAssertTrue(expectedRightMenuView.frame.origin.x == rootView.frame.origin.x + expectedMenuOffsetX, "Expected only rightMenuController to have origin X \(rootView.frame.origin.x + expectedMenuOffsetX) but got: \(expectedRightMenuView.frame.origin.x)")
        XCTAssertTrue(expectedRightMenuView.frame.width == rootView.frame.width - expectedMenuOffsetX, "Expected only rightMenuController to have width \(rootView.frame.width - expectedMenuOffsetX) but got: \(expectedRightMenuView.frame.width)")
        XCTAssertTrue(expectedMainView.frame.origin.x == rootView.frame.origin.x - rootView.frame.width + expectedMenuOffsetX, "Expected mainController to have origin X \(rootView.frame.origin.x - rootView.frame.width + expectedMenuOffsetX) but got: \(expectedMainView.frame.origin.x)")
    }
    
    func testCloseRightMenuJustEnough() throws {
        let initialGestureLocation = app.windows.firstMatch
            .coordinate(withNormalizedOffset: CGVector(dx: 0.30, dy: 0.5))
        let finalGestureLocation = app.windows.firstMatch
            .coordinate(withNormalizedOffset: CGVector(dx: 0.05, dy: 0.5))
        initialGestureLocation.press(forDuration: 0.1, thenDragTo: finalGestureLocation)
        finalGestureLocation.press(forDuration: 0.1, thenDragTo: initialGestureLocation)
        let views = rootView.children(matching: .any)
        XCTAssertTrue(views.count == 1, "Expected only mainController to be in the hierarchy initially but found: \(views.count) view(s)")
        let expectedMainView = views.element(boundBy: 0)
        XCTAssertTrue(expectedMainView.frame.origin.x == rootView.frame.origin.x, "Expected mainController to have origin X \(rootView.frame.origin.x) but got: \(expectedMainView.frame.origin.x)")
    }
    
    func testCloseRightMenuCompletely() throws {
        let initialGestureLocation = app.windows.firstMatch
            .coordinate(withNormalizedOffset: CGVector(dx: 0.98, dy: 0.5))
        let finalGestureLocation = app.windows.firstMatch
            .coordinate(withNormalizedOffset: CGVector(dx: 0.05, dy: 0.5))
        initialGestureLocation.press(forDuration: 0.1, thenDragTo: finalGestureLocation)
        finalGestureLocation.press(forDuration: 0.1, thenDragTo: initialGestureLocation)
        let views = rootView.children(matching: .any)
        XCTAssertTrue(views.count == 1, "Expected only mainController to be in the hierarchy initially but found: \(views.count) view(s)")
        let expectedMainView = views.element(boundBy: 0)
        XCTAssertTrue(expectedMainView.frame.origin.x == rootView.frame.origin.x, "Expected mainController to have origin X \(rootView.frame.origin.x) but got: \(expectedMainView.frame.origin.x)")
    }

}
