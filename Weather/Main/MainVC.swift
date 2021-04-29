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
    
    private(set) var items: [LocationVO] = {
        []
    }()
    {
        willSet {
            print("willset")
            if nil == items {
                items = []
                print("willset initialized..........")
            }
        }
        didSet {
            print("didSet 호출")
            //tableView.reloadData()
            
            //UIView.transition(with: self.tableView, duration: 1.0, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
        }
    }
//    private(set) var items: [LocationVO]? {
//        willSet {
//            print("willset")
//            if nil == items {
//                items = []
//                print("willset initialized..........")
//            }
//        }
//        didSet {
//            print("didSet 호출")
//            //tableView.reloadData()
//
//            //UIView.transition(with: self.tableView, duration: 1.0, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
//        }
//    }
    
    /*
    private(set) var items: [LocationVO] = {
        return [LocationVO]()
        
    }() {
        didSet {
//            
//                didSet {
//                    print("didSet 호출")
//                    //tableView.reloadData()
//                    
//                    //UIView.transition(with: self.tableView, duration: 1.0, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
//                }
        }
    }
 */
    
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
        if self.items.isEmpty, !_UDS.bool(forKey: "ADD_LOCATION") {
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
        
        vc.saveLocationAlias = { location in //[weak self] locationElements in
            self.save(object: nil, location: location)
            
            self.tableView.performBatchUpdates({
                self.items.append(location)
                self.tableView.insertRows(at: [IndexPath(row: self.items.count - 1, section: 0)], with: .bottom)
            }, completion: nil)
        }
        self.present(vc, animated: true)
    }
    
    func fetchByCurrent() -> NSManagedObject? {
        
        let context = _AD.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Location")
        
        fetchRequest.predicate = NSPredicate(format: "currentArea == %i", 1)
        
        print("fetchRequest.predicate: \(fetchRequest.predicate!)")
        
        let currentArea = try? context.fetch(fetchRequest)
        
        print("currentArea: \(currentArea)")
        print("currentArea.first: \(currentArea?.first)")
        
        return try? context.fetch(fetchRequest).first ?? nil
    }
    
    
    func fetchByKey(code: String) -> NSManagedObject? {
        
        let context = _AD.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Location")
        
        fetchRequest.predicate = NSPredicate(format: "code == %@", code)
        
        return try? context.fetch(fetchRequest).first ?? nil
    }
    
    /// CoreData Fetch
    /// - Returns: [Location]
    func fetch() -> [NSManagedObject] {
        let context = _AD.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Location")
        
        // 정렬 속성
        do {
            
            
            let sortCurrentArea = NSSortDescriptor(key: "currentArea", ascending: false)
            let sortRegDate = NSSortDescriptor(key: "regdate", ascending: false)
            fetchRequest.sortDescriptors = [sortCurrentArea, sortRegDate]
            
    
            
            let result = try context.fetch(fetchRequest)
            
            print("fetched result: \(result)")
            
            defer {
                self.tableView.performBatchUpdates({
                    _ = result.map {
                        items.append(
                            LocationVO(
                                currentArea: $0.value(forKey: "currentArea") as! Bool,
                                city: $0.value(forKey: "city") as! String,
                                code: $0.value(forKey: "code") as! String,
                                longitude: $0.value(forKey: "longitude") as! String,
                                latitude: $0.value(forKey: "latitude") as! String,
                                recent_temp: $0.value(forKey: "recent_temp") as? Int,
                                timezone: $0.value(forKey: "timezone") as! Int64
                            )
                        )
                        
                        self.tableView.insertRows(at: [IndexPath(row: self.items.count - 1, section: 0)], with: .bottom)
                    }
                
                }, completion: nil)
            }
            
            return result
        } catch let error {
            print(error.localizedDescription)
            return []
        }
    }
    
    func deleteByCode(code: String) -> Bool {
    
        if let result = fetchByKey(code: code) {
            return delete(object: result)
        } else {
            return false
        }
    }
    
    @discardableResult
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
    
    @available(*, deprecated)
    @discardableResult
    func edit(object: NSManagedObject, location: LocationVO) -> Bool {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        print("111: de222저장: \(location.city) \(location.currentArea)")
        
        object.setValue(location.city, forKey: "city")
        object.setValue(location.code, forKey: "code")
        object.setValue(location.recent_temp, forKey: "recent_temp")
        object.setValue(location.currentArea, forKey: "currentArea")
        object.setValue(location.latitude, forKey: "latitude")
        object.setValue(location.longitude, forKey: "longitude")
        object.setValue(location.timezone, forKey: "timezone")
        
        object.setValue(Date(), forKey: "regdate")
        
        do {
            try context.save()
            return true
        } catch {
            context.rollback()
            return false
        }
    }
    
    @available(*, deprecated)
    @discardableResult
    func save(location: LocationVO) -> Bool {
                
        let context = _AD.persistentContainer.viewContext
        
        let object = NSEntityDescription.insertNewObject(forEntityName: "Location", into: context)
        
        print("111: de1저장: \(location.city) \(location.currentArea)")
        object.setValue(location.currentArea, forKey: "currentArea")
        object.setValue(location.city, forKey: "city")
        object.setValue(location.code, forKey: "code")
        object.setValue(location.longitude, forKey: "longitude")
        object.setValue(location.latitude, forKey: "latitude")
        object.setValue(location.recent_temp, forKey: "recent_temp")
        object.setValue(Date(), forKey: "regdate")
        object.setValue(location.timezone, forKey: "timezone")
        
        do {
            try context.save()
            return true
        } catch {
            context.rollback()
            return false
        }
    }
    
    @discardableResult
    func save(object: NSManagedObject?, location: LocationVO) -> Bool {
                
        let context = _AD.persistentContainer.viewContext
        
        var obj: NSManagedObject!
        
        if nil != object {
            obj = object
        } else {
            obj = NSEntityDescription.insertNewObject(forEntityName: "Location", into: context)
        }
        
        print("111: 저장: \(location.city) \(location.currentArea)")
        obj.setValue(location.currentArea, forKey: "currentArea")
        obj.setValue(location.city, forKey: "city")
        obj.setValue(location.code, forKey: "code")
        obj.setValue(location.longitude, forKey: "longitude")
        obj.setValue(location.latitude, forKey: "latitude")
        obj.setValue(location.recent_temp, forKey: "recent_temp")
        obj.setValue(Date(), forKey: "regdate")
        obj.setValue(location.timezone, forKey: "timezone")
        
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
        
        return items.count
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
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell") as? WeatherCell
        else { fatalError() }
        
        cell.separatorInset = UIEdgeInsets.zero // https://zeddios.tistory.com/235
                
        var record = self.items[indexPath.row]
        
        print("111: \(record.city) \(record.currentArea)")
        
        cell.locationName.text = record.city
        
        print("record.recent_temp : \(record.recent_temp)")
        if let temp = record.recent_temp {
            cell.temperature.text = "\(temp)\(fahrenheitOrCelsius.emoji)"
        } else {
            cell.temperature.text = "--\(fahrenheitOrCelsius.emoji)"
        }
        
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .iso8601)
        df.timeZone = TimeZone(secondsFromGMT: Int(record.timezone))
        df.locale = Locale(identifier: UICommon.getLanguageCountryCode())
        df.dateFormat = "a hh:mm"
        
        //print("timezone: \(record.timezone) => dt: \(df.string(from: Date()))")
        cell.time.text = df.string(from: Date())
        
        let param: [String: Any] = ["lat": record.latitude,
                                    "lon": record.longitude,
                                    "appid": "0367480f207592a2a18d028adaac65d2",
                                    "lang": _COUNTRY,
                                    "units": fahrenheitOrCelsius.pameter]
        API.init(session: Session.default)
            .request("https://api.openweathermap.org/data/2.5/weather", method: .get, parameters: param, encoding: URLEncoding.default, headers: nil, interceptor: nil, requestModifier: nil) { json in
                
                //print(JSON(json))
                
                let temp = json["main"]["temp"].intValue
                cell.temperature.fadeTransition(0.8)
                cell.temperature.text = "\(temp)\(fahrenheitOrCelsius.emoji)"
                
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
        
        let object = items[indexPath.row]
        
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
        if self.items[indexPath.row].currentArea {
            return .none
        } else {
            return .delete
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let object = items[indexPath.row]
        
        if self.deleteByCode(code: object.code) {
            
            tableView.performBatchUpdates({
                items.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
            }, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        let object = items[indexPath.row]
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
            
            let prevLocation = self.fetchByCurrent()
            
            if nil != prevLocation {
                if ((prevLocation?.value(forKey: "longitude") as! String).nearBy() == currentLocation.coordinate.longitude.description.nearBy()) &&
                    ((prevLocation?.value(forKey: "latitude") as! String).nearBy() == currentLocation.coordinate.latitude.description.nearBy()) {
                    // do nothing
                    
                    print("위치 같아서 안해도 됨")
                    return
                }
            }
            
            let param: [String: Any] = ["lat": currentLocation.coordinate.latitude,
                                        "lon": currentLocation.coordinate.longitude,
                                        "appid": "0367480f207592a2a18d028adaac65d2",
                                        "lang": _COUNTRY,
                                        "units": fahrenheitOrCelsius.pameter] //imperial - Fahrenheit
            API(session: Session.default)
                .request("https://api.openweathermap.org/data/2.5/weather",
                         method: .get,
                         parameters: param,
                         encoding: URLEncoding.default,
                         headers: nil,
                         interceptor: nil,
                         requestModifier: nil) { json in
                    
                    self.tableView.performBatchUpdates ({
                        
                        let locationVO = LocationVO(
                            currentArea: true,
                            city: json["name"].stringValue,
                            code: json["id"].stringValue,
                            longitude: String(currentLocation.coordinate.longitude),
                            latitude: String(currentLocation.coordinate.latitude),
                            recent_temp: json["main"]["temp"].intValue,
                            timezone: json["timezone"].int64Value
                        )
                        
                        // 기존에 현위치 저장된 것이 있다면 업데이트 없으면 인서트
                        self.save(
                            object: prevLocation,
                            location: locationVO
                        )
                        
                        self.items.insert(locationVO,at: 0)
                        self.tableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .top)
                    }, completion: nil)
                }
        } else {
            
            // 기존에 현위치 저장된 것이 있다면 삭제
            if let currentArea = self.fetchByCurrent() {
                self.delete(object: currentArea)
            }
        }
    }
}

extension String {
    func nearBy() -> String {
        return String(Int((Double(self) ?? 0) * 1000))
    }
}

extension MainVC: SaveLocationDelegate {
    func requestSave(vo: LocationVO) {
        
        self.save(object: nil, location: vo)
        
        self.tableView.performBatchUpdates({
            self.items.append(vo)
            self.tableView.insertRows(at: [IndexPath(row: self.items.count - 1, section: 0)], with: .bottom)
        }, completion: nil)
    }
}

extension UIView {
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
}
