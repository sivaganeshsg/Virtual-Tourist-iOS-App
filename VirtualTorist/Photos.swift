//
//  Photo.swift
//  VirtualTorist
//
//  Created by Siva Ganesh on 30/11/15.
//  Copyright © 2015 Siva Ganesh. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class Photos : NSManagedObject {
    
    struct Keys {
        static let imagePath = "imagePath"
    }
    
    @NSManaged var imagePath: String
    @NSManaged var place: Place?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(imagePath: String, context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Photos", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.imagePath = imagePath
        
    }
    
    var posterImage: UIImage? {
        
        get {
            return FlickrFunctions.Caches.imageCache.imageWithIdentifier(imagePath)
        }
        
        set {
            FlickrFunctions.Caches.imageCache.storeImage(newValue, withIdentifier: imagePath)
        }
    }
    
    
    override func prepareForDeletion() {
        super.prepareForDeletion()
        posterImage = nil
    }
}