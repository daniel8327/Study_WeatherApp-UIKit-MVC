//
//  IntroVC.swift
//  Weather
//
//  Created by moonkyoochoi on 2021/05/07.
//

import CoreLocation
import UIKit

import Alamofire

class IntroVC: UIViewController {
    
    lazy var locationManager: CLLocationManager = {
    
        let locationManager = CLLocationManager()
        locationManager.delegate = self // CLLocationManagerDelegate
        locationManager.requestWhenInUseAuthorization()// 포그라운드에서 권한 요청
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
                
        return locationManager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 위치정보
        // 아이폰 설정에서의 위치 서비스가 켜진 상태라면
        if CLLocationManager.locationServicesEnabled() {
            print("위치 서비스 On 상태")
            locationManager.startUpdatingLocation() //위치 정보 받아오기 시작 CLLocationManagerDelegate
        } else {
            print("위치 서비스 Off 상태")
            removeCurrentData()
        }
    }
    
    /// 현위치 저장 내역 삭제
    func removeCurrentData() {
        // 기존에 현위치 저장된 것이 있다면 삭제
        if let currentArea = CoreDataHelper.fetchByCurrent() {
            CoreDataHelper.delete(object: currentArea)
        }
    }
    
    func currentLocationInfo(manager: CLLocationManager) {
        
        let prevLocation = CoreDataHelper.fetchByCurrent()
        
        // 위치 정확도 Best, 배터리 많이 잡아먹음
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        guard let currentLocation = locationManager.location else {
            
            if let _ = prevLocation {
                // 지난 현재위치 삭제
                CoreDataHelper.delete(object: prevLocation!)
            }
            return
        }
        
        if let loc = prevLocation {
            if ((loc.value(forKey: "longitude") as! String).nearBy() == currentLocation.coordinate.longitude.description.nearBy()) &&
                ((loc.value(forKey: "latitude") as! String).nearBy() == currentLocation.coordinate.latitude.description.nearBy()) {
                // do nothing
                
                print("위치 같아서 안해도 됨")
                
                return
            } else {
                // 지난 현재위치 삭제 후 새로운 위치 받기
                CoreDataHelper.delete(object: loc)
            }
        }
        
        let param: [String: Any] =
            ["lat": currentLocation.coordinate.latitude,
             "lon": currentLocation.coordinate.longitude]
        
        let json = API(session: Session.default)
            .requestSync(API.WEATHER,
                         method: .get,
                         parameters: param)
        
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
    }
}

extension IntroVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        // 현위치 처리
        currentLocationInfo(manager: manager)
        
        // 조회
        let result = CoreDataHelper.fetch()
        
        var items: [LocationVO] = []
        
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
        }
        
        let vc = DetailWeatherPageVC(items: items, index: 0)
        vc.modalPresentationStyle = .fullScreen
        
        switch status {
        
        case .authorizedAlways,
             .authorizedWhenInUse:
            
            self.present(vc, animated: false)
        default:
            removeCurrentData()
            self.present(vc, animated: false)
        }
    }
}
