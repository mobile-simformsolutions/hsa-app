//
//  NavigationUtil.swift
//

import SwiftUI

struct NavigationUtil {
    func popToRootView() {
        findNavigationController(
            viewController: UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController)?
            .popToRootViewController(animated: true)
    }
    
    func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
        guard let viewController = viewController else {
            return nil
        }
        
        if let navigationController = viewController as? UINavigationController {
            return navigationController
        }
        
        for childViewController in viewController.children {
            return findNavigationController(viewController: childViewController)
        }
        
        return nil
    }
    
    func popViewControllers(levels: Int) {
        let window = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?.windows
            .first(where: { $0.isKeyWindow })
        
        let navigation = window?.rootViewController?.children.first as? UINavigationController
        navigation?.popViewControllers(viewsToPop: levels)
    }
}

extension UINavigationController {
    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let viewController = viewControllers.filter({ $0.isKind(of: ofClass) }).last {
            popToViewController(viewController, animated: animated)
        }
    }
    
    func popViewControllers(viewsToPop: Int, animated: Bool = true) {
        if viewControllers.count > viewsToPop {
            let viewController = viewControllers[viewControllers.count - viewsToPop - 1]
            popToViewController(viewController, animated: animated)
        }
    }
    
    func popBack<T: UIViewController>(toControllerType: T.Type) {
        if var viewControllers: [UIViewController] = self.navigationController?.viewControllers {
            viewControllers = viewControllers.reversed()
            for currentViewController in viewControllers {
                if currentViewController .isKind(of: toControllerType) {
                    self.navigationController?.popToViewController(currentViewController, animated: true)
                    break
                }
            }
        }
    }
}
