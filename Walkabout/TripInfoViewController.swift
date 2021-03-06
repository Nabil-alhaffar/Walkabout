//
//  TripInfoViewController.swift
//  Walkabout
//
//  Created by Nabil Haffar on 10/21/19.
//  Copyright © 2019 Nabil Haffar. All rights reserved.
//
import UIKit
import Foundation
import MapKit

class TripInfoViewController : UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var averageSpeedLbl: UILabel!
    @objc var trip: Trip!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        configureView()
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      guard let polyline = overlay as? MKPolyline else {
        return MKOverlayRenderer(overlay: overlay)
      }
      let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = .systemBlue
      renderer.lineWidth = 3
      return renderer
    }
    private func configureView() {
      let distance = Measurement(value: trip.distance, unit: UnitLength.meters)
      let duration = Int(trip.duration)
      let averageSpeed = UnitConversions.speed(distance: distance,
                                             time: duration,
                                             outputUnit: UnitSpeed.metersPerSecond)
      
      distanceLbl.text = "Distance:  \(UnitConversions.distance(distance))"
      timeLbl.text = UnitConversions.date(trip.time)
      durationLbl.text = "Time:  \(UnitConversions.time(duration))"
      averageSpeedLbl.text = "Average Speed:  \(averageSpeed)"
      
      loadMap()
    }
    func loadMap (){
        mapView.delegate = self

          guard
            let locations = trip.locations,
            locations.count > 0,
            let region = generateMapRegion()
          else {
              let alert = UIAlertController(title: "Error",
                                            message: "No locations travelled in this trip",
                                            preferredStyle: .alert)
              alert.addAction(UIAlertAction(title: "OK", style: .cancel))
              present(alert, animated: true)
              return
          }
          
        mapView.setRegion(region, animated: true)
        mapView.addOverlay(polyLine())
        }
    private func polyLine() -> MKPolyline {
        
        guard let locations = trip.locations else {
        return MKPolyline()
      }
        let coordinates: [CLLocationCoordinate2D] = locations.sorted(by: { ($0 as! Location).time! < ($1 as! Location).time! }).map { location in
        let location = location as! Location
        return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
      }
      return MKPolyline(coordinates: coordinates, count: coordinates.count)
    }
     

    private func generateMapRegion() -> MKCoordinateRegion? {
      guard
        let locations = trip.locations,
        locations.count > 0 else {return nil}
      
      let latitudes = locations.map { location -> Double in
        let location = location as! Location
        return location.latitude
      }
      
      let longitudes = locations.map { location -> Double in
        let location = location as! Location
        return location.longitude
      }
      
      let latitudeMax = latitudes.max()!
      let latitudeMin = latitudes.min()!
      let longitudeMax = longitudes.max()!
      let longitudeMin = longitudes.min()!
      
      let regionCenter = CLLocationCoordinate2D(latitude: (latitudeMin + latitudeMax) / 2,
                                          longitude: (longitudeMin + longitudeMax) / 2)
      let regionSpan = MKCoordinateSpan(latitudeDelta: (latitudeMax - latitudeMin) * 1.3,
                                  longitudeDelta: (longitudeMax - longitudeMin) * 1.3)
      return MKCoordinateRegion(center: regionCenter, span: regionSpan)
    }
    
    
}
