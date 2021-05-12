//
//  LocationCell.swift
//  Weather
//
//  Created by 장태현 on 2021/04/20.
//

import UIKit

import SkeletonView

class LocationCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var temperature: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.isSkeletonable = true
        
        containerView.isSkeletonable = true
        time.isSkeletonable = true
        locationName.isSkeletonable = true
        temperature.isSkeletonable = true
        
        
        containerView.skeletonCornerRadius = 8
        time.skeletonCornerRadius = 8
        locationName.skeletonCornerRadius = 8
        temperature.skeletonCornerRadius = 8
        
    }
}
