//
//  UICommon.swift
//  Weather
//
//  Created by 장태현 on 2021/04/17.
//

import UIKit

class UICommon {
    
    // MARK: Animation

    /// TransitionAnimation - 화면 전환 애미메이션
    /// - Parameter navi: UINavigationController
    class func setTransitionAnimation(navi: UINavigationController?) {
        // 화면 전환 애미메이션
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = .fade
        transition.subtype = .fromTop

        navi?.view.layer.add(transition, forKey: kCATransition)
    }
}
