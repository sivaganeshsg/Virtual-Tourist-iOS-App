//
//  FlickrFunctions.swift
//  VirtualTorist
//
//  Created by Siva Ganesh on 29/11/15.
//  Copyright © 2015 Siva Ganesh. All rights reserved.
//

import Foundation

class FlickrFunctions : NSObject {

    static var session = NSURLSession.sharedSession()
    
    static var user_id = ""
    static var session_id = ""
    static var firstName = ""
    static var lastName = ""
    
    static let flickrAPIUrl = "https://api.flickr.com/services/rest/"

    static let apiKey = "21c3733ca7ac33821bdd6010c763eecb"
    static let apiSecret = "a20dd0d422d7a66c"
//    static let urlMethod = "flickr.photos.search"
//    static let extraParam = "url_m"
//    static let dataFormat = "json"
//    static let jsonCallback = "1"
    
    
    static var photosArray = [String]()
    
    
    static func getFlickrImages(lat : Double, long: Double, didComplete: (success: Bool, errorMessage: String?) -> Void){
        
        print("in")
        
        let methodArguments = [
            "method": "flickr.photos.search",
            "api_key": apiKey,
            "lat" : lat,
            "lon" : long,
            "accuracy" : "11",
            "extras": "url_m",
            "format": "json",
            "nojsoncallback": "1",
            "per_page" : "15"
            
        ]
        

        let urlString = flickrAPIUrl + FlickrFunctions.escapedParameters(methodArguments as! [String : AnyObject])
        
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if let error = downloadError {
                print("Could not complete the request \(error)")
                didComplete(success: false, errorMessage: "The Internet connection appears to be offline.")
                return
                
            } else {
                
                FlickrFunctions.photosArray = []
                let success = FlickrFunctions.parseUserData(data!)
                var errorMessage = ""
                if(!success){
                    errorMessage = "Invalid account details"
                }
                didComplete(success: success, errorMessage: errorMessage)
            }
        }
        
        task.resume()
        
        
        
    }
    
    static func parseUserData(data: NSData) -> Bool {
        var success = true;
        if  let flickrData = (try? NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)) as? NSDictionary{
        
            print(flickrData)
            
            let flickrPhotosInfo = flickrData.valueForKey("photos") as! NSDictionary
            let flickrPhotosArr = flickrPhotosInfo.valueForKey("photo") as! [[String : AnyObject]]
            
            for imageData in flickrPhotosArr{
                let imageUrl = imageData["url_m"] as! String
                FlickrFunctions.photosArray.append(imageUrl)
            }
            
            print(FlickrFunctions.photosArray)
            
        } else {
            success = false
        }
        return success;
    }
    
    
    
    // MARK: - All purpose task method for images
    
    static func taskForImage(urlString: String, completionHandler: (imageData: NSData?, error: NSError?) ->  Void) -> NSURLSessionTask {
        
        let url = NSURL(string: urlString)
        
        print(url)
        
        let request = NSURLRequest(URL: url!)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                let newError = NSError(domain: error.localizedDescription, code: 1, userInfo: nil)
                completionHandler(imageData: nil, error: newError)
            } else {
                completionHandler(imageData: data, error: nil)
            }
        }
        
        task.resume()
        
        return task
    }

    
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    static func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    
    struct Caches {
        static let imageCache = ImageCache()
    }

    
    /*
    
    static func loginUser(username : String, password: String, didComplete: (success: Bool, errorMessage: String?) -> Void){
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let details = ["username" : username,"password" : password]
        let jsonBody = ["udacity" : details]
        
        var jsonifyError: NSError? = nil
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: [])
        } catch let error as NSError {
            jsonifyError = error
            request.HTTPBody = nil
        }
        
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if let error = downloadError {
                print("Could not complete the request \(error)")
                didComplete(success: false, errorMessage: "The Internet connection appears to be offline.")
                return
                
            } else {
                
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
                let success = FlickrFunctions.parseUserData(newData)
                var errorMessage = ""
                if(!success){
                    errorMessage = "Invalid account details"
                }
                didComplete(success: success, errorMessage: errorMessage)
            }
        }
        
        task.resume()
        
        
        
    }
    
    static func parseUserData(data: NSData) -> Bool {
        var success = true;
        if  let userData = (try? NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)) as? NSDictionary,
            let account = userData["account"] as? [String: AnyObject],
            let session = userData["session"] as? [String: String]
        {
            user_id = account["key"] as! String
            session_id = session["id"]!
        } else {
            success = false
        }
        return success;
    }


    */


}