//
//  Enums.swift
//  Weather
//
//  Created by moonkyoochoi on 2021/05/03.
//

import Foundation

enum FahrenheitOrCelsius: String {
    case Fahrenheit
    case Celsius
}

extension FahrenheitOrCelsius {
    var stringValue: String {
        return "\(self)"
    }
    
    var emoji: String {
        switch self {
        case .Celsius:
            return "℃"
        case .Fahrenheit:
            return "℉"
        }
    }
    
    var pameter: String {
        switch self {
        case .Celsius:
            return "metric"
        default:
            return "imperial"
        }
    }
}
