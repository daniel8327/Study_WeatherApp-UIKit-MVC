//
//  DetailWeatherBodyHourlyCell2.swift
//  Weather
//
//  Created by moonkyoochoi on 2021/04/22.
//

import UIKit

import SwiftyJSON

class DetailWeatherBodyHourlyCell2: UITableViewCell {
    
    private var dateFormatter: DateFormatter = {
       
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .iso8601)
        df.timeZone = TimeZone.current
        df.locale = Locale(identifier: UICommon.getLanguageCountryCode())
        print(Locale.current)
        df.dateFormat = "a H"
        return df
    }()
    
    private lazy var collectionView: UICollectionView = {
       
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.isUserInteractionEnabled = true
        
        //collectionView.register(DetailWeatherBodyHourlyCollectionViewCell.self, forCellWithReuseIdentifier: DetailWeatherBodyHourlyCollectionViewCell.reusableIdentifier) // code base
        collectionView.register(UINib(nibName: DetailWeatherBodyHourlyCollectionViewCell.reusableIdentifier, bundle: nil), forCellWithReuseIdentifier: DetailWeatherBodyHourlyCollectionViewCell.reusableIdentifier) // ui base
        
        // Add `coolectionView` to display hierarchy and setup its appearance
        self.contentView.addSubview(collectionView) // self.addSubview(collectionView) 햐게되면 컬렉션의 스크롤이 안먹음✭✭✭✭✭✭✭✭✭✭✭✭✭✭✭✭
        
        collectionView.contentInsetAdjustmentBehavior = .always
        
        // Setup Autolayout constraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        collectionView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        collectionView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .systemBackground
        
        return collectionView
    }()
    
    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        //layout.estimatedItemSize = CGSize(width: 100, height: 100)
        
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16) // CollectionView 의 전체 마진
        layout.minimumLineSpacing = 16 // 셀 아이템간의 라인 마진
        layout.minimumInteritemSpacing = 16 // 셀 아이템간의 측면 마진
        
        return layout
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var hourly: HourlyVO?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setHourly(hourly: HourlyVO) {
        
        self.hourly = hourly
        collectionView.dataSource = self
    }
}

extension DetailWeatherBodyHourlyCell2: UICollectionViewDataSource {
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
