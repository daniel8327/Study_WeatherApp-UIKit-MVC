//
//  DetailWeatherBodyHourlyCell.swift
//  Weather
//
//  Created by moonkyoochoi on 2021/04/22.
//

import UIKit

import Kingfisher
import SwiftyJSON


class DetailWeatherBodyHourlyCell: UITableViewCell {
    
    private var dateFormatter: DateFormatter = {
       
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .iso8601)
        df.timeZone = TimeZone.current
        df.locale = Locale.current
        df.locale = Locale(identifier: UICommon.getLanguageCountryCode())
        df.dateFormat = "a H"
        return df
    }()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionLayout: UICollectionViewFlowLayout! {
        didSet {
            collectionLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            //collectionLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
    }
    
    private var hourly: HourlyVO?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //collectionView.register(DetailWeatherBodyHourlyCollectionViewCell.self, forCellWithReuseIdentifier: "DetailWeatherBodyHourlyCollectionViewCell") // code base
        collectionView.register(UINib(nibName: DetailWeatherBodyHourlyCollectionViewCell.reusableIdentifier, bundle: nil), forCellWithReuseIdentifier: DetailWeatherBodyHourlyCollectionViewCell.reusableIdentifier) // ui base
        
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
    
    func setHourly(hourly: HourlyVO) {
        
        self.hourly = hourly
        collectionView.dataSource = self
        
    }
}

extension DetailWeatherBodyHourlyCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return hourly?.items.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailWeatherBodyHourlyCollectionViewCell.reusableIdentifier, for: indexPath) as? DetailWeatherBodyHourlyCollectionViewCell,
              let hourly = hourly
        else { fatalError() }
        
        let data = hourly.items[indexPath.row]
        
        let timeInterval = TimeInterval(data.dt)
        let date = Date(timeIntervalSince1970: timeInterval)
        
        cell.dt.text = dateFormatter.string(from: date)
        cell.temp.text = "\(Int(data.temp))"
        
        cell.icon.image = UIImage(named: "dash.png")
        
        let iconURL = "http://openweathermap.org/img/wn/\(data.weather[0].icon)@2x.png"
        
        //print("icon: \(iconURL)")
        cell.icon.kf.setImage(with: URL(string: iconURL))
        //cell.icon.kf.setImage(with: URL(string: iconURL))
        
        //cell.backgroundColor = .random
        
        return cell
    }
}
