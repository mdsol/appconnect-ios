//
//  AppConnectSwiftUnitTests.swift
//  AppConnectSwiftUnitTests
//
//  Created by Nan Li on 10/30/18.
//  Copyright © 2018 Medidata Solutions. All rights reserved.
//

import XCTest
@testable import AppConnectSwift

class PasswordTest: XCTestCase {

    var password = ""
    
    func testCorrectPassword() {
        password = "12345678abcA"
        XCTAssertTrue(PasswordViewController.validatePassword(password))
    }
    
    func testWrongPasswordWithLowerCaseMissed() {
        password = "12345678ABC"
        XCTAssertFalse(PasswordViewController.validatePassword(password))
    }
    
    func testWrongPasswordWithUpperCaseMissed() {
        password = "12345678abc"
        XCTAssertFalse(PasswordViewController.validatePassword(password))
    }
    
    func testTooShortPassword() {
        password = "123abcD"
        XCTAssertFalse(PasswordViewController.validatePassword(password))
    }
    
    func testCorrectPasswordWithSpecialSymbol() {
        password = "12345678abcA%"
        XCTAssertTrue(PasswordViewController.validatePassword(password))
    }
    
    func testCorrectPasswordWithWhiteSpaceInMiddle() {
        password = "12345678 bcA"
        XCTAssertTrue(PasswordViewController.validatePassword(password))
    }
    
    func testEmptyPassword() {
        password = ""
        XCTAssertFalse(PasswordViewController.validatePassword(password))
    }
    
    func testWhiteSpacePassword() {
        password = " "
        XCTAssertFalse(PasswordViewController.validatePassword(password))
    }
}
