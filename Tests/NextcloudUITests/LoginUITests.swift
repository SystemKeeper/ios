// SPDX-FileCopyrightText: 2025 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import XCTest

@MainActor
final class LoginUITests: BaseUIXCTestCase {

    // MARK: - Lifecycle

    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false

        // Handle alerts presented by the system.
        addUIInterruptionMonitor(withDescription: "Allow Notifications", for: "Allow")
        addUIInterruptionMonitor(withDescription: "Save Password", for: "Not Now")

        // Launch the app.
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }

    func testLogin() async throws {
        let initalLoginButton = app.buttons["login"]

        guard initalLoginButton.exists else {
            return
        }

        initalLoginButton.tap()

        let serverAddressTextField = app.textFields["serverAddress"].firstMatch
        serverAddressTextField.awaitOrFail()

        serverAddressTextField.tap()
        serverAddressTextField.typeText(TestConstants.server)

        app.buttons["submitServerAddress"].tap()

        let webView = app.webViews.firstMatch
        waitForReady(object: webView, timeout: TestConstants.controlExistenceTimeoutLong)

        let loginButton = webView.buttons["Log in"]
        waitForReady(object: loginButton, timeout: TestConstants.controlExistenceTimeoutLong)

        loginButton.tap()

        let usernameTextField = webView.textFields.firstMatch
        let passwordSecureTextField = webView.secureTextFields.firstMatch

        usernameTextField.awaitOrFail(timeout: TestConstants.controlExistenceTimeoutLong)
        passwordSecureTextField.awaitOrFail(timeout: TestConstants.controlExistenceTimeoutLong)

        usernameTextField.tap()
        usernameTextField.typeText(TestConstants.username + "\n")

        passwordSecureTextField.tap()
        passwordSecureTextField.typeText(TestConstants.password + "\n")

        let accountAccess = webView.staticTexts["Account access"]
        XCTAssert(accountAccess.waitForExistence(timeout: TestConstants.controlExistenceTimeoutLong))

        let grantButton = webView.buttons["Grant access"]
        waitForReady(object: grantButton, timeout: TestConstants.controlExistenceTimeoutLong)

        grantButton.tap()
        grantButton.awaitInexistence()

        app.buttons["accountSwitcher"].await()
    }
}
