//
//  SessionManagerStub.swift
//  GlobalFriend
//
//  Created by 장태현 on 2021/04/17.
//

@testable import Alamofire // DataRequest.init(...)는 internal 이어서 직접 쓸 수 없으니 @testable로 선언해줘서 접근한다.
import Foundation

final class SessionManagerStub: SessionManagerProtocol {
    struct RequestConvertible: URLRequestConvertible {
        let url: URLConvertible
        let method: HTTPMethod
        let parameters: Parameters?
        let encoding: ParameterEncoding
        let headers: HTTPHeaders?
        let requestModifier: RequestModifier?

        func asURLRequest() throws -> URLRequest {
            var request = try URLRequest(url: url, method: method, headers: headers)
            try requestModifier?(&request)

            return try encoding.encode(request, with: parameters)
        }
    }

    var requestParameters: (
        url: URLConvertible,
        method: HTTPMethod,
        parameters: Parameters?
    )?

    func request(_ convertible: URLConvertible, method: HTTPMethod, parameters: Parameters?, encoding _: ParameterEncoding, headers _: HTTPHeaders?, interceptor _: RequestInterceptor?, requestModifier _: Session.RequestModifier?) -> DataRequest {
        requestParameters = (url: convertible, method: method, parameters: parameters)

        return DataRequest(convertible: convertible as! URLRequestConvertible, underlyingQueue: DispatchQueue(label: ""), serializationQueue: DispatchQueue(label: ""), eventMonitor: nil, interceptor: nil, delegate: SessionDelegate() as! RequestDelegate)
    }
}
