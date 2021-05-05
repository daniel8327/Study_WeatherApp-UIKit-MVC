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
import SkeletonView
import SwiftyJSON


class MainVC: UIViewController {
    
    lazy var locationManager: CLLocationManager = {
    
        let locationManager = CLLocationManager()
        locationManager.delegate = self // CLLocationManagerDelegate
        locationManager.requestWhenInUseAuthorization()// 포그라운드에서 권한 요청
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
                
        return locationManager
    }()
    
    private(set) var items: [LocationVO] = {
        return []
    }()
    
    var currentLocation: CLLocation?
    
    lazy var tableView: UITableView = {
        
         let tbv = UITableView(frame: .zero)
        
        view.addSubview(tbv)
        
        tbv.translatesAutoresizingMaskIntoConstraints = false
        tbv.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tbv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tbv.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tbv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        tbv.rowHeight = UITableView.automaticDimension
        tbv.estimatedRowHeight = 100
        
        tbv.register(UINib(nibName: WeatherCell.reusableIdentifier, bundle: nil), forCellReuseIdentifier: WeatherCell.reusableIdentifier)
        tbv.separatorStyle = .none
        
        
        // xib 호출 방법1
        if let loadedNib = Bundle.main.loadNibNamed("LocationFooter", owner: self, options: nil) {
            if let view = loadedNib[1] as? UIView {
                tbv.tableFooterView = view
                
                NotificationCenter
                    .default
                    .addObserver(
                        self,
                        selector: #selector(addLocation),
                        name: Notification.Name("ADD_LOCATION"),
                        object: nil)
                
                NotificationCenter
                    .default
                    .addObserver(
                        self,
                        selector: #selector(changeNotation),
                        name: Notification.Name("CHANGE_NOTATION"),
                        object: nil)
            }
        }
        
        // xib 호출 방법2
        //if let aa = UINib(nibName: "LocationFooter", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView //xib의 첫번째
        /*if let aa = UINib(nibName: "LocationFooter", bundle: nil).instantiate(withOwner: self, options: nil)[1] as? UIView { // xib의 두번째
            tbv.tableFooterView = aa
            
        }*/
        
        return tbv
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private let dateFormatter: DateFormatter = {
       
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .iso8601)
        df.timeZone = TimeZone.current
        //df.locale = Locale.current
        //df.locale = Locale(identifier: "ko_KR")
        df.locale = Locale(identifier: UICommon.getLanguageCountryCode())

        df.dateFormat = "hh:mm a"
        return df
    }()
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        tableView.isSkeletonable = true

        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight, duration: 0.5, autoreverses: true)

        tableView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .lightGray), animation: animation, transition: .crossDissolve(0.5))
        tableView.showSkeleton(usingColor: .red)
        
        
        
        view.backgroundColor = .systemBackground
        
//        // 아이폰 설정에서의 위치 서비스가 켜진 상태라면
//        if CLLocationManager.locationServicesEnabled() {
//            print("위치 서비스 On 상태")
//            locationManager.startUpdatingLocation() //위치 정보 받아오기 시작 CLLocationManagerDelegate
//        } else {
//            print("위치 서비스 Off 상태")
//            removeCurrentData()
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            
            let result = CoreDataHelper.fetch()
        
            
            //self.tableView.performBatchUpdates({
                _ = result.map {
                    self.items.append(
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
                    
                    //self.tableView.insertRows(at: [IndexPath(row: self.items.count - 1, section: 0)], with: .bottom)
                }
            
                self.tableView.reloadData()
            
                self.tableView.stopSkeletonAnimation()
                self.tableView.hideSkeleton(reloadDataAfter: true)
                
            //}, completion: nil)
            
            self.checkLocations()
        }
    }
    
    // MARK: Selectors
    
    /// 섭씨/화씨 전환
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
        
        self.tableView.reloadData()
        //UIView.transition(with: self.tableView, duration: 1.0, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
        
    }
    
    /// 도시 추가
    @objc func addLocation() {
        
        // 도시 검색
        let vc = AddLocationVC()
        
        vc.saveDelegate = self // SaveLocationDelegate
        /*
        vc.saveLocationAlias = { location in //[weak self] locationElements in
            CoreDataHelper.save(object: nil, location: location)
            
            self.tableView.performBatchUpdates({
                self.items.append(location)
                self.tableView.insertRows(at: [IndexPath(row: self.items.count - 1, section: 0)], with: .bottom)
            }, completion: nil)
        }*/
        self.present(vc, animated: true)
    }
    
    // MARK: User Functions
    
    /// 도시 추가 확인
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
    
    /// 현위치 저장 내역 삭제
    func removeCurrentData() {
        // 기존에 현위치 저장된 것이 있다면 삭제
        if let currentArea = CoreDataHelper.fetchByCurrent() {
            CoreDataHelper.delete(object: currentArea)
        }
    }
    
    // MARK: Deprecated
    
    @available(*, deprecated)
    func setHeaderView() {
        
        guard let headerView: WeatherCell = tableView.tableHeaderView as? WeatherCell,
              let location = self.currentLocation
        else { return }
            
        headerView.locationName.text = "--"
        headerView.temperature.text = "--\(fahrenheitOrCelsius.emoji)"
        
        let param: [String: Any] = ["lat": location.coordinate.latitude,
                                    "lon": location.coordinate.longitude]
        API(session: Session.default)
            .request(
                API.WEATHER,
                method: .get,
                parameters: param,
                encoding: URLEncoding.default,
                headers: nil,
                interceptor: nil,
                requestModifier: nil
            ) { json in
                
                //print(JSON(json))
                
                headerView.locationName.text = "현재위치 - \(json["name"].stringValue)"
                headerView.temperature.text = "\(json["main"]["temp"].intValue)\(fahrenheitOrCelsius.emoji)"
                headerView.time.text = Date().getCountryTime(byTimeZone: json["timezone"].intValue)
            }
    }
}

extension MainVC: SkeletonTableViewDataSource {
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "WeatherCell"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell") as? WeatherCell
        else { fatalError() }
        
        cell.separatorInset = UIEdgeInsets.zero // https://zeddios.tistory.com/235
                
        let record = self.items[indexPath.row]
        
        print("111: \(record.city) \(record.currentArea)")
        
        cell.locationName.text = record.city
        
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
                                    "lon": record.longitude]
        
        API.init(session: Session.default)
            .request(
                API.WEATHER,
                method: .get,
                parameters: param,
                encoding: URLEncoding.default,
                headers: nil,
                interceptor: nil,
                requestModifier: nil
            ) { json in
                
                //print(JSON(json))
                
                let temp = json["main"]["temp"].intValue
                //cell.temperature.fadeTransition(0.8)
                cell.temperature.text = "\(temp)\(fahrenheitOrCelsius.emoji)"
                
                CoreDataHelper.editByCode(cityCode: json["id"].stringValue, temperature: temp)
                
                
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
                
                /*
                 
                 let object = items[indexPath.row]
                 
                 let location = CLLocation(
                     latitude: CLLocationDegrees(Double(object.latitude)!),
                     longitude: CLLocationDegrees(Double(object.longitude)!)
                 )
             
                 let vc = DetailWeatherVC(locationName: object.city, locationCode: object.code, location: location)
             
                 
                 */
                /*    print("callDetailData needed")
                let param: [String: Any] = ["lat": record.latitude,
                                            "lon": record.longitude,
                                                "appid": "0367480f207592a2a18d028adaac65d2",
                                                "lang": _COUNTRY,
                                                "units": fahrenheitOrCelsius.pameter] //imperial - Fahrenheit
                    API(session: Session.default)
                        .request("https://api.openweathermap.org/data/2.5/onecall", method: .get, parameters: param, encoding: URLEncoding.default, headers: nil, interceptor: nil, requestModifier: nil) { json in
                            
                            //print(JSON(json))
                            
                            // Tx 발생하기때문에 강한 참조로 묶어준다. https://jinsangjin.tistory.com/129 참고
                            //guard let self = self else { return }
                            
                            do {
                                let data = try JSONDecoder().decode(DetailData.self, from: json.rawData())
                                
                                let context = _AD.persistentContainer.viewContext
                                
                                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CD_Location")
                                
                                fetchRequest.predicate = NSPredicate(format: "code == %@", record.code)
                                
                                guard let location = try context.fetch(fetchRequest).first else {
                                    fatalError()
                                }
                                
                                location.setValue(data, forKey: "current")
                                
                                try context.save()
                                print("context (\(indexPath.row)) saved")
                            } catch let error {
                                print(error)
                                print(error.localizedDescription)
                                fatalError()
                            }
                        }*/
            }
        //cell.backgroundColor = .random
 
        return cell
    }
}

extension MainVC: SkeletonTableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cell.alpha = 0
//        cell.layer.transform = CATransform3DMakeScale(0.8, 0.8, 0.8)
//        UIView.animate(withDuration: 0.5, delay: 0.2 * Double(indexPath.row)) {
//            cell.alpha = 1
//            cell.layer.transform = CATransform3DScale(CATransform3DIdentity, 1, 1, 1)
//        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let object = items[indexPath.row]
        
        let location = CLLocation(
            latitude: CLLocationDegrees(Double(object.latitude)!),
            longitude: CLLocationDegrees(Double(object.longitude)!)
        )
    
        let vc = DetailWeatherVC(locationName: object.city, locationCode: object.code, location: location)
    
        //UICommon.setTransitionAnimation(navi: self.navigationController)
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
        
        if CoreDataHelper.deleteByCode(code: object.code) {
            
            tableView.performBatchUpdates({
                items.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
            }, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

extension MainVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            
            print(locationManager)
            guard let currentLocation = locationManager.location else { return }
            
            let prevLocation = CoreDataHelper.fetchByCurrent()
            
            if let loc = prevLocation {
                if ((loc.value(forKey: "longitude") as! String).nearBy() == currentLocation.coordinate.longitude.description.nearBy()) &&
                    ((loc.value(forKey: "latitude") as! String).nearBy() == currentLocation.coordinate.latitude.description.nearBy()) {
                    // do nothing
                    
                    print("위치 같아서 안해도 됨")
                    return
                } else {
                    // 지난 현재위치 삭제
                    CoreDataHelper.delete(object: loc)
                }
            }
            
            let param: [String: Any] =
                ["lat": currentLocation.coordinate.latitude,
                 "lon": currentLocation.coordinate.longitude]
    
            API(session: Session.default)
                .request(API.WEATHER,
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
                        CoreDataHelper.save(
                            object: prevLocation,
                            location: locationVO
                        )
                        
                        self.items.insert(locationVO,at: 0)
                        self.tableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .top)
                    }, completion: nil)
                }
        } else {
            removeCurrentData()
        }
    }
}

extension MainVC: SaveLocationDelegate {
    func requestSave(vo: LocationVO) {
        
        CoreDataHelper.save(object: nil, location: vo)
        
        self.tableView.performBatchUpdates({
            self.items.append(vo)
            self.tableView.insertRows(at: [IndexPath(row: self.items.count - 1, section: 0)], with: .bottom)
        }, completion: nil)
    }
}
