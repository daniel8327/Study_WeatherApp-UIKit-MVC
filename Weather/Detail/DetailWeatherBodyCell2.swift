//
//  DetailWeatherBodyCell2.swift
//  Weather
//
//  Created by moonkyoochoi on 2021/04/22.
//

import UIKit

import SwiftyJSON

class DetailWeatherBodyCell2: UITableViewCell {
    
    private(set) var collectionView: UICollectionView
    
    var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: 100, height: 100)
        return layout
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var hourly: [JSON]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func config(hourly: [JSON]) {
        
        self.hourly = hourly
        
        //collectionView.register(DetailWeatherCollectionViewCell.self, forCellWithReuseIdentifier: "DetailWeatherCollectionViewCell") // code base
        collectionView.register(UINib(nibName: "DetailWeatherCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DetailWeatherCollectionViewCell") // ui base
        
        // Add `coolectionView` to display hierarchy and setup its appearance
        self.addSubview(collectionView)
        //collectionView.backgroundColor = .white
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        // Setup Autolayout constraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        collectionView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        collectionView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        
        collectionView.dataSource = self
    
        
        (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).sectionInsetReference = .fromLayoutMargins
    }
}

extension DetailWeatherBodyCell2: UICollectionViewDataSource {
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
    
        if let icon = data["weather"][0]["icon"].string {
            //print("icon: \(icon)")
            cell.icon.kf.setImage(with: URL(string: "http://openweathermap.org/img/wn/\(icon)@2x.png"))
        }
        
        cell.backgroundColor = .random
        
        return cell
    }
}
