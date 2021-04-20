//
//  LocationFooter.swift
//  Weather
//
//  Created by 장태현 on 2021/04/19.
//

import UIKit

class LocationFooter: UIView {
    
    @IBOutlet weak var notation: UILabel!
    @IBOutlet weak var theWeather: UIImageView!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let notationGesture = UITapGestureRecognizer(target: self, action: #selector(changeNotation))
        notation.addGestureRecognizer(notationGesture)
        notation.isUserInteractionEnabled = true
        
        let webGesture = UITapGestureRecognizer(target: self, action: #selector(goToWeb))
        theWeather.addGestureRecognizer(webGesture)
        theWeather.isUserInteractionEnabled = true
        
        notation.tag = 1
        //NotificationCenter.default.post(name: Notification.Name("CHANGE_NOTATION"), object: nil)
        
        
        // footer 바꾸기
        let attributeString = NSMutableAttributedString(string: notation.text ?? "")
        
        let str = notation.text!
        
        let r1 = str.range(of: fahrenheitOrCelsius.emoji)!
        // String range to NSRange:
        let n1 = NSRange(r1, in: str)
        
        attributeString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: n1)

        notation.attributedText = attributeString
    }
    
    @objc func goToWeb() {
        UIApplication.shared
            .open(URL(string: "https://weather.com/")!,
                  options: [:],
                  completionHandler: nil)
    }
    
    @objc func changeNotation() {
        NotificationCenter.default.post(name: Notification.Name("CHANGE_NOTATION"), object: nil)
    }
    
    @IBAction func searchLocationTapped(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("ADD_LOCATION"), object: nil)
    }
}
