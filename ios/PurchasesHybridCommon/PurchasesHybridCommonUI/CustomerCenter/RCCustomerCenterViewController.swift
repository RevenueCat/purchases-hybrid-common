//
//  RCCustomerCenterViewController.swift
//  Pods
//
//  Created by Facundo Menzella on 17/2/25.
//

#if !os(macOS) && !os(tvOS) && !os(watchOS)

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
@objc
class RCCustomerCenterViewController: UIViewController {

    /// Create a view controller to handle common customer support tasks
    /// - Parameters:
    ///   - customerCenterActionHandler: An optional `CustomerCenterActionHandler` to handle actions
    ///   from the Customer Center.
    public init(
        customerCenterActionHandler: CustomerCenterActionHandler? = nil
    ) {
        super.init(nibName: nil, bundle: nil)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        if self.hostingController == nil {
            self.hostingController = self.createHostingController()
        }
    }

    @available(*, unavailable, message: "Use init(customerCenterActionHandler:mode:) instead.")
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private var hostingController: UIViewController? {
        willSet {
            guard let oldController = self.hostingController else { return }

            oldController.willMove(toParent: nil)
            oldController.view.removeFromSuperview()
            oldController.removeFromParent()
        }

        didSet {
            guard let newController = self.hostingController else { return }

            self.addChild(newController)

            self.view.subviews.forEach { $0.removeFromSuperview() }

            self.view.addSubview(newController.view)
            newController.didMove(toParent: self)

            NSLayoutConstraint.activate([
                newController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
                newController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                newController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                newController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            ])
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
private extension RCCustomerCenterViewController {

    // swiftlint:disable:next function_body_length
    func createHostingController() -> UIViewController {
        let view = CustomerCenterView()

        let controller = UIHostingController(rootView: view)

        // make the background of the container clear so that if there are cutouts, they don't get
        // overridden by the hostingController's view's background.
        controller.view.backgroundColor = .clear
        controller.view.translatesAutoresizingMaskIntoConstraints = false

        return controller
    }
}

#endif
