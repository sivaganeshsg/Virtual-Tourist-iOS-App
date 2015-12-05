//
//  SinglePlaceViewController.swift
//  VirtualTorist
//
//  Created by Siva Ganesh on 27/11/15.
//  Copyright © 2015 Siva Ganesh. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class SinglePlaceViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {

    var latitude = 0.0
    var longitude = 0.0
    
    var place : Place!
    
    
    var selectedIndexes = [NSIndexPath]()
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    
    
    @IBOutlet weak var miniMapView: MKMapView!
    
    @IBOutlet weak var photoAlbumCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.photoAlbumCollectionView.delegate = self
        
        latitude = place.latitude
        longitude = place.longitude
        
        let initialLocation = CLLocation(latitude: latitude, longitude: longitude)
        centerMapOnLocation(initialLocation)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        // Step 6: Set the delegate to this view controller
        self.fetchedResultsController.delegate = self
        
        if place.photos!.isEmpty {
            getNewImages(place)
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Core Data Convenience.
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    
    // Step 1 - Add the lazy fetchedResultsController property. See the reference sheet in the lesson if you
    // want additional help creating this property.
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photos")
        print(self.place)
        fetchRequest.predicate = NSPredicate(format: "place == %@", self.place)
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        return fetchedResultsController
        
        /*
        let fetchRequest = NSFetchRequest(entityName: "Photos")
        // fetchRequest.sortDescriptors = []
        // fetchRequest.predicate = NSPredicate(format: "%K == %@", "place", self.place)
        // NSPredicate(format: "place == %@", self.place)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "imagePath", ascending: true)]
        
        print(self.latitude)
        // print(self.place.photos)
        // print(NSPredicate(format: "Place == %@", self.place))
        
        //let predicate = NSPredicate(format: "place == %@", self.place)
        // fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin)
        // NSPredicate(format: "latitude == %@ AND longitude == %i", self.latitude, self.longitude)
        // let predicate = NSPredicate(format: "%K == %@", "latitude", self.latitude) // , "longitude", 80.2185632109692
        // let sortDescriptor = [] // NSSortDescriptor(key: "latitude", ascending:true)
        // fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext!,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        print(fetchedResultsController)
        
        return fetchedResultsController
        */
        
    }()
    
    
    
    @IBAction func deletedSelectedPhoto(sender: AnyObject) {
        
        if(selectedIndexes.count > 0){
        
            var photosToDelete = [Photos]()
            for indexPath in selectedIndexes {
                photosToDelete.append(fetchedResultsController.objectAtIndexPath(indexPath) as! Photos)
            }
            for photo in photosToDelete {
                sharedContext.deleteObject(photo)
            }
            CoreDataStackManager.sharedInstance().saveContext()
        
            selectedIndexes = [NSIndexPath]()
        
        }else{
            
            let alertController = UIAlertController(title: "Error", message:
                "Please select atleast one image", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        
        }
    }
    
   
    func getNewImages(place : Place){
        
        FlickrFunctions.getFlickrImages(place.latitude, long: place.longitude) { (success, errorMessage) -> Void in
            
            let photoArr = FlickrFunctions.photosArray
            
            for eachPhoto in photoArr{
                let photoResult = Photos(imagePath: eachPhoto, context: self.sharedContext)
                photoResult.place = self.place
                
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                CoreDataStackManager.sharedInstance().saveContext()
            }
            
        }
        
    }

    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        if let sectionInfo = self.fetchedResultsController.sections?.count {
            return sectionInfo
        }else{
            return 1
        }
        
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0

    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let reuseIdentifier = "photosCollectionCell"
        
        print("collection view")
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoAlbumCollectionViewCell
        // cell.urlLabel.text = "Loading"
        
        let photos = fetchedResultsController.objectAtIndexPath(indexPath)  as! Photos
        configureCell(cell, photo: photos)
        
        return cell
    }
    
    
    func configureCell(cell: PhotoAlbumCollectionViewCell, photo: Photos) {
        
        // For testing
        cell.urlLabel.text = photo.imagePath
        
        
        if photo.posterImage != nil {
            cell.albumImage!.image = photo.posterImage
        }
        else {
            
            cell.albumImage!.image = UIImage(contentsOfFile: "placeholder")
            cell.imageLoadingIndicator.startAnimating()
            
            FlickrFunctions.taskForImage(photo.imagePath) { data, error in
                
                if let error = error {
                    print("Photo download error: \(error.localizedDescription)")
                }
                
                if let data = data {
                    
                    let image = UIImage(data: data)
                    photo.posterImage = image
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.imageLoadingIndicator.stopAnimating()
                        cell.albumImage!.image = image
                    }
                }
            }
            
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoAlbumCollectionViewCell
        
        
        if let index = selectedIndexes.indexOf(indexPath) {
            selectedIndexes.removeAtIndex(index)
            cell.albumImage.alpha = 1.0
        } else {
            selectedIndexes.append(indexPath)
            cell.albumImage.alpha = 0.5
        }
        
        
    }
    
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        selectedIndexes = [NSIndexPath]()
    }
    
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        photoAlbumCollectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.photoAlbumCollectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.photoAlbumCollectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            CoreDataStackManager.sharedInstance().saveContext()
            
            }, completion: nil)
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type{
            
        case .Insert:
            print("While Inserting")
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            print("Delete the selected item")
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            print("No need to Update")
            break
        case .Move:
            print("No need to Move.")
            break
        default:
            print("default action")
            break
        }
        
    }
    
    
    let regionRadius: CLLocationDistance = 100
    func centerMapOnLocation(location: CLLocation) {
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 100.0, regionRadius * 100.0)
        miniMapView.setRegion(coordinateRegion, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        miniMapView.addAnnotation(annotation)
    }
    

    @IBAction func newCollectionBtnPressed(sender: AnyObject) {

        print("new collection")
        FlickrFunctions.photosArray = []
        if let fetchedObjectsToDelete = fetchedResultsController.fetchedObjects {
            for deleteObject in fetchedObjectsToDelete {
                let photo = deleteObject as! Photos
                sharedContext.deleteObject(photo)
            }
            CoreDataStackManager.sharedInstance().saveContext()
        }
        getNewImages(place)
        
    }
   

}
