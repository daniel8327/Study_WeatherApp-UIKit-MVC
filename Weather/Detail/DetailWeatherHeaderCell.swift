//
//  DetailWeatherHeaderCell.swift
//  Weather
//
//  Created by moonkyoochoi on 2021/04/22.
//

import UIKit

class DetailWeatherHeaderCell: UITableViewHeaderFooterView {
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var max: UILabel!
    @IBOutlet weak var min: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.isSkeletonable = true
        city.isSkeletonable = true
        weatherDescription.isSkeletonable = true
        temp.isSkeletonable = true
        max.isSkeletonable = true
        min.isSkeletonable = true
        
        city.skeletonCornerRadius = 8
        weatherDescription.skeletonCornerRadius = 8
        temp.skeletonCornerRadius = 8
        max.skeletonCornerRadius = 8
        min.skeletonCornerRadius = 8
    }
}

