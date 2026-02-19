//
//  HybridPurchaseLogicBridge.swift
//  PurchasesHybridCommonUI
//
//  Created by Rick van der Linden.
//  Copyright © 2026 RevenueCat. All rights reserved.
//

#if !os(macOS) && !os(tvOS) && !os(watchOS)

import Foundation
import PurchasesHybridCommon
import RevenueCat
import RevenueCatUI

@available(iOS 15.0, *)
@objcMembers public class HybridPurchaseLogicBridge: NSObject {

    // MARK: - Constants

    @objc public static let eventKeyRequestId = "requestId"
    @objc public static let eventKeyPackageBeingPurchased = "packageBeingPurchased"

    @objc public static let resultSuccess = "SUCCESS"
    @objc public static let resultCancellation = "CANCELLATION"
    @objc public static let resultError = "ERROR"

    static let errorDomain = "com.revenuecat.purchases.hybridcommon.purchaselogic"
    static let errorCodeOperationFailed = 1

    // MARK: - Private

    private typealias PurchaseResult = (userCancelled: Bool, error: Error?)
    private typealias RestoreResult = (success: Bool, error: Error?)

    private enum PendingRequest {
        case purchase(CheckedContinuation<PurchaseResult, Never>)
        case restore(CheckedContinuation<RestoreResult, Never>)
    }

    private static let queue = DispatchQueue(label: "com.revenuecat.hybridcommon.purchaselogicbridge")
    private static var pendingRequests: [String: PendingRequest] = [:]

    /// The request IDs managed by this bridge instance.
    /// May contain already-resolved IDs since resolveResult is static and can't clean up here.
    /// This is harmless — cancelPending handles missing entries gracefully.
    private var instanceRequestIds: Set<String> = []

    // MARK: - Public

    private let onPerformPurchase: ((_ eventData: [String: Any]) -> Void)?
    private let onPerformRestore: ((_ eventData: [String: Any]) -> Void)?

    @objc public init(onPerformPurchase: ((_ eventData: [String: Any]) -> Void)?,
                      onPerformRestore: ((_ eventData: [String: Any]) -> Void)?) {
        self.onPerformPurchase = onPerformPurchase
        self.onPerformRestore = onPerformRestore
        super.init()
    }

    func makePerformPurchase() -> PerformPurchase {
        return { [weak self] packageToPurchase in
            guard let self = self else {
                return (userCancelled: true, error: nil)
            }

            return await self.sendRequest(
                createRequest: { .purchase($0) },
                data: [Self.eventKeyPackageBeingPurchased: packageToPurchase.dictionary],
                handler: self.onPerformPurchase,
                fallbackError: "No onPerformPurchase handler registered"
            )
        }
    }

    func makePerformRestore() -> PerformRestore {
        return { [weak self] in
            guard let self = self else {
                return (success: false, error: nil)
            }

            return await self.sendRequest(
                createRequest: { .restore($0) },
                data: [:],
                handler: self.onPerformRestore,
                fallbackError: "No onPerformRestore handler registered"
            )
        }
    }

    @objc public class func resolveResult(requestId: String,
                                          resultString: String,
                                          errorMessage: String?) {
        let request: PendingRequest? = queue.sync {
            pendingRequests.removeValue(forKey: requestId)
        }

        guard let request = request else {
            NSLog("[HybridPurchaseLogicBridge] Warning: No pending callback for requestId '%@'. " +
                  "It may have already been resolved.", requestId)
            return
        }

        let error = makeError(resultString: resultString, errorMessage: errorMessage)

        switch request {
        case .purchase(let continuation):
            continuation.resume(returning: (
                userCancelled: resultString == resultCancellation,
                error: error
            ))
        case .restore(let continuation):
            continuation.resume(returning: (
                success: resultString == resultSuccess,
                error: error
            ))
        }
    }

    @objc public class func resolveResult(requestId: String, resultString: String) {
        resolveResult(requestId: requestId, resultString: resultString, errorMessage: nil)
    }

    /// Cancels pending requests owned by this instance.
    /// Called by PaywallProxy on dismiss, and by hybrid SDKs (e.g. RN) for embedded view cleanup.
    @objc public func cancelPending() {
        let requests: [PendingRequest] = Self.queue.sync {
            let owned = instanceRequestIds.compactMap { Self.pendingRequests.removeValue(forKey: $0) }
            instanceRequestIds.removeAll()
            return owned
        }

        for request in requests {
            switch request {
            case .purchase(let continuation):
                continuation.resume(returning: (userCancelled: true, error: nil))
            case .restore(let continuation):
                continuation.resume(returning: (success: false, error: nil))
            }
        }
    }

    // MARK: - Private helpers

    private func sendRequest<T>(
        createRequest: @escaping (CheckedContinuation<T, Never>) -> PendingRequest,
        data: [String: Any],
        handler: (([String: Any]) -> Void)?,
        fallbackError: String
    ) async -> T {
        let requestId = UUID().uuidString

        return await withCheckedContinuation { continuation in
            Self.queue.sync {
                Self.pendingRequests[requestId] = createRequest(continuation)
                self.instanceRequestIds.insert(requestId)
            }

            var eventData: [String: Any] = [Self.eventKeyRequestId: requestId]
            eventData.merge(data) { _, new in new }

            DispatchQueue.main.async {
                guard let handler = handler else {
                    Self.resolveResult(requestId: requestId,
                                       resultString: Self.resultError,
                                       errorMessage: fallbackError)
                    return
                }
                handler(eventData)
            }
        }
    }

    private static func makeError(resultString: String, errorMessage: String?) -> Error? {
        switch resultString {
        case resultSuccess, resultCancellation:
            return nil
        default:
            return NSError(
                domain: errorDomain,
                code: errorCodeOperationFailed,
                userInfo: [NSLocalizedDescriptionKey: errorMessage ?? "Operation failed"]
            )
        }
    }
}

#endif
