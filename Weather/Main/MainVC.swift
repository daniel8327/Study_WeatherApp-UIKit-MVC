//
//  ViewController.swift
//  Weather
//
//  Created by 장태현 on 2021/04/17.
//

import CoreData
import CoreLocation
import UIKit

import Alamofire
import SwiftyJSON


enum FahrenheitOrCelsius: String {
    case Fahrenheit
    case Celsius
}

extension FahrenheitOrCelsius {
    var stringValue: String {
        return "\(self)"
    }
    
    var emoji: String {
        switch self {
        case .Celsius:
            return "℃"
        case .Fahrenheit:
            return "℉"
        }
    }
    
    var pameter: String {
        switch self {
        case .Celsius:
            return "metric"
        default:
            return "imperial"
        }
    }
}

class MainVC: UIViewController {
    
    lazy var locationManager: CLLocationManager = {
    
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()// 포그라운드에서 권한 요청
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
                
        return locationManager
    }()
    
    private(set) var items: [LocationVO]? {
        didSet {
            print("didSet 호출")
            //tableView.reloadData()
            
            UIView.transition(with: self.tableView, duration: 1.0, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
        }
    }
    
    var currentLocation: CLLocation?
    
    lazy var tableView: UITableView = {
        
        let tbv = UITableView()
        
        view.addSubview(tbv)
        tbv.translatesAutoresizingMaskIntoConstraints = false
        tbv.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tbv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tbv.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tbv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        //tbv.backgroundColor = .red
        
        tbv.register(UINib(nibName: "WeatherCell", bundle: nil), forCellReuseIdentifier: "WeatherCell")
        tbv.separatorStyle = .none
                
        tbv.delegate = self
        tbv.dataSource = self
        
        // xib 호출 방법1
        if let loadedNib = Bundle.main.loadNibNamed("LocationFooter", owner: self, options: nil) {
            if let view = loadedNib[1] as? UIView {
                tbv.tableFooterView = view
                
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(addLocation),
                                                       name: Notification.Name("ADD_LOCATION"),
                                                       object: nil)
                
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(changeNotation),
                                                       name: Notification.Name("CHANGE_NOTATION"),
                                                       object: nil)
            }
        }
        
        // xib 호출 방법2
        //if let aa = UINib(nibName: "LocationFooter", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView //xib의 1번째
        /*if let aa = UINib(nibName: "LocationFooter", bundle: nil).instantiate(withOwner: self, options: nil)[1] as? UIView { // xib의 두번째
            tbv.tableFooterView = aa
            
        }*/
        
        return tbv
    }()
    
    var count: Int = 0
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
    private var dateFormatter: DateFormatter = {
       
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .iso8601)
        df.timeZone = TimeZone.current
        //df.locale = Locale.current
        df.locale = Locale(identifier: UICommon.getLanguageCountryCode())

        //df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "hh:mm a"
        return df
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        Indicator.INSTANCE.startAnimating()
        
        view.backgroundColor = .systemBackground
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            Indicator.INSTANCE.stopAnimating()

            guard let self = self else {
                return
            }
        }
        
        // 아이폰 설정에서의 위치 서비스가 켜진 상태라면
        if CLLocationManager.locationServicesEnabled() {
            print("위치 서비스 On 상태")
            locationManager.startUpdatingLocation() //위치 정보 받아오기 시작 CLLocationManagerDelegate
            //print(locationManager.location?.coordinate)
        } else {
            print("위치 서비스 Off 상태")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        _ = fetch()
        checkLocations()
    }
    
    
    func checkLocations() {
        
        // 설정된 도시 없으면 물어보기
        if let vo = self.items, vo.isEmpty, !_UDS.bool(forKey: "ADD_LOCATION") {
            let alert = UIAlertController(title: "지역 선택", message: "날씨 정보를 받아볼 지역을 검색하세요.", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
                self.addLocation()
                _UDS.setValue(true, forKey: "ADD_LOCATION") // 한번만 물어보기
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
                _UDS.setValue(true, forKey: "ADD_LOCATION") // 한번만 물어보기
            }
            alert.addAction(confirmAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true)
        }
        
    }
    
    @objc func changeNotation() {
        
        fahrenheitOrCelsius = (fahrenheitOrCelsius == FahrenheitOrCelsius.Celsius) ? .Fahrenheit : .Celsius
        
        // footer 바꾸기
        let footer = self.tableView.tableFooterView as! LocationFooter
        
        let attributeString = NSMutableAttributedString(string: footer.notation.text ?? "")
        
        let str = footer.notation.text!
        
        let r1 = str.range(of: fahrenheitOrCelsius.emoji)!
        // String range to NSRange:
        let n1 = NSRange(r1, in: str)
        
        attributeString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: n1)

        footer.notation.attributedText = attributeString
        
        // 전체 리스트 바꾸기
        //tableView.reloadData()
        
        UIView.transition(with: self.tableView, duration: 1.0, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
        
        // 헤더
        //setHeaderView()
        
    }
    
    @objc func addLocation() {
        
        // 도시 검색
        let vc = AddLocationVC()
        
        vc.saveDelegate = self // SaveLocationDelegate
        
        vc.saveLocationAlias = { locationElements in //[weak self] locationElements in
            self.save(cityName: locationElements[0], cityCode: locationElements[1], longitude: locationElements[2], latitude: locationElements[3])
        }
        self.present(vc, animated: true)
    }
    
    func fetchByKey(code: String) -> NSManagedObject? {
        
        let context = _AD.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Location")
        
        fetchRequest.predicate = NSPredicate(format: "code == %@", code)
        
        print("fetchRequest.predicate: \(fetchRequest.predicate!)")
        
        let aa = try? context.fetch(fetchRequest)
        
        print("aa: \(aa)")
        print("aa.first: \(aa?.first)")
        
        return try? context.fetch(fetchRequest).first ?? nil
    }
    
    /// CoreData Fetch
    /// - Returns: [Location]
    func fetch() -> [NSManagedObject] {
        let context = _AD.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Location")
        
        // 정렬 속성
        do {
            let sort = NSSortDescriptor(key: "regdate", ascending: false)
            fetchRequest.sortDescriptors = [sort]
            
            let result = try context.fetch(fetchRequest)
            items = result.map {
                LocationVO(city: $0.value(forKey: "city") as! String,
                           code: $0.value(forKey: "code") as! String,
                           longitude: $0.value(forKey: "longitude") as! String,
                           latitude: $0.value(forKey: "latitude") as! String,
                           recent_temp: $0.value(forKey: "recent_temp") as? Int
                )
            }
            
            return result
        } catch let error {
            print(error.localizedDescription)
            return []
        }
    }
    
    @discardableResult
    func save(cityName: String, cityCode: String, longitude: String, latitude: String) -> Bool {
        
        defer {
            self.items?.append(
                LocationVO(
                    city: cityName,
                    code: cityCode,
                    longitude: longitude,
                    latitude: latitude,
                    recent_temp: 0
                )
            )
        }
                
        let context = _AD.persistentContainer.viewContext
        
        let object = NSEntityDescription.insertNewObject(forEntityName: "Location", into: context)
        
        object.setValue(cityName, forKey: "city")
        object.setValue(cityCode, forKey: "code")
        object.setValue(longitude, forKey: "longitude")
        object.setValue(latitude, forKey: "latitude")
        object.setValue(Date(), forKey: "regdate")
        
        do {
            try context.save()
            //locations.insert(object, at: 0)
            //list.append(object)
            return true
        } catch {
            context.rollback()
            return false
        }
    }
    
    func deleteByCode(code: String) -> Bool {
    
        if let result = fetchByKey(code: code) {
            return delete(object: result)
        } else {
            return false
        }
    }
    
    func delete(object: NSManagedObject) -> Bool {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        context.delete(object)
        
        do {
            try context.save()
            return true
        } catch {
            context.rollback()
            return false
        }
    }
    
    @discardableResult
    func editByCode(cityCode: String, temperature: Int?) -> Bool {
        
        print("cityCode: \(cityCode)")
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        if let object = fetchByKey(code: cityCode) {
            
            object.setValue(cityCode, forKey: "code")
            
            if let temperature = temperature {
                object.setValue(temperature, forKey: "recent_temp")
            }
            
            object.setValue(Date(), forKey: "regdate")
            
            do {
                try context.save()
                return true
            } catch {
                context.rollback()
                return false
            }
        }
        
        return false
    }
    
    @discardableResult
    func edit(object: NSManagedObject, city: String?, cityCode: String?, temperature: Int?) -> Bool {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        if let city = city {
            object.setValue(city, forKey: "city")
        }
        if let cityCode = cityCode {
            object.setValue(cityCode, forKey: "code")
        }
        if let temperature = temperature {
            object.setValue(temperature, forKey: "recent_temp")
        }
        
        object.setValue(Date(), forKey: "regdate")
        
        do {
            try context.save()
            return true
        } catch {
            context.rollback()
            return false
        }
    }
//
//    func convertToAddressWith(coordinate: CLLocation) {
//        let geoCoder = CLGeocoder()
//        geoCoder.reverseGeocodeLocation(coordinate) { (placemarks, error) -> Void in
//            if error != nil {
//                NSLog("\(error)")
//                return
//            }
//
//            guard let placemark = placemarks?.first else { return }
//
//            print("placemark: \(placemark)")
//
//            self.currentLocation = placemark
//
//            let headerView = UINib(nibName: "WeatherCell", bundle: nil).instantiate(withOwner: self, options: [:]).first as! WeatherCell
//            self.tableView.tableHeaderView = headerView
//
//            self.setHeaderView()
//
//        }
//    }
    
    @available(*, deprecated)
    func setHeaderView() {
        
        guard let headerView: WeatherCell = tableView.tableHeaderView as? WeatherCell,
              let location = self.currentLocation
        else { return }
            
        headerView.locationName.text = "--"
        headerView.temperature.text = "--\(fahrenheitOrCelsius.emoji)"
        
        let param: [String: Any] = ["lat": location.coordinate.latitude,
                                    "lon": location.coordinate.longitude,
                                    "appid": "0367480f207592a2a18d028adaac65d2",
                                    "lang": _COUNTRY,
                                    "units": fahrenheitOrCelsius.pameter] //imperial - Fahrenheit
        API(session: Session.default)
            .request("https://api.openweathermap.org/data/2.5/weather", method: .get, parameters: param, encoding: URLEncoding.default, headers: nil, interceptor: nil, requestModifier: nil) { json in
                
                print(JSON(json))
                
                headerView.locationName.text = "현재위치 - \(json["name"].stringValue)"
                headerView.temperature.text = "\(json["main"]["temp"].intValue)\(fahrenheitOrCelsius.emoji)"
                headerView.time.text = Date().getCountryTime(byTimeZone: json["timezone"].intValue)
            }
    }
}

extension MainVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        cell.layer.transform = CATransform3DMakeScale(0.8, 0.8, 0.8)
        UIView.animate(withDuration: 0.5, delay: 0.2 * Double(indexPath.row)) {
            cell.alpha = 1
            cell.layer.transform = CATransform3DScale(CATransform3DIdentity, 1, 1, 1)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell") as? WeatherCell,
              let data = items
        else { fatalError() }
        
        cell.separatorInset = UIEdgeInsets.zero // https://zeddios.tistory.com/235
                
        let record = data[indexPath.row]
        
        cell.locationName.text = record.city
        
        if let temp = record.recent_temp {
            cell.temperature.text = "\(temp)\(fahrenheitOrCelsius.emoji)"
        } else {
            cell.temperature.text = "--\(fahrenheitOrCelsius.emoji)"
        }
        
        let param: [String: Any] = ["lat": record.latitude,
                                    "lon": record.longitude,
                                    "appid": "0367480f207592a2a18d028adaac65d2",
                                    "lang": _COUNTRY,
                                    "units": fahrenheitOrCelsius.pameter]
        API.init(session: Session.default)
            .request("https://api.openweathermap.org/data/2.5/weather", method: .get, parameters: param, encoding: URLEncoding.default, headers: nil, interceptor: nil, requestModifier: nil) { json in
                
                //print(JSON(json))
                
                let temp = json["main"]["temp"].intValue
                cell.temperature.text = "\(temp)\(fahrenheitOrCelsius.emoji)"
                
                print("DT: \(json["name"].stringValue) - \(json["dt"].int64Value)")
                let timeInterval = TimeInterval(json["dt"].int64Value)
                let date = Date(timeIntervalSince1970: timeInterval)
                
                cell.time.text = self.dateFormatter.string(from: date)
                
                let df = DateFormatter()
                df.calendar = Calendar(identifier: .iso8601)
                df.timeZone = TimeZone(secondsFromGMT: json["timezone"].intValue)
                //df.locale = Locale.current
                df.locale = Locale(identifier: UICommon.getLanguageCountryCode())

                //df.locale = Locale(identifier: "ko_KR")
                df.dateFormat = "hh:mm a"
                
                print("timezone: \(json["timezone"].intValue) => dt: \(df.string(from: date))")
                cell.time.text = df.string(from: date)
                
                
                //cell.time.text = Date().getCountryTime(byTimeZone: json["timezone"].intValue)
                
                print("id: \(json["id"].stringValue)")
                print("id: \(json["id"].intValue)")
                self.editByCode(cityCode: json["id"].stringValue, temperature: temp)
                
                
                
//                print(Date())
//                print(Date().addingTimeInterval(32400))
//
//
//                print(Date(timeIntervalSince1970: TimeInterval(1618983823)).addingTimeInterval(32400)) // current
//                print(Date(timeIntervalSince1970: TimeInterval(1618951711)).addingTimeInterval(32400)) // sunrise
//                print(Date(timeIntervalSince1970: TimeInterval(1618999872)).addingTimeInterval(32400)) // sunset
//                print(Date(timeIntervalSince1970: TimeInterval(1618983840)).addingTimeInterval(32400)) // minutely
//                print(Date(timeIntervalSince1970: TimeInterval(1618981200)).addingTimeInterval(32400)) // hourly
//                print(Date(timeIntervalSince1970: TimeInterval(1618984800)).addingTimeInterval(32400)) // hourly2
//                print(Date(timeIntervalSince1970: TimeInterval(1618974000)).addingTimeInterval(32400)) // daily
//                print(Date(timeIntervalSince1970: TimeInterval(1619060400)).addingTimeInterval(32400)) // daily2
//                print(Date(timeIntervalSince1970: TimeInterval(1619578800)).addingTimeInterval(32400)) // daily-final
//                print(Date(timeIntervalSince1970: TimeInterval(1619089200)).addingTimeInterval(32400)) // rome
                
            }
        //cell.backgroundColor = .random
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

extension MainVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let object = items?[indexPath.row] else { return }
        
        
        let location = CLLocation(
            latitude: CLLocationDegrees(Double(object.latitude)!),
            longitude: CLLocationDegrees(Double(object.longitude)!)
        )
        
        let vc = DetailWeatherVC(locationName: object.city, location: location)
        
        UICommon.setTransitionAnimation(navi: self.navigationController)
        self.present(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if let object = items?[indexPath.row] {
        
            if self.deleteByCode(code: object.code) {
                //tableView.deleteRows(at: [indexPath], with: .fade)
                items?.remove(at: indexPath.row)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        let object = items?[indexPath.row]
//
//        let uvc = self.storyboard?.instantiateViewController(identifier: "LogVC") as! LogVC
//        uvc.board = (object as! BoardMO)
//
//        self.show(uvc, sender: self)
    }
}

extension MainVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            guard let currentLocation = locationManager.location else { return }
            
//            self.currentLocation = currentLocation
//
//            let headerView = UINib(nibName: "WeatherCell", bundle: nil).instantiate(withOwner: self, options: [:]).first as! WeatherCell
//            headerView.frame.size.height = 100
//            //headerView.backgroundColor = .random
//            self.tableView.tableHeaderView = headerView
//
//            self.setHeaderView()
            
            let param: [String: Any] = ["lat": currentLocation.coordinate.latitude,
                                        "lon": currentLocation.coordinate.longitude,
                                        "appid": "0367480f207592a2a18d028adaac65d2",
                                        "lang": _COUNTRY,
                                        "units": fahrenheitOrCelsius.pameter] //imperial - Fahrenheit
          /*
             API(session: Session.default)
                 .request("https://api.openweathermap.org/data/2.5/weather", method: .get, parameters: param, encoding: URLEncoding.default, headers: nil, interceptor: nil, requestModifier: nil) { json in
                     
                     locationVO?.insert(
                         LocationVO(
                             city: json["name"].stringValue,
                             code: json["id"].stringValue,
                             longitude: currentLocation.coordinate.longitude,
                             latitude: currentLocation.coordinate.latitude,
                             recent_temp: json["main"]["temp"].intValue
                         ),
                         at: 0
                     )
                 }
             */
            API(session: Session.default)
                .request("https://api.openweathermap.org/data/2.5/weather",
                         method: .get,
                         parameters: param,
                         encoding: URLEncoding.default,
                         headers: nil,
                         interceptor: nil,
                         requestModifier: nil) { json in
                    
                    self.items?.insert(
                        LocationVO(city: json["name"].stringValue,
                                   code: json["id"].stringValue,
                                   longitude: String(currentLocation.coordinate.longitude),
                                   latitude: String(currentLocation.coordinate.latitude),
                                   recent_temp: json["main"]["temp"].intValue
                        ),
                        at: 0
                    )
                }
        }
    }
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let loc = manager.location {
//            count += 1
//
//            convertToAddressWith(coordinate: loc)
//            print("\(count): \(loc.coordinate.longitude)")
//            print("\(count): \(loc.coordinate.latitude)")
//        }
//    }
}

extension MainVC: SaveLocationDelegate {
    func requestSave(locationElements: ([String])) {
        self.save(cityName: locationElements[0], cityCode: locationElements[1], longitude: locationElements[2], latitude: locationElements[3])
    }
}
