//
//  Define.swift
//  Weather
//
//  Created by 장태현 on 2021/04/17.
//

import UIKit

// MARK: 인디케이터

let _SI = Indicator.INSTANCE

// MARK: UserDefault

let _UDS = UserDefaults.standard

// MARK: AppDelegate

let _SD = UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate

let _AD = (UIApplication.shared.delegate as! AppDelegate)

// MARK: WINDOW

let _WINDOW = _SD.window!

// MARK: Notification

let _ND = NotificationCenter.default

let _COUNTRY = UICommon.getCountryCode()

var fahrenheitOrCelsius: FahrenheitOrCelsius = .Celsius

// MARK: Screen 정보

let Screen_Size = UIScreen.main.bounds
let Screen_Width = Screen_Size.width
let Screen_Height = Screen_Size.height

let Statusbar_Height = UIApplication.shared.statusBarFrame.size.height
let Navigationbar_Height = CGFloat(44.0)
let Top_Height = UIApplication.shared.statusBarFrame.size.height + Navigationbar_Height
