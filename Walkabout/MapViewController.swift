//
//  FirstViewController.swift
//  Walkabout
//
//  Created by Nabil Haffar on 10/20/19.
//  Copyright © 2019 Nabil Haffar. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    private var trip: Trip?
    private var timer: Timer?

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var startTrackingBtn: UIButton!
    @IBOutlet weak var stopTrackingBtn: UIButton!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var averageSpeedLbl: UILabel!
    @IBOutlet weak var labelsStackView: UIStackView!
    

    private let locationManager = LocationManager.shared
     private var durationInSeconds = 0
     private var distance = Measurement(value: 0, unit: UnitLength.meters)
     private var locationList: [CLLocation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    //    labelsStackView.isHidden = true
        stopTrackingBtn.isHidden = true
        // Do any additional setup after loading the view.
        checkLocationAuthorizationStatus()
        mapView.delegate = self

    }
    
    @IBAction func startTrackingBtnHandler(_ sender: Any) {
        initiateTrip()
    }
    
    @IBAction func stopTrackingBtnEventHandler(_ sender: Any) {
        let actionSheet = UIAlertController(title: "End trip?",
                                                message: "Are you sure you would like to abort your trip",
                                                preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Save", style: .default) { _ in
                 self.endTrip()
                 self.saveTripToDatabase()
                 self.performSegue(withIdentifier: "showTripInfo", sender: nil)
               })
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        actionSheet.addAction(UIAlertAction(title: "Discard", style: .destructive) { _ in
          self.endTrip()
          _ = self.navigationController?.popToRootViewController(animated: true)
        })
        actionSheet.popoverPresentationController?.sourceView = self.view
               actionSheet.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
               actionSheet.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        present(actionSheet, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTripInfo"{
      
        let destination = segue.destination as! TripInfoViewController
            destination.trip = trip
        }
    }
    
    private func updateView() {
      let averageSpeed = UnitConversions.speed(distance: distance,
                                        time: durationInSeconds,
                                        outputUnit: UnitSpeed.metersPerSecond)
      
      distanceLbl.text = "Distance:  \(UnitConversions.distance(distance))"
      durationLbl.text = "Time:  \(UnitConversions.time(durationInSeconds))"
      averageSpeedLbl.text = "Speed:  \(averageSpeed)"
    }
    
    func initiateTrip (){
        startTrackingBtn.isHidden = true
        stopTrackingBtn.isHidden = false
        labelsStackView.isHidden = false
        durationInSeconds = 0
        distance = Measurement(value: 0, unit: UnitLength.meters)
        mapView.removeOverlays(mapView.overlays)
        locationList.removeAll()
        updateView()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.durationInSeconds += 1
            self.updateView()
        }
        startLocationUpdates()
        
    }
    private func startLocationUpdates() {
       locationManager.delegate = self
       locationManager.activityType = .fitness
       locationManager.distanceFilter = 10
       locationManager.startUpdatingLocation()
     }
    func  endTrip()  {
           
        locationManager.stopUpdatingLocation()
        startTrackingBtn.isHidden = false
        stopTrackingBtn.isHidden = true;
        labelsStackView.isHidden = true;
    }
    
    func checkLocationAuthorizationStatus() {
      if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
        mapView.showsUserLocation = true
      } else {
        locationManager.requestWhenInUseAuthorization()
      }
        
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      guard let polyline = overlay as? MKPolyline else {
        return MKOverlayRenderer(overlay: overlay)
      }
      let polyLineRenderer = MKPolylineRenderer(polyline: polyline)
        polyLineRenderer.strokeColor = .blue
      polyLineRenderer.lineWidth = 3
      return polyLineRenderer
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      for newLocation in locations {
        let timeDif = newLocation.timestamp.timeIntervalSinceNow
        guard newLocation.horizontalAccuracy < 20 && abs(timeDif) < 10 else { continue }
        
        if let lastLocation = locationList.last {
          let distanceDif = newLocation.distance(from: lastLocation)
          distance = distance + Measurement(value: distanceDif, unit: UnitLength.meters)
          let coordinates = [lastLocation.coordinate, newLocation.coordinate]
            mapView.addOverlay(MKPolyline(coordinates: coordinates, count: 2))
            let myRegion = MKCoordinateRegion(center: newLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
          mapView.setRegion(myRegion, animated: true)
        }

        locationList.append(newLocation)
      }
    }
    
    func saveTripToDatabase () {
        
        let newTrip = Trip(context: DatabaseController.persistentContainer.viewContext)
          newTrip.distance = distance.value
          newTrip.duration = Int16(durationInSeconds)
          newTrip.time = Date()
          
          for location in locationList {
            let locationObject = Location(context: DatabaseController.persistentContainer.viewContext)
            locationObject.time = location.timestamp
            locationObject.latitude = location.coordinate.latitude
            locationObject.longitude = location.coordinate.longitude
            newTrip.addToLocations(locationObject)
          }
          trip = newTrip
          DatabaseController.saveContext()
          
        }



}

