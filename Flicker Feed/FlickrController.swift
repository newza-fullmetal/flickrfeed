//
//  FlickrController.swift
//  Flicker Feed
//
//  Created by Swish Live  on 20/06/2017.
//  Copyright © 2017 Swish Live. All rights reserved.
//

import Foundation

class FlickrController {
    
    /**
    *
    */
    private(set) var imgreceived = [Image]()
    
    let BASE_URL = "https://api.flickr.com/services/rest/"
    let METHOD_NAME:String! = "flickr.photos.search"
    let API_KEY:String! = "2b3a1a4981ddb76c976db58942c216cf"
    let GALLERY_ID:String! = "5704-72157622566655097"
    let EXTRAS:String! = "url_m"
    let DATA_FORMAT:String! = "json"
    let SAFE_SEARCH:String!="1"
    let NO_JSON_CALLBACK:String! = "1"
    
    public func searchAction(tag : String) -> Image? {//
        self.imgreceived.removeAll() //if new research we delete the old one
        let word:String! = tag
        print(word)
        /* 2 - API method arguments */
        let methodArguments = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "text": word,
            "safe_search": SAFE_SEARCH,
            "extras": EXTRAS,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK
        ]
        if methodArguments.isEmpty {
        }else{
            getImageFromFlickrSearch(methodArguments: methodArguments)//passes API Key and search term to method
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                // Put your code which should be executed with a delay here
            })
            print (self.imgreceived.count)
        }
        //as! [String : AnyObject])
        return selectrandomimage()
        
    }

    private func getImageFromFlickrSearch(methodArguments:[String : String?]) {
        
        
        /* 3 - Initialize session and url  - Use NSURLSessions to connect */
        let session = URLSession.shared
        let urlString = BASE_URL + escapedParameters(parameters: methodArguments)
        print (urlString)   
        
        //        let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&tags=sky&extras=url_m&api_key=2b3a1a4981ddb76c976db58942c216cf&per_page=10&format=json&nojsoncallback=1"
        let url = URL(string: urlString)
   
        let request = URLRequest(url: url!)
        
        /* 4 - Initialize task for getting data  - initialize task*/
        //        let task = session.dataTask(request) {data, response, downloadError in
        let semaphore = DispatchSemaphore(value: 0)
        let task = session.dataTask(with: request) { (data, response, downloadError) -> Void in
            
            if let error = downloadError {
                print("Could not complete the request \(error)")
            } else {
                /* 5 - Success! Parse the data */
                
                let parsedResult: AnyObject!
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
                } catch let error as NSError {
                    _ = error
                    print(error.localizedFailureReason!)
                    parsedResult = nil
                } catch {
                    fatalError()
                }
                
                if let photosDictionary = parsedResult.value(forKey: "photos") as? NSDictionary {
                    if let photoArray = photosDictionary.value(forKey: "photo") as? [[String: AnyObject]] {
                        
                        
                        for index in 0..<photoArray.count {
                            let photoDictionary = photoArray[index] as [String: AnyObject]
                            
                            
                            let photoTitle = photoDictionary["title"] as? String
                            let imageUrlString = photoDictionary["url_m"] as? String
                            if(imageUrlString==nil){
                            }else{
                                let img : Image = Image(id: self.imgreceived.count, title: photoTitle!, url: imageUrlString!)
//                                print(img)
                                self.imgreceived.append(img)
//                                print(self.imgreceived.count)
                            }
                            
                            
                            
                            
                        }
                        semaphore.signal()
                        
                        print(self.imgreceived.count)
                        
                    } else {
                        print("Cant find key 'photo' in \(photosDictionary)")
                    }
                } else {
                    print("Cant find key 'photos' in \(parsedResult)")
                }
            }
            
        }
        
        /* 9 - Resume (execute) the task */
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        print(self.imgreceived.count)
        print("Function GetImage terminated")
    }

    private func selectrandomimage() -> Image? {
        print("Function : selectrandomimage")
        if self.imgreceived.count > 0 {
            
            let randomPhotoIndex = Int(arc4random_uniform(UInt32(self.imgreceived.count)))
            print ("image returned :")
            print (self.imgreceived[randomPhotoIndex])
            return self.imgreceived[randomPhotoIndex]
           
        }
        else { //if no image in the array
            print ("return nil")
            return nil
        }
        
    }
    private func escapedParameters(parameters: [String : String?]) -> String! {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = String(value!)
  
            /* Escape it */
            let escapedValue = stringValue!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
        
    }
    
    public func nextImage(actualImg : Image) -> Image{
        print("Function : nextImage")
        
        let cursor : Int = actualImg.ID + 1
        if self.imgreceived.count == cursor{
            print ("image returned :")
            print (self.imgreceived[0])
            return self.imgreceived[0]
        }else{
            print ("image returned :")
            print (self.imgreceived[cursor+1])
            return self.imgreceived[cursor+1]
        }
        
        
    }//end of method
    
    
    
    
}
