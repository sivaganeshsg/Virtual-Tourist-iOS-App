//
//  TableViewController.swift
//  VirtualTorist
//
//  Created by Siva Ganesh on 04/12/15.
//  Copyright © 2015 Siva Ganesh. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var place : Place!
    
    var selectedIndexes = [NSIndexPath]()
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // print(self.place)

        // Step 2: invoke fetchedResultsController.performFetch(nil) here
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        // Step 6: Set the delegate to this view controller
        self.fetchedResultsController.delegate = self
        
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    
    // Step 1 - Add the lazy fetchedResultsController property. See the reference sheet in the lesson if you
    // want additional help creating this property.
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photos")
        fetchRequest.sortDescriptors = []
        
        //print(self.place)
        // fetchRequest.predicate = NSPredicate(format: "place == %@", self.place)
        
        // print(self.latitude)
        // print(self.place)
        
        //let predicate = NSPredicate(format: "place == %@", self.place)
        // fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin)
        // NSPredicate(format: "latitude == %@ AND longitude == %i", self.latitude, self.longitude)
        // let predicate = NSPredicate(format: "%K == %@", "latitude", self.latitude) // , "longitude", 80.2185632109692
        // let sortDescriptor = [] // NSSortDescriptor(key: "latitude", ascending:true)
        // fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        if let sections = fetchedResultsController.sections {
            print("dec sec \(sections)")
            let section = fetchedResultsController.sections!.count
            let sectionInfo = sections[section]
            print("dec items \(sectionInfo.numberOfObjects)")
            // return sectionInfo.numberOfObjects
            
        }
        
        print(fetchedResultsController)
        
        return fetchedResultsController
        
    }()
    
    
    
    
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        if let sectionInfo = self.fetchedResultsController.sections?.count {
            print("sect \(sectionInfo)")
            return sectionInfo
        }else{
            print("sect 1")
            return 1
            
        }
        
        // return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            print("items \(sectionInfo.numberOfObjects)")
            return sectionInfo.numberOfObjects
            
        }
        print("items 0")
        return 1
        // return 2
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("contentCell", forIndexPath: indexPath) as! TableViewCell
        cell.customLabel.text = "111"
        
        configureCell(cell, atIndexPath: indexPath)
        
        // let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        // self.configureCell(cell, photo: photo)
        
        return cell

        
//        let cell = tableView.dequeueReusableCellWithIdentifier("contentCell", forIndexPath: indexPath) as! TableViewCell
//        // cell.customLabel.t = "222"
//        
//        cell.customLabel.text = "2222"
//        // cell.customLabel.t
//
//        // Configure the cell...
//
//        return cell
    
    
    }
    
    
    
    func configureCell(cell: TableViewCell, atIndexPath indexPath: NSIndexPath){
        
        let record = fetchedResultsController.objectAtIndexPath(indexPath)
        
        if let name = record.valueForKey("imagePath") as? String {
            cell.customLabel.text = name
        }
        
        print("configure cell")
        
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
