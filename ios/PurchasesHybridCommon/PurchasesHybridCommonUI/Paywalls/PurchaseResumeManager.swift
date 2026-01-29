//
//  PurchaseResumeManager.swift
//  PurchasesHybridCommonUI
//
//  Created by Jay Shortway.
//

#if canImport(UIKit) && !os(tvOS) && !os(watchOS)

import Foundation
import RevenueCatUI

/// Manages pending resume actions for purchase flows that require async user decisions.
/// This is used to bridge the native SDK's Resumable/ResumeAction pattern to hybrid SDKs.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
@objcMembers public class PurchaseResumeManager: NSObject {

    private static let lock = NSLock()
    private static var pendingResumeActions: [String: ResumeAction] = [:]

    /// Stores a resume action with a unique callback ID.
    /// - Parameters:
    ///   - callbackId: Unique identifier for this resume action
    ///   - resumeAction: The ResumeAction to store
    public static func store(callbackId: String, resumeAction: ResumeAction) {
        lock.lock()
        defer { lock.unlock() }
        pendingResumeActions[callbackId] = resumeAction
    }

    /// Resumes a pending purchase flow.
    /// - Parameters:
    ///   - callbackId: The callback ID received from onPurchasePackageInitiated
    ///   - shouldProceed: Whether to proceed with the purchase
    @MainActor
    public static func resumePurchase(callbackId: String, shouldProceed: Bool) {
        lock.lock()
        let resumeAction = pendingResumeActions.removeValue(forKey: callbackId)
        lock.unlock()

        resumeAction?.resume(shouldProceed: shouldProceed)
    }

    /// Generates a unique callback ID.
    /// - Returns: A new UUID string
    public static func generateCallbackId() -> String {
        return UUID().uuidString
    }

    /// Removes a pending resume action without invoking it.
    /// Used for cleanup when a paywall is dismissed without completing.
    /// - Parameter callbackId: The callback ID to remove
    public static func remove(callbackId: String) {
        lock.lock()
        defer { lock.unlock() }
        pendingResumeActions.removeValue(forKey: callbackId)
    }
}

#endif

