//
//  Country.swift
//  plist3
//
//  Created by Colin Mackenzie on 15/10/2016.
//  Copyright © 2016 cdmackenzie. All rights reserved.
//

import UIKit
import MapKit

class Country: NSObject, MKAnnotation {
    
    var title:        String?   // landCapital
    var coordinate:   CLLocationCoordinate2D
    var info:         String
    var landCode:     String
    var landName:     String
    var flagFileName: String
    
    init(title: String, coordinate: CLLocationCoordinate2D, info: String, landCode: String, landName: String, flagFileName: String) {
        self.title        = title
        self.coordinate   = coordinate
        self.info         = info
        self.landCode     = landCode
        self.landName     = landName
        self.flagFileName = flagFileName
        
        super.init()
    }
    
}
