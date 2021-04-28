//
//  Model.swift
//  Weather
//
//  Created by moonkyoochoi on 2021/04/26.
//

import Foundation

protocol JSONVO {
    
}

struct HourlyVO: JSONVO {
    var items: [Current]
}

struct DailyVO: JSONVO {
    var items: [Daily]
}
