//
//  Location.swift
//  Weather
//
//  Created by moonkyoochoi on 2021/04/28.
//

import Foundation

struct LocationVO {
    let currentArea: Bool
    let city: String
    let code: String
    let longitude: String
    let latitude: String
    var recent_temp: Int?
    let timezone: Int64
}
