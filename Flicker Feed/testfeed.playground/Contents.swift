//: Playground - noun: a place where people can play

import UIKit
import Foundation
import PlaygroundSupport


let BASE_URL = "https://api.flickr.com/services/rest/"
let METHOD_NAME:String! = "flickr.photos.search"
let API_KEY:String! = "2b3a1a4981ddb76c976db58942c216cf"
let GALLERY_ID:String! = "5704-72157622566655097"
let EXTRAS:String! = "url_m"
let DATA_FORMAT:String! = "json"
let SAFE_SEARCH:String!="1"
let NO_JSON_CALLBACK:String! = "1"

    //below are arrays that save all the images related to the keyword
    //so that we can show them later when the Next button is pressed
    var photoArray2: AnyObject!=[String: AnyObject]() as AnyObject
    
    var iNamey=[String]()
    var iImage=[String]()
    var iImageUrl=[NSURL]()
    
    var counter=0;
    
    
    weak var mainImg: UIImageView!
    
    
    weak var searchText: UITextField!
    
    weak var searchButton: UIButton!
    
    var search : String = "sky"

    weak var nextButton: UIButton!
    
    
    
    
    weak var titleLabel: UILabel!

PlaygroundPage.current.needsIndefiniteExecution = true

    
    func searchAction() {//
        let word:String! = search
        print(word)
        /* 2 - API method arguments */
        let methodArguments = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "text": search,
            "safe_search": SAFE_SEARCH,
            "extras": EXTRAS,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK
        ]
        if methodArguments.isEmpty {
        }else{
            getImageFromFlickrSearch(methodArguments: methodArguments)//passes API Key and search term to method
        }
        //as! [String : AnyObject])
        
        
    }
    func searchAction(_ sender: Any) {
        let word:String! = searchText.text
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
        }
    }
    
    func geoAction(sender: AnyObject) {
    }

    

    
    func getImageFromFlickrSearch(methodArguments:[String : String?]) {
        print("Appel de la fonction : getImageFromFlickrSearch")
        
        /* 3 - Initialize session and url  - Use NSURLSessions to connect */
        let session = URLSession.shared
        let urlString = BASE_URL + escapedParameters(parameters: methodArguments)
//        let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&api_key=2b3a1a4981ddb76c976db58942c216cf&per_page=10&format=json&nojsoncallback=1"
//        let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&tags=sky&extras=url_m&api_key=2b3a1a4981ddb76c976db58942c216cf&per_page=10&format=json&nojsoncallback=1"

        print(urlString)
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        /* 4 - Initialize task for getting data  - initialize task*/
        //        let task = session.dataTask(request) {data, response, downloadError in
//        let task = session.dataTask(with: url, completionHandler: { (data, response, downloadError) in
        let task = session.dataTask(with: request) { (data, response, downloadError) -> Void in
            if let error = downloadError {
                print("Could not complete the request \(error)")
            } else {
                /* 5 - Success! Parse the data */
                print("Downloaded, now : parser")
               
                let parsedResult: AnyObject!
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
                    
//                    parsedResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
                } catch let error as NSError {
                   _ = error
                    print("error")
                    print(error.localizedFailureReason!)
                    parsedResult = nil
                } catch {
                    fatalError()
                }
                
               
                if let photosDictionary = parsedResult.value(forKey: "photos") as? NSDictionary {
                    print (photosDictionary)
                    if let photoArray = photosDictionary.value(forKey: "photo") as? [[String: AnyObject]] {
                        
                        
                        for index in 0..<photoArray.count {
                            let photoDictionary = photoArray[index] as [String: AnyObject]
                           
                            let photoTitle = photoDictionary["title"] as? String
                            
                            let imageUrlString = photoDictionary["url_m"] as? String
                            if(imageUrlString==nil){
                            }else{
                                let imageURL = NSURL(string: imageUrlString!)
                                /* 7 - Save info to arrays  */
                                iNamey.append(photoTitle!)
                                iImage.append(imageUrlString!)
                                iImageUrl.append(imageURL!)
                            }
                            
                            
                        }
                        /* 6 - Grab a single, random image */
                        let randomPhotoIndex = Int(arc4random_uniform(UInt32(iNamey.count)))
                        
                        
                        let photoDictionary = photoArray[randomPhotoIndex] as [String: AnyObject]
                        print (photoDictionary)
                        /* 7 - Get the image url and title of random image */
                        let photoTitle = photoDictionary["title"] as? String
                        let imageUrlString = photoDictionary["url_m"] as? String
                        let imageURL = NSURL(string: imageUrlString!)
                        print(photoTitle!)
                        
                        /* 8 - If an image exists at the url, set the image and title to storyboard*/
                        //                        if let imageData = NSData(contentsOfURL: imageURL! as URL) {
                        if let imageData = NSData(contentsOf: imageURL! as URL){
                            DispatchQueue.main.async(execute: {
                                mainImg.image = UIImage(data: imageData as Data)
                                titleLabel.text = photoTitle
                            })
                        } else {
                            print("Image does not exist at \(String(describing: imageURL))")
                        }
                    } else {
                        print("Cant find key 'photo' in \(photosDictionary)")
                    }
                } else {
                    print("Cant find key 'photos' in \(parsedResult)")
                }
            }
        }
        
        /* 9 - Resume (execute) the task */
        print("resuming task")
        task.resume()
        print("Task resumed")
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    func escapedParameters(parameters: [String : String?]) -> String! {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = String(value!)
            print (stringValue!)
            /* Escape it */
//            //            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(stringValue ?? "")"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
    }
    
    
    
    
    func NextImg(_ sender: Any) {
        nextPerson()
    }
    
    
    
    func nextPerson(){
        
        
        /* 8 - If an image exists at the url, set the image and title */
        //        if let imageData = NSData(contentsOfURL: iImageUrl[counter] as URL) {
        if let imageData = NSData(contentsOf: iImageUrl[counter] as URL) {
            DispatchQueue.main.async(execute: {
                mainImg.image = UIImage(data: imageData as Data)
                titleLabel.text = iNamey[counter]
                counter += 1
                if(counter==iNamey.count){
                    counter=0;
                }
            })
        } else {
            print("Image does not exist at \(iImageUrl[0])")
        }    }//end of method
    
    



    searchAction()
    


