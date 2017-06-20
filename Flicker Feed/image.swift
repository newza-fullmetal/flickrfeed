//
//  image.swift
//  Flicker Feed
//
//  Created by Swish Live  on 19/06/2017.
//  Copyright © 2017 Swish Live. All rights reserved.
//

import Foundation

class Image : CustomStringConvertible{
    
    let ID : Int
    let Title : String
    let Size : String = ""
    let Tags : [String]? = nil
    let url : URL

    init(id : Int, title : String, url : String){
        self.ID = id
        self.Title = title
        self.url = URL(string: url)!
        
    }
    
    public var description: String { return "ID :\(self.ID) \n Title :\(self.Title) \n Size :\(self.Size) \n Url : \(self.url)"}
}
