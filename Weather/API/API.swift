//
//  API.swift
//  Weather
//
//  Created by 장태현 on 2021/04/17.
//

import UIKit

import Alamofire
import SwiftyJSON

struct API {
    
    private let sessionManager: SessionManagerProtocol
    private let appid = "0367480f207592a2a18d028adaac65d2"
    static let WEATHER = "https://api.openweathermap.org/data/2.5/weather"
    static let ONCELL = "https://api.openweathermap.org/data/2.5/onecall"

    init(session: SessionManagerProtocol) {
        sessionManager = session
    }
    
    func requestSync(_ url: URLRequest) -> JSON {
        
        //Indicator.INSTANCE.startAnimating()
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var json: JSON!
        
        print("semaphore start")
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if error != nil {
                print("error: \(error?.localizedDescription)")
                return
            }
            
            json = JSON(data)
        }
        
        print("semaphore start wait")
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.now() + .seconds(30))
        //semaphore.wait()
        
        print("semaphore end wait")
        //Indicator.INSTANCE.terminateIndicator()
        
        return json
    }

    /// 통신 프로토콜 기본형
    /// - Parameters:
    ///   - path: api 경로
    ///   - method: 전송타입
    ///   - param: 파라메터
    ///   - completionHandler: 콜백
    func request(_ convertible: Alamofire.URLConvertible, method: Alamofire.HTTPMethod, parameters: Alamofire.Parameters?, encoding: Alamofire.ParameterEncoding, headers: Alamofire.HTTPHeaders?, interceptor: Alamofire.RequestInterceptor?, requestModifier: Alamofire.Session.RequestModifier?, completionHandler: @escaping (JSON) -> Void) {
        
        //_SI.startAnimating()
        
        sessionManager.request(convertible, method: method, parameters: setAdditionalInfo(params: parameters), encoding: encoding, headers: headers, interceptor: interceptor, requestModifier: requestModifier)
            .responseJSON(completionHandler: { response in
                
                //_SI.stopAnimating()
                
                switch response.result {
                case .success(let data):
                    let json = JSON(data)

                    //print("path : \(convertible)\njson => \(json)\n")

                    if !json["cod"].exists() || json["cod"].intValue == 200 {
                        completionHandler(json)
                    } else {
                        Alert.show(parent: nil, title: "Failed", message: json["MESSAGE"].stringValue)
                    }
                case .failure(let error):
                    
                    print(error)
                    print("Error occured")
                    Alert.show(parent: nil, title: "network_Error", message: error.localizedDescription)
                }
            })
    }
    
    /// 공통 파라메터 추가분 적용
    /// - Parameter params: 기존 파라메터
    /// - Returns: 추가 파라메터 적용 파라메터
    func setAdditionalInfo(params: Alamofire.Parameters?) -> Alamofire.Parameters? {
        
        var parameters = params
        parameters?.updateValue(appid, forKey: "appid")
        parameters?.updateValue(_COUNTRY, forKey: "lang")
        parameters?.updateValue(fahrenheitOrCelsius.pameter, forKey: "units")
        return parameters
    }
}
