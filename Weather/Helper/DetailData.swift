//
//  DetailData.swift
//  Weather
//
//  Created by moonkyoochoi on 2021/04/21.
//

import Foundation
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(DetailData.self, from: jsonData)

import Foundation

// MARK: - DetailData
struct DetailData: Codable {
    let lat, lon: Double
    let timezone: String
    let timezoneOffset: Int
    let current: Current
    let minutely: [Minutely]?
    let hourly: [Current]
    let daily: [Daily]

    enum CodingKeys: String, CodingKey {
        case lat, lon, timezone
        case timezoneOffset = "timezone_offset"
        case current, minutely, hourly, daily
    }
}

// MARK: - Current
struct Current: Codable {
    let dt: Int
    let sunrise, sunset: Int?
    let temp, feelsLike: Double
    let pressure, humidity: Int
    let dewPoint, uvi: Double
    let clouds, visibility: Int
    let windSpeed: Double
    let windDeg: Int
    let weather: [Weather]
    let windGust, pop: Double?
    let rain: Rain?

    enum CodingKeys: String, CodingKey {
        case dt, sunrise, sunset, temp
        case feelsLike = "feels_like"
        case pressure, humidity
        case dewPoint = "dew_point"
        case uvi, clouds, visibility
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case weather
        case windGust = "wind_gust"
        case pop, rain
    }
}

// MARK: - Rain
struct Rain: Codable {
    let the1H: Double

    enum CodingKeys: String, CodingKey {
        case the1H = "1h"
    }
}

// MARK: - Weather
struct Weather: Codable {
    let id: Int
    let main: Main
    let weatherDescription: Description
    let icon: Icon

    enum CodingKeys: String, CodingKey {
        case id, main
        case weatherDescription = "description"
        case icon
    }
}

enum Icon: String, Codable {
    case the02D = "02d"
    case the03D = "03d"
    case the04D = "04d"
    case the04N = "04n"
    case the10D = "10d"
    case the10N = "10n"
}

enum Main: String, Codable {
    case clouds = "Clouds"
    case rain = "Rain"
}

enum Description: String, Codable {
    case 구름조금 = "구름조금"
    case 보통비 = "보통 비"
    case 실비 = "실 비"
    case 약간의구름이낀하늘 = "약간의 구름이 낀 하늘"
    case 온흐림 = "온흐림"
    case 튼구름 = "튼구름"
}

// MARK: - Daily
struct Daily: Codable {
    let dt, sunrise, sunset, moonrise: Int
    let moonset: Int
    let moonPhase: Double
    let temp: Temp
    let feelsLike: FeelsLike
    let pressure, humidity: Int
    let dewPoint, windSpeed: Double
    let windDeg: Int
    let windGust: Double
    let weather: [Weather]
    let clouds: Int
    let pop, uvi: Double
    let rain: Double?

    enum CodingKeys: String, CodingKey {
        case dt, sunrise, sunset, moonrise, moonset
        case moonPhase = "moon_phase"
        case temp
        case feelsLike = "feels_like"
        case pressure, humidity
        case dewPoint = "dew_point"
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case windGust = "wind_gust"
        case weather, clouds, pop, uvi, rain
    }
}

// MARK: - FeelsLike
struct FeelsLike: Codable {
    let day, night, eve, morn: Double
}

// MARK: - Temp
struct Temp: Codable {
    let day, min, max, night: Double
    let eve, morn: Double
}

// MARK: - Minutely
struct Minutely: Codable {
    let dt, precipitation: Int
}
