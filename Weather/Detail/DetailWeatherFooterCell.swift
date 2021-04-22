//
//  DetailWeatherFooterTableViewCell.swift
//  Weather
//
//  Created by moonkyoochoi on 2021/04/22.
//

import UIKit

import SwiftyJSON

class DetailWeatherFooterCell: UITableViewCell {
    
    var tableView: UITableView
    
    var daily: [JSON]?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        tableView = UITableView()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        
        self.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        //tableView.backgroundColor = .red
        
        tableView.register(UINib(nibName: DetailWeatherFooterTableViewCell.reusableIdentifier, bundle: nil), forCellReuseIdentifier: DetailWeatherFooterTableViewCell.reusableIdentifier)
        
        tableView.separatorStyle = .none
    }
    
    override func awakeFromNib() { // UINib( 으로 호출시에만 탄다.
        super.awakeFromNib()
        setUI()
        
    }
    
    func setDaily(daily: [JSON]){
        self.daily = daily
        
        tableView.dataSource = self
    }
}

extension DetailWeatherFooterCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daily?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailWeatherFooterTableViewCell.reusableIdentifier) as? DetailWeatherFooterTableViewCell else {
            fatalError()
        }
        
        /*
         
 //
 //        header.dt.text = "aa"
 //        header.weatherId.text = "bb"
 //        header.rainExpectation.text = "80%"
 //        header.max.text = "20"
 //        header.min.text = "1"
 //
 //        header.max.text = "_\(fahrenheitOrCelsius.emoji)"
 //        header.min.text = "_\(fahrenheitOrCelsius.emoji)"
 //
 //        guard let temp = detailData?["daily"].array?[0]["temp"]
 //        else { return header }
 //
 //        header.max.text = "\(temp["max"].intValue)"
 //        header.min.text = "\(temp["min"].intValue)"
         
         */
        if let data = daily {
            
            let item = data[indexPath.row]
            
            cell.dt.text = item["dt"].stringValue
            cell.weatherId.text = item["weather"][0]["icon"].stringValue
            cell.rainExpectation.text = "90"
            cell.max.text = item["temp"]["max"].stringValue
            cell.min.text = item["temp"]["min"].stringValue
        }
        
        
        return cell
    }
    
    
    
}

extension DetailWeatherFooterCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
