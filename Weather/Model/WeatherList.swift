//
//  Model.swift
//  Weather
//
//  Created by moonkyoochoi on 2021/04/26.
//

import Foundation

protocol WeatherList {
    
}

struct HourlyVO: WeatherList {
    var items: [Current]
}

struct DailyVO: WeatherList {
    var items: [Daily]
}
