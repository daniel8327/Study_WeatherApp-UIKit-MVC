//
//  API.swift
//  Weather
//
//  Created by 장태현 on 2021/04/17.
//

import UIKit

import Alamofire
import SwiftyJSON

class API {
    
    private let sessionManager: SessionManagerProtocol

    init(session: SessionManagerProtocol) {
        sessionManager = session
    }

    /// 통신 프로토콜 기본형
    /// - Parameters:
    ///   - path: api 경로
    ///   - method: 전송타입
    ///   - param: 파라메터
    ///   - completionHandler: 콜백
    func request(_ convertible: Alamofire.URLConvertible, method: Alamofire.HTTPMethod, parameters: Alamofire.Parameters?, encoding: Alamofire.ParameterEncoding, headers: Alamofire.HTTPHeaders?, interceptor: Alamofire.RequestInterceptor?, requestModifier: Alamofire.Session.RequestModifier?, completionHandler: @escaping (JSON) -> Void) {
        _SI.startAnimating()

        //print("path: \(convertible)\nparam: \(parameters)")

        sessionManager.request(convertible, method: method, parameters: parameters, encoding: encoding, headers: headers, interceptor: interceptor, requestModifier: requestModifier)
            .responseJSON(completionHandler: { response in

                _SI.stopAnimating()

                if let error = response.error {
                    print(error)
                    print("Error occured")
                    // alert

                    if let topVC = UIApplication.getTopViewController() {
                        Alert.show(parent: topVC, title: "network_Error", message: error.localizedDescription)
                    }
                } else {
                    guard let responseData = response.data else {
                        print("Data is missing")
                        // alert

                        if let topVC = UIApplication.getTopViewController() {
                            Alert.show(parent: topVC, title: "Network Error", message: "Data is missing")
                        }
                        return
                    }

                    let json = JSON(responseData)

                    //print("path : \(convertible)\njson => \(json)\n")

                    if !json["cod"].exists() || json["cod"].intValue == 200 {
                        completionHandler(json)
                    } else {
                        // alert
                        if let topVC = UIApplication.getTopViewController() {
                            Alert.show(parent: topVC, title: "Failed", message: json["MESSAGE"].stringValue)
                        }
                    }
                }
            })
    }
}
