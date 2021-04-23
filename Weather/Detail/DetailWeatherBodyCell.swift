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
            collectionLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            //collectionLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
    }
    
    private var hourly: [JSON]?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //collectionView.register(DetailWeatherCollectionViewCell.self, forCellWithReuseIdentifier: "DetailWeatherCollectionViewCell") // code base
        collectionView.register(UINib(nibName: DetailWeatherCollectionViewCell.reusableIdentifier, bundle: nil), forCellWithReuseIdentifier: DetailWeatherCollectionViewCell.reusableIdentifier) // ui base
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
        
        
//        layout.estimatedItemSize = CGSize(width: 60, height: 138)
//        let cellSize = CGSize(width:60 , height:138)
//        layout.itemSize = cellSize
        
        
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16) // CollectionView 의 전체 마진
        layout.minimumLineSpacing = 16 // 셀 아이템간의 라인 마진
        layout.minimumInteritemSpacing = 16 // 셀 아이템간의 측면 마진
        
        //self.collectionView.collectionViewLayout = layout
        self.collectionView.showsHorizontalScrollIndicator = false
        
        
        //layout.invalidateLayout()
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
