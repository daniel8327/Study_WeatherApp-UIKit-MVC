//
//  Alert.swift
//  GlobalFriend
//
//  Created by Daniel Chang on 2021/03/23.
//

import UIKit

class Alert: UIAlertController {
    // override 가능하도록 class function 사용 (static x)

    /// 세종 얼럿
    /// - Parameters:
    ///   - parent: 얼럿을 표현할 뷰컨트롤러
    ///   - title: 얼럿의 제목 (nil 일 경우 앱 이름으로 처리)
    ///   - message: 얼럿의 메세지
    class func show(parent: UIViewController?, title: String?, message: String) {
        show(parent: parent, title: title, message: message, preferredStyle: .alert, actionConfirmTitle: "ok", actionCancelTitle: nil)
    }

    /// 세종 얼럿
    /// - Parameters:
    ///   - parent: 얼럿을 표현할 뷰컨트롤러
    ///   - title: 얼럿의 제목 (nil 일 경우 앱 이름으로 처리)
    ///   - message: 얼럿의 메세지
    ///   - actionConfirmCallback: 확인버튼 콜백
    class func show(parent: UIViewController?, title: String?, message: String, actionConfirmCallback: ((UIAlertAction) -> Void)? = nil) {
        show(parent: parent, title: title, message: message, preferredStyle: .alert, actionConfirmTitle: nil, actionConfirmCallback: actionConfirmCallback, actionCancelTitle: nil, actionCancelCallback: nil)
    }

    /// 세종 얼럿
    /// - Parameters:
    ///   - parent: 얼럿을 표현할 뷰컨트롤러
    ///   - title: 얼럿의 제목 (nil 일 경우 앱 이름으로 처리)
    ///   - message: 얼럿의 메세지
    ///   - preferredStyle: 얼럿의 스타일
    ///   - actionConfirmTitle: 얼럿 확인버튼의 문자열
    ///   - actionConfirmCallback: 확인버튼 콜백
    ///   - actionCancelTitle: 얼럿 취소버튼의 문자열
    ///   - actionCancelCallback: 취소버튼 콜백
    class func show(parent: UIViewController?, title: String?, message: String, preferredStyle: UIAlertController.Style? = nil, actionConfirmTitle: String?, actionConfirmCallback: ((UIAlertAction) -> Void)? = nil, actionCancelTitle: String? = nil, actionCancelCallback: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title ?? "", message: message, preferredStyle: preferredStyle ?? .alert)

        let alertConfirmAction = UIAlertAction(title: actionConfirmTitle ?? "ok", style: .default, handler: actionConfirmCallback)
        alert.addAction(alertConfirmAction)

        if let cancelTitle = actionCancelTitle {
            let alertCancelAction = UIAlertAction(title: cancelTitle, style: .default, handler: actionCancelCallback)
            alert.addAction(alertCancelAction)
        }

        
        if parent == nil, let topVC = UIApplication.getTopViewController() {
            topVC.present(alert, animated: true, completion: nil)
        } else {
            parent!.present(alert, animated: true, completion: nil)
        }
    }
}
