//
//  ViewController.swift
//  VirtualTorist
//
//  Created by Siva Ganesh on 27/11/15.
//  Copyright © 2015 Siva Ganesh. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData


class ViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        getLocations()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBOutlet var longPressRecogniser: UILongPressGestureRecognizer!
    
    // Add New PIN
    @IBAction func handleLongPressAction(sender: UILongPressGestureRecognizer) {
        
        print("Adding new pin")
        
        let getstureRecognizer = sender as UILongPressGestureRecognizer
        if getstureRecognizer.state != .Began { return }
        let touchPoint = getstureRecognizer.locationInView(self.mapView)
        let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)

        let annotation = MKPointAnnotation()
        annotation.coordinate = touchMapCoordinate
        
        let newLocation = saveNewLocation(touchMapCoordinate.latitude, longitude: touchMapCoordinate.longitude)
        addLocationToMap(newLocation)
        // mapView.addAnnotation(newLocation)
        
    }
    
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        let place = view.annotation as! Place
        let singlePlaceVC = self.storyboard?.instantiateViewControllerWithIdentifier("SinglePlaceViewController") as! SinglePlaceViewController
        singlePlaceVC.place = place
        self.navigationController?.pushViewController(singlePlaceVC, animated: true)
        
    }
   
    
    // Helper Functions
    
    func getLocations(){
       
        let locations = getLocationsFromCoreData()
        
        for location in locations {
            addLocationToMap(location)
        }
    }
    
    
    func getLocationsFromCoreData() -> [Place] {
        var error: NSError?
        let fetchRequest = NSFetchRequest(entityName: "Place")
        let locations: [AnyObject]?
        
        do {
            locations = try sharedContext.executeFetchRequest(fetchRequest)
        } catch let CDError as NSError {
            error = CDError
            locations = nil
        }
        
        if let errorMsg = error {
            let alertController = UIAlertController(title: "Error", message:
                errorMsg.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        return locations as! [Place]
    }
    
    
    
    func addLocationToMap(location: Place) {
        dispatch_async(dispatch_get_main_queue(), {
            self.mapView.addAnnotation(location)
        })
    }
    
    
    func saveNewLocation(latitude : Double, longitude : Double) -> Place{
        
        let locDict = ["latitude" : latitude, "longitude" : longitude]
        let newLocation = Place(dictionary: locDict, context: sharedContext)
        
        print(newLocation)
        
        do{
            try sharedContext.save()
        }catch{
            print(error)
        }
        
        return newLocation
        
        
    }
    
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2000.0, regionRadius * 2000.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }


}

