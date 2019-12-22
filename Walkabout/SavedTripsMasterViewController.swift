//
//  SavedTripsMasterViewController.swift
//  Walkabout
//
//  Created by Nabil Haffar on 10/21/19.
//  Copyright © 2019 Nabil Haffar. All rights reserved.
//
import UIKit
import Foundation
import CoreData

class SavedTripsMasterViewController: UITableViewController, NSFetchedResultsControllerDelegate{
    
    private var trips = [Trip]()
    var detailViewController : SavedTripsDetailViewController? = nil
    var objects = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let split = splitViewController {
                   let controllers = split.viewControllers
                   detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? SavedTripsDetailViewController
            split.preferredDisplayMode = .allVisible
        }
        let fetchRequest:NSFetchRequest<Trip> = Trip.fetchRequest()
        do{
            let searchResults = try DatabaseController.getContext().fetch(fetchRequest)
            print ("Number of results: \(searchResults.count) ")
            
            
                
            self.trips = searchResults
            DispatchQueue.main.async {
            self.tableView.reloadData()

            }
        }
        catch{
            print ("Error")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
       self.tableView.reloadData()
        
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("segue1")
        if segue.identifier == "showSavedTripsDetail" {
            if let indexPath = tableView.indexPathForSelectedRow{
                let trip = trips[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! SavedTripsDetailViewController
            
                controller.detailItem = trip
                print ("segue2")
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }

            
        }
    
}
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                       guard let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell") as? TripCell
                     else {
                          print ("error creating cell")
                         return UITableViewCell()
                         
                     }
        cell.dateLbl.text = UnitConversions.date(trips[indexPath.row].time!)
        cell.durationLbl.text = UnitConversions.time( Int(trips[indexPath.row].duration))
        cell.distanceLbl.text = UnitConversions .distance( trips[indexPath.row].distance)
                     return cell
              }
    
       override func numberOfSections(in tableView: UITableView) -> Int {
              return 1
          }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

           if editingStyle == .delete {
               let trip = trips[indexPath.row]
               trips.remove(at: indexPath.row)
                  tableView.deleteRows(at: [indexPath], with: .fade)
               let context:NSManagedObjectContext = DatabaseController.getContext()
               context.delete(trip as NSManagedObject)
               
               DatabaseController.saveContext()
              } else if editingStyle == .insert {
                  // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
              }
          }
}
