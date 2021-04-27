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
    let timezone: String
    let hourly: [Current]
    let daily: [Daily]
    let minutely: [Minutely]?
    let lon, lat: Double
    let current: Current
    let timezoneOffset: Int

    enum CodingKeys: String, CodingKey {
        case timezone, hourly, daily, lon, lat, current, minutely
        case timezoneOffset = "timezone_offset"
    }
}

// MARK: - Current
struct Current: Codable {
    let feelsLike, dewPoint: Double
    let sunrise, sunset: Int?
    let temp: Double
    let humidity, windDeg: Int
    let uvi: Double
    let weather: [Weather]
    let dt, clouds, pressure: Int
    let windSpeed: Double
    let visibility: Int
    let pop, windGust: Double?
    let rain: Rain?

    enum CodingKeys: String, CodingKey {
        case feelsLike = "feels_like"
        case dewPoint = "dew_point"
        case sunrise, sunset, temp, humidity
        case windDeg = "wind_deg"
        case uvi, weather, dt, clouds, pressure
        case windSpeed = "wind_speed"
        case visibility, pop
        case windGust = "wind_gust"
        case rain
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
    let icon: String
    let id: Int
    let main: Main
    let weatherDescription: String

    enum CodingKeys: String, CodingKey {
        case icon, id, main
        case weatherDescription = "description"
    }
}

enum Main: String, Codable {
    case clear = "Clear"
    case clouds = "Clouds"
    case rain = "Rain"
}

// MARK: - Daily
struct Daily: Codable {
    let feelsLike: FeelsLike
    let dewPoint: Double
    let sunrise, moonrise, sunset: Int
    let temp: Temp
    let uvi: Double
    let windDeg, humidity: Int
    let weather: [Weather]
    let moonset, dt, clouds: Int
    let windSpeed, moonPhase: Double
    let pressure: Int
    let windGust, pop: Double?
    let rain: Double?

    enum CodingKeys: String, CodingKey {
        case feelsLike = "feels_like"
        case dewPoint = "dew_point"
        case sunrise, moonrise, sunset, temp, uvi
        case windDeg = "wind_deg"
        case humidity, weather, moonset, dt, clouds
        case windSpeed = "wind_speed"
        case moonPhase = "moon_phase"
        case pressure
        case windGust = "wind_gust"
        case pop, rain
    }
}

// MARK: - FeelsLike
struct FeelsLike: Codable {
    let day, morn, night, eve: Double
}

// MARK: - Temp
struct Temp: Codable {
    let night, max, day, morn: Double
    let min, eve: Double
}

// MARK: - Minutely
struct Minutely: Codable {
    let precipitation: Double?
    let dt: Int?
}
