//
//  CommonFunctionality+Authentication.swift
//  PurchasesHybridCommon
//
//  Copyright © 2026 RevenueCat. All rights reserved.
//

import Foundation
@_spi(Internal) import RevenueCat

/// The parts of ``Authentication`` the bridge uses, so tests can replace it.
internal protocol HybridAuthentication: AnyObject {

    var delegate: AuthenticationDelegate? { get set }
    var currentAccessToken: String? { get }

    func logIn(using token: Identity, completion: @escaping (CustomerInfo?, PublicError?) -> Void)

}

extension Authentication: HybridAuthentication {}

// MARK: - IAM

@objc public extension CommonFunctionality {

    /// Experimental. Logs in through IAM with an identity dictionary of `source` (`apple`, `oidc`, `google` or
    /// `firebase`) and `token` (the provider's raw ID token). `facebook` isn't supported on iOS yet. Requires
    /// configuring with `iamEnabled`.
    ///
    /// The completion receives the new user's CustomerInfo dictionary.
    @objc(logInWithIdentity:completionBlock:)
    static func logIn(identity: [String: Any], completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        switch Identity.from(hybridIdentity: identity) {
        case let .failure(error):
            completion(nil, Self.createErrorContainer(error: error))
        case let .success(identity):
            Self.authentication.logIn(using: identity,
                                      completion: Self.customerInfoCompletionBlock(from: completion))
        }
    }

    /// Experimental. The current user's IAM access token, or `nil` if there isn't one.
    @objc static var currentAccessToken: String? { Self.authentication.currentAccessToken }

    /// Experimental. Listens for authentication errors that no explicit call reports, and for access-token
    /// changes. Both are called on the main thread. Replaces any previous listener.
    @objc(setAuthenticationListenerWithOnError:onAccessTokenUpdated:)
    static func setAuthenticationListener(onError: @escaping (ErrorContainer) -> Void,
                                          onAccessTokenUpdated: @escaping (String?) -> Void) {
        let delegate = AuthenticationDelegateBridge(onError: onError, onAccessTokenUpdated: onAccessTokenUpdated)
        Self.authenticationDelegate = delegate
        Self.authentication.delegate = delegate
    }

    /// Experimental. Removes the listener set with ``setAuthenticationListener(onError:onAccessTokenUpdated:)``.
    @objc static func removeAuthenticationListener() {
        Self.authenticationDelegate = nil
        Self.authentication.delegate = nil
    }

}

internal extension CommonFunctionality {

    /// Set by tests; otherwise the configured SDK's ``Authentication``.
    static var authenticationOverride: HybridAuthentication? {
        get { AuthenticationStorage.override }
        set { AuthenticationStorage.override = newValue }
    }

    /// The native SDK holds its delegate weakly, so the bridge keeps it alive here.
    static var authenticationDelegate: AuthenticationDelegate? {
        get { AuthenticationStorage.delegate }
        set { AuthenticationStorage.delegate = newValue }
    }

    static var authentication: HybridAuthentication {
        Self.authenticationOverride ?? Purchases.shared.authentication
    }

}

private enum AuthenticationStorage {

    static var override: HybridAuthentication?
    static var delegate: AuthenticationDelegate?

}

// MARK: - Identity mapping

internal enum HybridIdentityKey {

    static let source = "source"
    static let token = "token"

}

internal extension Identity {

    /// Builds an ``Identity`` from a hybrid dictionary of `source` (an ``IdentitySource`` raw value) and `token`
    /// (the raw ID token string).
    static func from(hybridIdentity map: [String: Any]) -> Result<Identity, NSError> {
        guard let sourceValue = map[HybridIdentityKey.source] as? String else {
            return .failure(Self.error(.unsupportedError, "Identity is missing a '\(HybridIdentityKey.source)'."))
        }
        guard let token = map[HybridIdentityKey.token] as? String, !token.isEmpty else {
            return .failure(Self.error(.invalidCredentialsError,
                                       "Identity is missing a '\(HybridIdentityKey.token)'."))
        }
        let tokenData = Data(token.utf8)

        if sourceValue == IdentitySource.facebook.rawValue {
            // purchases-ios has no public Facebook factory yet.
            return .failure(Self.error(.unsupportedError, "Facebook identities aren't supported on iOS yet."))
        }
        // Anonymous is left out: the SDK creates anonymous identities itself.
        let factories: [String: (Data) -> Identity] = [
            IdentitySource.signInWithApple.rawValue: Identity.signInWithApple,
            IdentitySource.oidc.rawValue: Identity.oidc,
            IdentitySource.google.rawValue: Identity.google,
            IdentitySource.firebase.rawValue: Identity.firebase
        ]
        guard let factory = factories[sourceValue] else {
            return .failure(Self.error(.unsupportedError, "Unsupported identity source '\(sourceValue)'."))
        }
        return .success(factory(tokenData))
    }

    private static func error(_ code: ErrorCode, _ message: String) -> NSError {
        return NSError(domain: ErrorCode.errorDomain,
                       code: code.rawValue,
                       userInfo: [NSLocalizedDescriptionKey: message])
    }

}

// MARK: - AuthenticationDelegateBridge

private final class AuthenticationDelegateBridge: NSObject, AuthenticationDelegate {

    private let onError: (ErrorContainer) -> Void
    private let onAccessTokenUpdated: (String?) -> Void

    init(onError: @escaping (ErrorContainer) -> Void, onAccessTokenUpdated: @escaping (String?) -> Void) {
        self.onError = onError
        self.onAccessTokenUpdated = onAccessTokenUpdated
    }

    func authenticatorDidEncounterError(_ error: PublicError) {
        self.onError(ErrorContainer(error: error, extraPayload: [:]))
    }

    func authenticatorDidUpdateAccessToken(_ newAccessToken: String?) {
        self.onAccessTokenUpdated(newAccessToken)
    }

}
