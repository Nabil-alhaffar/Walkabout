//
//  SavedTripsDetailViewController.swift
//  Walkabout
//
//  Created by Nabil Haffar on 10/21/19.
//  Copyright © 2019 Nabil Haffar. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit


class SavedTripsDetailViewController : UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate {
    private var trip:Trip!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var averageSpeedLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self

     //   configureView()
    }
    var detailItem: Trip? {
        didSet {
            
            // Update the view.
            trip = detailItem
            self.loadView()
            mapView.delegate = self

            configureView()
        }
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      guard let polyline = overlay as? MKPolyline else {
        return MKOverlayRenderer(overlay: overlay)
      }
      let renderer = MKPolylineRenderer(polyline: polyline)
    renderer.strokeColor = .blue
      renderer.lineWidth = 3
      return renderer
    }
    
    private func configureView() {
      print ("Configuring View")
        if let trip = detailItem{
            print("detail set")
            
        let distance = Measurement(value: trip.distance, unit: UnitLength.meters)
      let duration = Int(trip.duration)
            let averageSpeed = UnitConversions.speed(distance: distance ,time: duration,outputUnit: UnitSpeed.metersPerSecond)
        
            if let label = distanceLbl{
                label.text = "Distance:  \(UnitConversions.distance(distance))"
            }
            if let label = dateLbl{
                label.text = UnitConversions.date(trip.time)
                
            }
            if let label = durationLbl{
                label.text = "Time:  \(UnitConversions.time(duration))"
            }
            if let label = averageSpeedLbl{
                label.text = "Average Speed:  \(averageSpeed)"
            }
      loadMap()
            print ("Done loading detail")
        }
    }
    func loadMap (){
    
      guard let locations = trip.locations,locations.count > 0,
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
