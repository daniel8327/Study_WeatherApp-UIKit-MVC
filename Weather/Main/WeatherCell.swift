//
//  WeatherCell.swift
//  Weather
//
//  Created by 장태현 on 2021/04/20.
//

import UIKit

class WeatherCell: UITableViewCell {
    
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var temperture: UILabel!
    
    
}
extension UIView {

    func setCardView(){
        layer.cornerRadius = 5.0
        layer.borderColor  =  UIColor.clear.cgColor
        layer.borderWidth = 5.0
        layer.shadowOpacity = 0.5
        layer.shadowColor =  UIColor.lightGray.cgColor
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width:5, height: 5)
        layer.masksToBounds = true
    }
}
