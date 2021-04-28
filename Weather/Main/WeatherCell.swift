//
//  WeatherCell.swift
//  Weather
//
//  Created by 장태현 on 2021/04/20.
//

import UIKit

class WeatherCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var temperature: UILabel!
}
