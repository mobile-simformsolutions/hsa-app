//
//  UINavigationController+EmptyBackButton.swift
//

import UIKit

extension UINavigationController {
    // Remove back button text
    override open func viewWillLayoutSubviews() {
        navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
