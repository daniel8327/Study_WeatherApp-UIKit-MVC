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

        print("path: \(convertible)\nparam: \(parameters)")

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

                    print("path : \(convertible)\njson => \(json)\n")

                    if let result = json["RESULT"].string,
                       result == APIResult.SUCCESS.rawValue || result == APIResult.FAIL.rawValue
                    {
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

    /// 통신 프로토콜 기본형
    /// - Parameters:
    ///   - path: api 경로
    ///   - method: 전송타입
    ///   - param: 파라메터
    ///   - completionHandler: 콜백tfffd
    @available(*, deprecated)
    open class func request(path: String, method: HTTPMethod, param: [String: String], completionHandler: @escaping (JSON) -> Void) {
        _SI.startAnimating()

        print("path: \(path)\nparam: \(JSON(param))")

        AF.request(path,
                   method: method,
                   parameters: param)
            .responseJSON { response in

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

                    print("path : \(path)\njson => \(json)\n")

                    if let result = json["RESULT"].string,
                       result == APIResult.SUCCESS.rawValue || result == APIResult.FAIL.rawValue
                    {
                        completionHandler(json)
                    } else {
                        // alert
                        if let topVC = UIApplication.getTopViewController() {
                            Alert.show(parent: topVC, title: "Failed", message: json["MESSAGE"].stringValue)
                        }
                    }
                }
            }
    }

    // MARK: 멀티파트 전송 updoad function

    /// - Parameters:
    ///   - path: api 경로
    ///   - param: 파라메터
    ///   - datas: 전송데이터
    ///   - completionHandler: 콜백
    open class func upload(path: String, param: [String: String], datas: [String: Data], completionHandler: @escaping (JSON) -> Void) {
        _SI.startAnimating()

        print("param: \(JSON(param))")

        AF
            .upload(
                multipartFormData: { multipartFormData in
                    for (key, value) in param {
                        multipartFormData.append(value.data(using: .utf8)!, withName: key)
                        // multipartFormData.append(value.data(using: .utf8)!, withName: key, mimeType: "text/plain")
                    }
                    _ = datas.map {
                        // multipartFormData.append($0.value, withName: $0.key)
                        multipartFormData.append($0.value, withName: "image", fileName: $0.key, mimeType: "image/jpg")
                    }
                },
                to: path,
                method: .post
            )
            .responseJSON { response in

                debugPrint(response)

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

                    print("path : \(path)\njson => \(json)\n")

                    if let result = json["RESULT"].string,
                       result == APIResult.SUCCESS.rawValue || result == APIResult.FAIL.rawValue
                    {
                        completionHandler(json)
                    } else {
                        // alert
                        if let topVC = UIApplication.getTopViewController() {
                            Alert.show(parent: topVC, title: "Failed", message: json["MESSAGE"].stringValue)
                        }
                    }
                }
            }
    }
}

enum APIResult: String {
    case SUCCESS
    case FAIL
}
