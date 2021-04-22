//
//  DetailWeatherBodyCell.swift
//  Weather
//
//  Created by moonkyoochoi on 2021/04/22.
//

import UIKit

import Kingfisher
import SwiftyJSON


class DetailWeatherBodyCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionLayout: UICollectionViewFlowLayout! {
        didSet {
            //collectionLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            collectionLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
    }
    
    private var hourly: [JSON]?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //collectionView.register(DetailWeatherCollectionViewCell.self, forCellWithReuseIdentifier: "DetailWeatherCollectionViewCell") // code base
        collectionView.register(UINib(nibName: "DetailWeatherCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DetailWeatherCollectionViewCell") // ui base
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
        //layout.estimatedItemSize = CGSize(width: 60, height: 138)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.sectionInsetReference = .fromLayoutMargins
//        (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//        (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).sectionInsetReference = .fromLayoutMargins
        
        layout.invalidateLayout()
    }
    
    func setHourly(hourly: [JSON]) {
        
        self.hourly = hourly
        
        collectionView.dataSource = self
        
    }
}

extension DetailWeatherBodyCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return hourly?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailWeatherCollectionViewCell.reusableIdentifier, for: indexPath) as? DetailWeatherCollectionViewCell,
              let hourly = hourly
        else { fatalError() }
        
        let data = hourly[indexPath.row]
        
        cell.dt.text = data["dt"].stringValue
        cell.temp.text = data["temp"].stringValue
        
        cell.icon.image = UIImage(named: "dash.png")
    
        if let icon = data["weather"][0]["icon"].string {
            
            let iconURL = "http://openweathermap.org/img/wn/\(icon)@2x.png"
            
            //print("icon: \(iconURL)")
            cell.icon.kf.setImage(with: URL(string: iconURL))
            //cell.icon.kf.setImage(with: URL(string: iconURL))
        }
        
        cell.backgroundColor = .random
        
        return cell
    }
}

extension DetailWeatherBodyCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }

    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
}
