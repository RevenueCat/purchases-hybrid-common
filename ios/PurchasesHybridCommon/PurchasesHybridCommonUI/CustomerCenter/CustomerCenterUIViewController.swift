//
//  CustomerCenterViewController.swift
//  PurchasesHybridCommon
//
//  Created by Facundo Menzella on 17/2/25.
//  Copyright © 2025 RevenueCat. All rights reserved.
//

#if os(iOS)

import Foundation
import PurchasesHybridCommon
import RevenueCat
import RevenueCatUI
import UIKit
import SwiftUI

@available(iOS 15.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
@objc
public final class CustomerCenterUIViewController: UIViewController {

    /// See ``CustomerCenterViewControllerDelegateWrapper`` for receiving events.
    @objc
    public weak var delegate: CustomerCenterViewControllerDelegateWrapper?

    @objc
    public var onCloseHandler: (() -> Void)?

    @objc
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
      
    /// Create a view controller to handle common customer support tasks
    /// - Parameters:
    ///   - customerCenterActionHandler: An optional `CustomerCenterActionHandler` to handle actions
    ///   from the Customer Center.
    init(
        customerCenterActionHandler: CustomerCenterActionHandler? = nil
    ) {
        super.init(nibName: nil, bundle: nil)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        let vc = createHostingController()

        addChild(vc)

        view.subviews.forEach { $0.removeFromSuperview() }

        view.addSubview(vc.view)
        vc.didMove(toParent: self)

        NSLayoutConstraint.activate([
            vc.view.topAnchor.constraint(equalTo: view.topAnchor),
            vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            vc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    public override func viewDidDisappear(_ animated: Bool) {
        if self.isBeingDismissed {
            self.delegate?.customerCenterViewControllerWasDismissed?(self)
        }
        super.viewDidDisappear(animated)
    }

    @available(*, unavailable, message: "Use init(customerCenterActionHandler:mode:) instead.")
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@available(iOS 15.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension CustomerCenterUIViewController {

    func createHostingController() -> UIViewController {
        let view = CustomerCenterView(
            customerCenterActionHandler: nil,
            navigationOptions: CustomerCenterNavigationOptions(
                onCloseHandler: onCloseHandler
            )
        )

        let controller = UIHostingController(rootView: view)

        // make the background of the container clear so that if there are cutouts, they don't get
        // overridden by the hostingController's view's background.
        controller.view.backgroundColor = UIColor.clear
        controller.view.translatesAutoresizingMaskIntoConstraints = false

        return controller
    }
}

#endif
