//
//  Extension+Etc.swift
//  GlobalFriend
//
//  Created by Daniel Chang on 2021/03/23.
//

import UIKit

// MARK: UIApplication

extension UIApplication {
    /// View 의 부모 구하기
    /// - Parameter base: UIViewController?
    /// - Returns: UIViewController?
    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}

// MARK: UIWindow

extension UIWindow {
    func visibleViewController() -> UIViewController? {
        if let rootViewController: UIViewController = self.rootViewController {
            return UIWindow.getVisibleViewControllerFrom(vc: rootViewController)
        }
        return nil
    }

    static func getVisibleViewControllerFrom(vc: UIViewController) -> UIViewController {
        if let navigationController = vc as? UINavigationController,
           let visibleController = navigationController.visibleViewController
        {
            return UIWindow.getVisibleViewControllerFrom(vc: visibleController)
        } else if let tabBarController = vc as? UITabBarController,
                  let selectedTabController = tabBarController.selectedViewController
        {
            return UIWindow.getVisibleViewControllerFrom(vc: selectedTabController)
        } else {
            if let presentedViewController = vc.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(vc: presentedViewController)
            } else {
                return vc
            }
        }
    }
}

// MARK: UINavigationController

extension UINavigationController {
    /// Transition Animation 을 입힌 popViewController
    /// - Parameter withTransition: animation 여부
    func popViewController(withTransition: Bool) {
        UICommon.setTransitionAnimation(navi: self)
        popViewController(animated: withTransition)
    }

    /// Transition Animation 을 입힌 pushViewController
    /// - Parameter withTransition: animation 여부
    func pushViewController(_ vc: UIViewController, withTransition: Bool) {
        UICommon.setTransitionAnimation(navi: self)
        pushViewController(vc, animated: withTransition)
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random(in: 0 ... 1),
                       green: .random(in: 0 ... 1),
                       blue: .random(in: 0 ... 1),
                       alpha: 1.0)
    }
}


extension NSObject {
    static var reusableIdentifier: String {
        return String(describing: self)
    }
}

extension Date {
    func calcuateGMT(time: Int) -> String {
        let timeZone = abs(time) / 3600
        let compare = time < 0 ? "-" : "+"

        if timeZone < 10 {
            return "GMT\(compare)0\(timeZone)"
        } else {
            return "GMT\(compare)\(timeZone)"
        }
    }
    
    func getCountryTime(byTimeZone time: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm a"
        formatter.timeZone = TimeZone(abbreviation: calcuateGMT(time: time))
        let defaultTimeZoneStr = formatter.string(from: self)
        return defaultTimeZoneStr
    }
    
    func getCountryTime2(dt time: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        formatter.timeZone = TimeZone(abbreviation: calcuateGMT(time: time))
        let defaultTimeZoneStr = formatter.string(from: self)
        return defaultTimeZoneStr
    }
    
    func convert(from initTimeZone: TimeZone, to targetTimeZone: TimeZone) -> Date {
        let delta = TimeInterval(initTimeZone.secondsFromGMT() - targetTimeZone.secondsFromGMT())
        return addingTimeInterval(delta)
    }
}
