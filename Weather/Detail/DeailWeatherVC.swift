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
    var detailData: DetailData?
    
    var items: [JSONVO]?
    
    private var dateFormatter: DateFormatter = {
       
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .iso8601)
        df.timeZone = TimeZone.current
        //df.locale = Locale.current
        df.locale = Locale(identifier: UICommon.getLanguageCountryCode())

        //df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "EEEE"
        return df
    }()
    
    
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
        //tbv.backgroundColor = .random
        
        //tbv.register(UINib(nibName: "DetailWeatherHeaderCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "DetailWeatherHeaderCell")
        tbv.register(UINib(nibName: DetailWeatherHeaderCell.reusableIdentifier, bundle: nil), forHeaderFooterViewReuseIdentifier: DetailWeatherHeaderCell.reusableIdentifier)
        
        
//        tbv.register(UINib(nibName: DetailWeatherBodyHourlyCell.reusableIdentifier, bundle: nil), forCellReuseIdentifier: DetailWeatherBodyHourlyCell.reusableIdentifier) // ui base
        tbv.register(DetailWeatherBodyHourlyCell2.self, forCellReuseIdentifier: DetailWeatherBodyHourlyCell2.reusableIdentifier) // code base
        
        
        tbv.register(UINib(nibName: DetailWeatherBodyDailyCell.reusableIdentifier, bundle: nil), forCellReuseIdentifier: DetailWeatherBodyDailyCell.reusableIdentifier) // code base
        
        //tbv.separatorStyle = .none
        tbv.allowsSelection = false
        tbv.showsVerticalScrollIndicator = false
        
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
                
                do {
                    self.detailData = try JSONDecoder().decode(DetailData.self, from: json.rawData())
                    
                    if let data = self.detailData {
                        
                        self.items = [JSONVO]()
                        self.items?.append(HourlyVO(items: data.hourly))
                        self.items?.append(DailyVO(items: data.daily))
                        
                        self.setHeader()
                    }
                } catch let error {
                    print(error)
                    print(error.localizedDescription)
                    fatalError()
                }
                
                self.tableView.dataSource = self
                self.tableView.delegate = self
            }
    }
    
    func setHeader() {
        
        guard let header = UINib(nibName: DetailWeatherHeaderCell.reusableIdentifier, bundle: nil)
                .instantiate(withOwner: self, options: [:])[0] as? DetailWeatherHeaderCell,
              let data = self.detailData
        else { fatalError() }
        
        header.city.text = self.locationName
        header.weatherDescription.text = data.current.weather[0].weatherDescription
        header.temp.text = "\(Int(data.current.temp))"
        
        header.max.text = "_\(fahrenheitOrCelsius.emoji)"
        header.min.text = "_\(fahrenheitOrCelsius.emoji)"
        
        header.max.text = "\(Int(data.daily[0].temp.max))"
        header.min.text = "\(Int(data.daily[0].temp.min))"
        
        tableView.tableHeaderView = header
    }
}

extension DetailWeatherVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        if let hourly = items?[section] as? HourlyVO {
            print("hourly count: \(hourly.items.count)")
            return 1
        } else if let daily = items?[section] as? DailyVO {
            print("daily count: \(daily.items.count)")
            return daily.items.count
        } else {
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        cell.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5)
        UIView.animate(withDuration: 0.5, delay: 0.2 * Double(indexPath.row)) {
            cell.alpha = 1
            cell.layer.transform = CATransform3DScale(CATransform3DIdentity, 1, 1, 1)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
    //        guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailWeatherBodyHourlyCell.reusableIdentifier) as? DetailWeatherBodyHourlyCell,
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailWeatherBodyHourlyCell2.reusableIdentifier) as? DetailWeatherBodyHourlyCell2,
                  let hourly = items?[indexPath.section] as? HourlyVO
            else { fatalError() }
        
            cell.setHourly(hourly: hourly)
            cell.separatorInset = UIEdgeInsets.zero // https://zeddios.tistory.com/235
            return cell
        }
        
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailWeatherBodyDailyCell.reusableIdentifier) as? DetailWeatherBodyDailyCell,
                  let daily = items?[indexPath.section] as? DailyVO
            else { fatalError() }
            
            let data = daily.items[indexPath.row]
            
            
            let timeInterval = TimeInterval(data.dt)
            let date = Date(timeIntervalSince1970: timeInterval)
            
            cell.dt.text = dateFormatter.string(from: date)
            
            cell.icon.image = UIImage(named: "dash.png")
            
            let iconURL = "http://openweathermap.org/img/wn/\(data.weather[0].icon)@2x.png"
            
            //print("icon: \(iconURL)")
            cell.icon.kf.setImage(with: URL(string: iconURL))
            //cell.weatherId.text = "\(data.weather[0].id)"
            cell.rainExpectation.text = data.humidity > 30 ? "\(data.humidity)" : ""
            cell.max.text = "\(Int(data.temp.max))"
            cell.min.text = "\(Int(data.temp.min))"
            
            cell.separatorInset = UIEdgeInsets.zero // https://zeddios.tistory.com/235
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // DetailWeatherBodyHourlyCollectionViewCell 의 ContentView's heght 가 130 이며 CollectionView의 UIEdgeInsets가 top + bottom 이 32 이므로 최소 크기로 130 + 32를 선언해줘야한다. 만약 이보다 작은 경우 'The behavior of the UICollectionViewFlowLayout is not defined' Warning이 발생한다.
        //return 130 + 32
        if indexPath.section == 0 {
            return 130 + 32
        }
        return UITableView.automaticDimension
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: DetailWeatherHeaderCell.reusableIdentifier) as? DetailWeatherHeaderCell
//        else { return nil }
//
////        guard let header = UINib(nibName: "DetailWeatherHeaderCell", bundle: nil)
////                .instantiate(withOwner: self, options: [:])[0] as? DetailWeatherHeaderCell
////        else { return nil }
//        /*
//
//         @IBOutlet weak var city: UILabel!
//         @IBOutlet weak var weatherDescription: UILabel!
//         @IBOutlet weak var temp: UILabel!
//         @IBOutlet weak var max: UILabel!
//         @IBOutlet weak var min: UILabel!
//         */
//        header.city.text = self.locationName
//        header.weatherDescription.text = detailData?["current"]["weather"].stringValue
//        header.temp.text = detailData?["current"]["temp"].stringValue
//
//        header.max.text = "_\(fahrenheitOrCelsius.emoji)"
//        header.min.text = "_\(fahrenheitOrCelsius.emoji)"
//
//        guard let temp = detailData?["daily"].array?[0]["temp"]
//        else { return header }
//
//        header.max.text = "\(temp["max"].intValue)"
//        header.min.text = "\(temp["min"].intValue)"
//
//        return header
//    }
    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let footer = DetailWeatherFooterCell(style: .default, reuseIdentifier: DetailWeatherFooterCell.reusableIdentifier)
//
//        guard let dailyArray = detailData?["daily"].array
//        else { return nil }
//
//        footer.setDaily(daily: dailyArray)
//        return footer
//    }
    
    
    
    
}

extension DetailWeatherVC: UITableViewDelegate {
    
}
