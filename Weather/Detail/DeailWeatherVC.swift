//
//  DeailWeatherVC.swift
//  Weather
//
//  Created by moonkyoochoi on 2021/04/21.
//

import CoreLocation
import UIKit

import Alamofire
import SwiftyJSON

class DetailWeatherVC: UIViewController {
    
    var location: CLLocation
    var locationName: String
    
    //var detailData: DetailData?
    var detailData: JSON?
    
    init(locationName: String, location: CLLocation) {
        self.locationName = locationName
        self.location = location
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var tableView: UITableView = {
        
        let tbv = UITableView()
        
        view.addSubview(tbv)
        tbv.translatesAutoresizingMaskIntoConstraints = false
        tbv.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tbv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tbv.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tbv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        //tbv.backgroundColor = .red
        
        tbv.register(UINib(nibName: "DetailWeatherHeaderCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "DetailWeatherHeaderCell")
//        tbv.register(UINib(nibName: DetailWeatherBodyCell.reusableIdentifier, bundle: nil), forCellReuseIdentifier: DetailWeatherBodyCell.reusableIdentifier) // ui base
        tbv.register(DetailWeatherBodyCell2.self, forCellReuseIdentifier: DetailWeatherBodyCell2.reusableIdentifier) // code base
        //tbv.register(UINib(nibName: "DetailWeatherFooterCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "DetailWeatherFooterCell")
        tbv.register(DetailWeatherFooterCell.self, forCellReuseIdentifier: DetailWeatherFooterCell.reusableIdentifier)
        
        tbv.separatorStyle = .none
        
        return tbv
        
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let param: [String: Any] = ["lat": location.coordinate.latitude,
                                    "lon": location.coordinate.longitude,
                                    "appid": "0367480f207592a2a18d028adaac65d2",
                                    "lang": _COUNTRY,
                                    "units": fahrenheitOrCelsius.pameter] //imperial - Fahrenheit
        API(session: Session.default)
            .request("https://api.openweathermap.org/data/2.5/onecall", method: .get, parameters: param, encoding: URLEncoding.default, headers: nil, interceptor: nil, requestModifier: nil) { json in
                
                //print(JSON(json))
                
//                do {
//                    self.detailData = try JSONDecoder().decode(DetailData.self, from: json.rawData())
//
//                    self.tableView.dataSource = self
//                    self.tableView.delegate = self
//                } catch let error {
//                    print(error.localizedDescription)
//                }
                
                self.detailData = json
                self.tableView.dataSource = self
                self.tableView.delegate = self
            }
    }
}

extension DetailWeatherVC: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailData == nil ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailWeatherBodyCell.reusableIdentifier) as? DetailWeatherBodyCell,
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailWeatherBodyCell2.reusableIdentifier) as? DetailWeatherBodyCell2,
              let hourlyArray = detailData?["hourly"].array
        else { fatalError() }
        
        cell.setHourly(hourly: hourlyArray)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // DetailWeatherCollectionViewCell 의 ContentView's heght 가 130 이며 CollectionView의 UIEdgeInsets가 top + bottom 이 32 이므로 최소 크기로 130 + 32를 선언해줘야한다. 만약 이보다 작은 경우 'The behavior of the UICollectionViewFlowLayout is not defined' Warning이 발생한다.
        return 130 + 32
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let header = UINib(nibName: "DetailWeatherHeaderCell", bundle: nil)
                .instantiate(withOwner: self, options: [:])[0] as? DetailWeatherHeaderCell
        else { return nil }
        /*
         
         @IBOutlet weak var city: UILabel!
         @IBOutlet weak var weatherDescription: UILabel!
         @IBOutlet weak var temp: UILabel!
         @IBOutlet weak var max: UILabel!
         @IBOutlet weak var min: UILabel!
         */
        header.city.text = self.locationName
        header.weatherDescription.text = detailData?["current"]["weather"].stringValue
        header.temp.text = detailData?["current"]["temp"].stringValue
        
        header.max.text = "_\(fahrenheitOrCelsius.emoji)"
        header.min.text = "_\(fahrenheitOrCelsius.emoji)"
        
        guard let temp = detailData?["daily"].array?[0]["temp"]
        else { return header }
        
        header.max.text = "\(temp["max"].intValue)"
        header.min.text = "\(temp["min"].intValue)"
        
        return header
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//
//        guard let header = UINib(nibName: "DetailWeatherFooterCell", bundle: nil)
//                .instantiate(withOwner: self, options: [:]).first as? DetailWeatherFooterCell
//        else { return nil }
        let footer = DetailWeatherFooterCell(style: .default, reuseIdentifier: DetailWeatherFooterCell.reusableIdentifier)
        
        guard let dailyArray = detailData?["daily"].array
        else { return nil }
        
        footer.setDaily(daily: dailyArray)
        return footer
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 200
    }
    
}

extension DetailWeatherVC: UITableViewDelegate {
    
}
