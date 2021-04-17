//
//  Indicator.swift
//  Weather
//
//  Created by 장태현 on 2021/04/17.
//

import UIKit

class Indicator: UIView {
    
    static let INSTANCE = Indicator()

    private var indicator = UIActivityIndicatorView()

    private init() {
        super.init(frame: UIScreen.main.bounds)
    }

    private init(aView: UIView) {
        super.init(frame: aView.frame)
        indicator = UIActivityIndicatorView(frame: aView.frame)
    }

    @available(*, unavailable)
    internal required init?(coder _: NSCoder) {
        fatalError()
    }

    /// 인디케이터 보여주기
    /// - Parameter aView: 인디케이터가 포함될 뷰
    func startAnimating(aView: UIView) {
        DispatchQueue.main.async {
            aView.addSubview(self.indicator)

            self.indicator.frame = aView.bounds
            self.indicator.backgroundColor = .black
            self.indicator.alpha = 0.3
            self.indicator.style = .large
            self.indicator.color = .orange
            self.indicator.startAnimating()
        }
    }

    /// 인디케이커 보여주기
    internal func startAnimating() {
        DispatchQueue.main.async {
            if self.indicator.isAnimating {
                self.terminateIndicator()
            }

            self.startAnimating(aView: _WINDOW)
        }
    }

    /// 인디케이터 멈추기
    internal func stopAnimating() {
        DispatchQueue.main.async {
            self.indicator.stopAnimating()
        }
    }

    /// 인디케이터 종료시키기
    internal func terminateIndicator() {
        DispatchQueue.main.async {
            self.indicator.stopAnimating()
            self.indicator.removeFromSuperview()
        }
    }
}
