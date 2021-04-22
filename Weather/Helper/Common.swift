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
    
    /// 언어 -지역 코드 가져가기
    /// - Returns: String 디바이스의 언어-지역 코드 ex. ko-KR
    public static func getLanguageCountryCode() -> String {
        let languages = _UDS.array(forKey: "AppleLanguages")!
        let currentLanguage = languages[0] as! String
        return currentLanguage
    }
    
    /// 지역 코드 가져가기
    /// - Returns: String 디바이스의 지역 코드
    public static func getCountryCode() -> String {
        
        let lang = NSLocale.preferredLanguages[0]
        let langDic = NSLocale.components(fromLocaleIdentifier: lang)
        
        let locaCode = langDic["kCFLocaleCountryCodeKey"]
        let _ = langDic["kCFLocaleLanguageCodeKey"]
        
        return locaCode ?? ""
    }
    
    // MARK: 뷰 꾸미기

    /// 라운드 코너 만들기
    /// - Parameters:
    ///   - view: 대상 View
    ///   - corners: UIRectCorner[.topLeft .topRight .bottomLeft .bottomRight .allCorner]
    ///   - size: CGFloat
    public class func roundCorners(view: UIView, corners: UIRectCorner, size: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: size, height: size))

        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
        maskLayer.path = maskPath.cgPath

        view.layer.mask = maskLayer
    }

}
