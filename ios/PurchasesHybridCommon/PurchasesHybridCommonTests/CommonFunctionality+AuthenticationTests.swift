//
//  CommonFunctionality+AuthenticationTests.swift
//  PurchasesHybridCommonTests
//
//  Copyright © 2026 RevenueCat. All rights reserved.
//

import XCTest
import Nimble
@_spi(Internal) @testable import PurchasesHybridCommon
@_spi(Internal) @testable import RevenueCat

final class CommonFunctionalityAuthenticationTests: XCTestCase {

    private static let customerInfo = try! CustomerInfo.fromJSON(
        """
        {
            "request_date": "2019-08-16T10:30:42Z",
            "subscriber": {
                "first_seen": "2019-07-17T00:05:54Z",
                "original_app_user_id": "",
                "subscriptions": {},
                "other_purchases": {}
            }
        }
        """
    )

    private let token = "header.payload.signature"
    private var tokenData: Data { Data(self.token.utf8) }
    private var mockAuthentication: MockAuthentication!

    override func setUp() {
        super.setUp()
        self.mockAuthentication = MockAuthentication()
        CommonFunctionality.authenticationOverride = self.mockAuthentication
    }

    override func tearDown() {
        CommonFunctionality.authenticationOverride = nil
        CommonFunctionality.authenticationDelegate = nil
        super.tearDown()
    }

    // MARK: - Identity mapping

    func testMapsAppleIdentity() throws {
        expect(try self.authToken(["source": "apple", "token": self.token]))
            == IdentityAuthToken.signInWithApple(self.tokenData)
    }

    func testMapsOIDCIdentity() throws {
        expect(try self.authToken(["source": "oidc", "token": self.token])) == IdentityAuthToken.oidc(self.tokenData)
    }

    func testMapsGoogleIdentity() throws {
        expect(try self.authToken(["source": "google", "token": self.token])) == IdentityAuthToken.google(self.tokenData)
    }

    func testMapsFirebaseIdentity() throws {
        expect(try self.authToken(["source": "firebase", "token": self.token]))
            == IdentityAuthToken.firebase(self.tokenData)
    }

    func testEncodesNonASCIITokensAsUTF8() throws {
        let unicodeToken = "tökén-✓"
        expect(try self.authToken(["source": "oidc", "token": unicodeToken]))
            == IdentityAuthToken.oidc(Data(unicodeToken.utf8))
    }

    func testIdentitySourceRawValuesMatchHybridSources() {
        expect(IdentitySource.allCases.map(\.rawValue))
            .to(contain("apple", "oidc", "google", "firebase", "facebook", "anonymous"))
    }

    func testRejectsFacebookOnIOS() {
        let map: [String: Any] = ["source": "facebook", "token": self.token, "email": "a@b.com"]
        expect(self.mappingErrorCode(map)) == ErrorCode.unsupportedError.rawValue
    }

    func testRejectsAnonymousSource() {
        expect(self.mappingErrorCode(["source": "anonymous", "token": self.token]))
            == ErrorCode.unsupportedError.rawValue
    }

    func testRejectsUnknownSource() {
        expect(self.mappingErrorCode(["source": "myspace", "token": self.token])) == ErrorCode.unsupportedError.rawValue
    }

    func testRejectsMissingSource() {
        expect(self.mappingErrorCode(["token": self.token])) == ErrorCode.unsupportedError.rawValue
    }

    func testRejectsNonStringSource() {
        expect(self.mappingErrorCode(["source": 1, "token": self.token])) == ErrorCode.unsupportedError.rawValue
    }

    func testRejectsMissingToken() {
        expect(self.mappingErrorCode(["source": "google"])) == ErrorCode.invalidCredentialsError.rawValue
    }

    func testRejectsEmptyToken() {
        expect(self.mappingErrorCode(["source": "google", "token": ""])) == ErrorCode.invalidCredentialsError.rawValue
    }

    func testRejectsNonStringToken() {
        expect(self.mappingErrorCode(["source": "google", "token": 42])) == ErrorCode.invalidCredentialsError.rawValue
    }

    // MARK: - logIn(identity:)

    func testLogInPassesMappedIdentityToAuthentication() {
        CommonFunctionality.logIn(identity: ["source": "google", "token": self.token]) { _, _ in }

        expect(self.mockAuthentication.logInIdentities.map(\.authToken)) == [IdentityAuthToken.google(self.tokenData)]
    }

    func testLogInReturnsCustomerInfoDictionary() throws {
        self.mockAuthentication.stubbedLogInResult = (Self.customerInfo, nil)
        var result: [String: Any]?
        var error: ErrorContainer?

        CommonFunctionality.logIn(identity: ["source": "oidc", "token": self.token]) {
            result = $0
            error = $1
        }

        expect(try XCTUnwrap(result) as NSDictionary) == Self.customerInfo.dictionary as NSDictionary
        expect(error).to(beNil())
    }

    func testLogInReturnsNativeError() throws {
        let nativeError = NSError(domain: ErrorCode.errorDomain, code: ErrorCode.unsupportedError.rawValue)
        self.mockAuthentication.stubbedLogInResult = (nil, nativeError)
        var result: [String: Any]?
        var error: ErrorContainer?

        CommonFunctionality.logIn(identity: ["source": "oidc", "token": self.token]) {
            result = $0
            error = $1
        }

        expect(result).to(beNil())
        expect(try XCTUnwrap(error).error) == nativeError
    }

    func testLogInWithInvalidIdentityFailsWithoutCallingAuthentication() throws {
        var error: ErrorContainer?

        CommonFunctionality.logIn(identity: ["source": "anonymous", "token": self.token]) { error = $1 }

        expect(try XCTUnwrap(error).code) == ErrorCode.unsupportedError.rawValue
        expect(try XCTUnwrap(error).info["readableErrorCode"] as? String) == "UNSUPPORTED_ERROR"
        expect(self.mockAuthentication.logInIdentities).to(beEmpty())
    }

    // MARK: - currentAccessToken

    func testCurrentAccessTokenReturnsToken() {
        self.mockAuthentication.currentAccessToken = "access-token"
        expect(CommonFunctionality.currentAccessToken) == "access-token"
    }

    func testCurrentAccessTokenReturnsNilWithoutToken() {
        self.mockAuthentication.currentAccessToken = nil
        expect(CommonFunctionality.currentAccessToken).to(beNil())
    }

    // MARK: - Authentication listener

    func testSetAuthenticationListenerKeepsDelegateAlive() {
        // MockAuthentication holds its delegate weakly, like the SDK.
        CommonFunctionality.setAuthenticationListener(onError: { _ in }, onAccessTokenUpdated: { _ in })

        expect(self.mockAuthentication.delegate).toNot(beNil())
        expect(self.mockAuthentication.delegate === CommonFunctionality.authenticationDelegate) == true
    }

    func testListenerReceivesMappedErrors() throws {
        var errors: [ErrorContainer] = []
        CommonFunctionality.setAuthenticationListener(onError: { errors.append($0) }, onAccessTokenUpdated: { _ in })
        let nativeError = NSError(domain: ErrorCode.errorDomain, code: ErrorCode.invalidCredentialsError.rawValue)

        try XCTUnwrap(self.mockAuthentication.delegate).authenticatorDidEncounterError(nativeError)

        expect(errors.map(\.error)) == [nativeError]
        expect(errors.first?.code) == ErrorCode.invalidCredentialsError.rawValue
    }

    func testListenerReceivesTokenUpdatesIncludingNil() throws {
        var tokens: [String?] = []
        CommonFunctionality.setAuthenticationListener(onError: { _ in }, onAccessTokenUpdated: { tokens.append($0) })
        let delegate = try XCTUnwrap(self.mockAuthentication.delegate)

        delegate.authenticatorDidUpdateAccessToken?("new-token")
        delegate.authenticatorDidUpdateAccessToken?(nil)

        expect(tokens) == ["new-token", nil]
    }

    func testSettingNewListenerReplacesOldOne() throws {
        var first: [String?] = []
        var second: [String?] = []
        CommonFunctionality.setAuthenticationListener(onError: { _ in }, onAccessTokenUpdated: { first.append($0) })
        CommonFunctionality.setAuthenticationListener(onError: { _ in }, onAccessTokenUpdated: { second.append($0) })

        try XCTUnwrap(self.mockAuthentication.delegate).authenticatorDidUpdateAccessToken?("token")

        expect(first).to(beEmpty())
        expect(second) == ["token"]
    }

    func testRemoveAuthenticationListenerClearsDelegate() {
        CommonFunctionality.setAuthenticationListener(onError: { _ in }, onAccessTokenUpdated: { _ in })

        CommonFunctionality.removeAuthenticationListener()

        expect(self.mockAuthentication.delegate).to(beNil())
        expect(CommonFunctionality.authenticationDelegate).to(beNil())
    }

    // MARK: - configure

    func testConfigureWithIAMEnabled() {
        let purchases = self.configure(iamEnabled: true, keychainAccessGroup: nil)
        expect(Self.tokenManager(of: purchases)?.enabled) == true
    }

    func testConfigureWithIAMEnabledAndKeychainAccessGroup() {
        let purchases = self.configure(iamEnabled: true, keychainAccessGroup: "group.com.revenuecat.test")
        expect(Self.tokenManager(of: purchases)?.enabled) == true
    }

    func testConfigureWithIAMDisabled() {
        let purchases = self.configure(iamEnabled: false, keychainAccessGroup: nil)
        expect(Self.tokenManager(of: purchases)?.enabled) == false
    }

    func testDeprecatedConfigureLeavesIAMDisabled() {
        let purchases = Purchases.configure(apiKey: "api key",
                                            appUserID: nil,
                                            purchasesAreCompletedBy: "REVENUECAT",
                                            userDefaultsSuiteName: UUID().uuidString,
                                            platformFlavor: "hybrid-platform",
                                            platformFlavorVersion: "1.2.3",
                                            dangerousSettings: nil,
                                            verificationMode: nil,
                                            useExternalPurchaseCustomLinks: false,
                                            enableExternalPurchasesInSimulator: true)
        expect(Self.tokenManager(of: purchases)?.enabled) == false
    }

}

// MARK: - Helpers

private extension CommonFunctionalityAuthenticationTests {

    func authToken(_ map: [String: Any]) throws -> IdentityAuthToken {
        return try Identity.from(hybridIdentity: map).get().authToken
    }

    func mappingErrorCode(_ map: [String: Any]) -> Int? {
        guard case let .failure(error) = Identity.from(hybridIdentity: map),
              error.domain == ErrorCode.errorDomain else {
            return nil
        }
        return error.code
    }

    func configure(iamEnabled: Bool, keychainAccessGroup: String?) -> Purchases {
        return Purchases.configure(apiKey: "api key",
                                   appUserID: nil,
                                   purchasesAreCompletedBy: "REVENUECAT",
                                   userDefaultsSuiteName: UUID().uuidString,
                                   platformFlavor: "hybrid-platform",
                                   platformFlavorVersion: "1.2.3",
                                   dangerousSettings: nil,
                                   verificationMode: nil,
                                   useExternalPurchaseCustomLinks: false,
                                   enableExternalPurchasesInSimulator: true,
                                   iamEnabled: iamEnabled,
                                   keychainAccessGroup: keychainAccessGroup)
    }

    // The token manager is private to Authentication; its `enabled` reflects the configured IAM setting.
    static func tokenManager(of purchases: Purchases) -> TokenManager? {
        return Mirror(reflecting: purchases.authentication).children
            .first { $0.label == "tokenManager" }?
            .value as? TokenManager
    }

}

// MARK: - MockAuthentication

private final class MockAuthentication: HybridAuthentication {

    weak var delegate: AuthenticationDelegate?
    var currentAccessToken: String?

    var stubbedLogInResult: (CustomerInfo?, PublicError?)?
    private(set) var logInIdentities: [Identity] = []

    func logIn(using token: Identity, completion: @escaping (CustomerInfo?, PublicError?) -> Void) {
        self.logInIdentities.append(token)
        if let result = self.stubbedLogInResult {
            completion(result.0, result.1)
        }
    }

}
