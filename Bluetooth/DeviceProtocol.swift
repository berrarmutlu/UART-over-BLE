//
//  DeviceProtocol.swift
//  UART over BLE
//
//  Created by Berra Armutlu on 17.08.2026.
//

import Foundation

enum Command: String { //komut(lar)
    case temperature = "?t"
    case humidity = "?h"
    case level = "?l"
    case dateTime = "?d"
    case serialNumber = "?s"
    case calibrationDate = "?c"
    
    }

enum LevelCommand: String {
    case increase = "?l+"
    case decrease = "?l-"
}

enum DeviceDateFormat {
    static let date = "yyyyMMdd"
    static let dateTime = "yyyyMMdd HHmmss"
    static let weekday = "EEEE"
}

enum DisplayDateFormat {
    static let date = "dd.MM.yyyy"
    static let time = "HH:mm"
    static let dateTime = "dd.MM.yyyy HH:mm"
}
