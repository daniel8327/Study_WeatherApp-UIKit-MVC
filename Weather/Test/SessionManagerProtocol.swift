//
//  SessionManagerProtocol.swift
//
//
//  Created by 장태현 on 2021/04/17.
//

import Foundation

@testable import Alamofire
import SwiftyJSON

public typealias RequestModifier = (inout URLRequest) throws -> Void

protocol SessionManagerProtocol {
    /*
     open func request(_ convertible: Alamofire.URLConvertible, method: Alamofire.HTTPMethod = .get, parameters: Alamofire.Parameters? = nil, encoding: Alamofire.ParameterEncoding = URLEncoding.default, headers: Alamofire.HTTPHeaders? = nil, interceptor: Alamofire.RequestInterceptor? = nil, requestModifier: Alamofire.Session.RequestModifier? = nil) -> Alamofire.DataRequest
     */
    func request(_ convertible: Alamofire.URLConvertible, method: Alamofire.HTTPMethod, parameters: Alamofire.Parameters?, encoding: Alamofire.ParameterEncoding, headers: Alamofire.HTTPHeaders?, interceptor: Alamofire.RequestInterceptor?, requestModifier: Alamofire.Session.RequestModifier?) -> Alamofire.DataRequest
}

extension Alamofire.Session: SessionManagerProtocol {}
