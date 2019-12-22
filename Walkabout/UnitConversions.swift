//
//  UnitConversions.swift
//  Walkabout
//
//  Created by Nabil Haffar on 10/22/19.
//  Copyright © 2019 Nabil Haffar. All rights reserved.
//

import Foundation



class UnitConversions {
  static func distance(_ distance: Double) -> String {
    let distanceMeasurement = Measurement(value: distance, unit: UnitLength.meters)
    return UnitConversions.distance(distanceMeasurement)
  }
  
  static func distance(_ distance: Measurement<UnitLength>) -> String {
    let formatter = MeasurementFormatter()
    return formatter.string(from: distance)
  }
  
  static func time(_ seconds: Int) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second]
    formatter.unitsStyle = .positional
    formatter.zeroFormattingBehavior = .pad
    return formatter.string(from: TimeInterval(seconds))!
  }
    static func date(_ timestamp: Date?) -> String {
      guard let timestamp = timestamp as Date? else { return "" }
      let formatter = DateFormatter()
      formatter.dateStyle = .medium
      return formatter.string(from: timestamp)
    }
  
  static func speed(distance: Measurement<UnitLength>, time: Int, outputUnit: UnitSpeed) -> String {
    let formatter = MeasurementFormatter()
    formatter.unitOptions = [.providedUnit] // 1
    let speedMagnitude = time != 0 ? distance.value / Double(time) : 0
    let speed = Measurement(value: speedMagnitude, unit: UnitSpeed.metersPerSecond)
    return formatter.string(from: speed.converted(to: outputUnit))
  }
  
  
}
