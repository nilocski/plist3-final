//
//  ViewController.swift
//  plist3
//
//  Created by Colin Mackenzie on 16/10/2016.
//  Copyright © 2016 cdmackenzie. All rights reserved.
//

import UIKit
import MapKit
import GameplayKit

class ViewController: UIViewController, MKMapViewDelegate
{
    let mapView                 = MKMapView()
    
    var mainStackView           = UIStackView()
    var countryNameLabel        = UILabel()
    var countryCapitalLabel     = UILabel()
    var countryFlagButton       = UIButton(type: .roundedRect)
    
    // plist file name
    let plistFileName           = "countrydata"
    let fileType                = "plist"
    
    // Dictionary names
    let countryCodeID           = "landCode"
    let countryNameID           = "landName"
    let countryCapitalID        = "landCapital"
    let countryFlagID           = "landFlagImage"
    let countryCapLatID         = "landCapLat"
    let countryCapLonID         = "landCapLon"
    
    var plistArray              = [Dictionary<String, String>]()
    
    var countryNumber           = 0
    var countryDict: Dictionary<String, String>!
    
    var currentCountry: Country? = nil
    
    let regionRadius: CLLocationDistance = 200000
    
    let annotationIdentifier    = "Country"
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        mapView.delegate = self
        
        setupStackView()
        
        readpList()
        
        chooseRandomCountry()
        
        updateUI()
        
    }
    
    func setupStackView()
    {
        /*
         Set up StackViews containing
         1. Label   with country name
         2. Label   with country capital
         3. Button  with country flag
         4. MapView with capital position.
         */
        countryNameLabel.backgroundColor = UIColor.lightGray
        countryNameLabel.textColor       = UIColor.black
        countryNameLabel.textAlignment   = .center
        countryNameLabel.text            = "UK"
        countryNameLabel.font            = UIFont.preferredFont(forTextStyle: .title1)
        countryNameLabel.numberOfLines   = 1
        countryNameLabel.frame           = CGRect(x: 0, y: 0, width: 120, height: 60)
        
        countryCapitalLabel.backgroundColor = UIColor.lightGray
        countryCapitalLabel.textColor       = UIColor.black
        countryCapitalLabel.textAlignment   = .center
        countryCapitalLabel.text            = "London"
        countryCapitalLabel.font            = UIFont.preferredFont(forTextStyle: .title1)
        countryCapitalLabel.numberOfLines   = 1
        countryCapitalLabel.frame           = CGRect(x: 0, y: 0, width: 120, height: 60)
        
        let image = UIImage(named: "uk.png")
        countryFlagButton.setBackgroundImage(image, for: .normal)
        countryFlagButton.addTarget(self, action: #selector(flagTapped), for: .touchUpInside)
        countryFlagButton.frame = CGRect(x: 10, y: 0, width: 120, height: 60)
        
        let labelStackView = UIStackView()
        labelStackView.axis = .vertical
        labelStackView.alignment = .center
        labelStackView.distribution = .fill
        labelStackView.spacing  = 1
        labelStackView.addArrangedSubview(countryNameLabel)
        labelStackView.addArrangedSubview(countryCapitalLabel)
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let flagStackView = UIStackView()
        flagStackView.axis         = .horizontal
        flagStackView.alignment    = .center
        flagStackView.distribution = .equalSpacing
        flagStackView.addArrangedSubview(countryFlagButton)
        flagStackView.addArrangedSubview(countryNameLabel)
        flagStackView.addArrangedSubview(countryCapitalLabel)
        flagStackView.spacing      = 10.0
        flagStackView.translatesAutoresizingMaskIntoConstraints = true
        
        mainStackView.axis         = .vertical
        mainStackView.alignment    = .fill
        mainStackView.distribution = .fill
        mainStackView.spacing      = 10.0
        
        mainStackView.addArrangedSubview(mapView)
        mainStackView.addArrangedSubview(flagStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(mainStackView)
        
        //autolayout the stack view
        let viewsDictionary = ["stackView":mainStackView]
        let stackView_H = NSLayoutConstraint.constraints(withVisualFormat:
            "H:|-20-[stackView]-20-|",
                                                         options: NSLayoutFormatOptions(rawValue: 0),
                                                         metrics: nil,
                                                         views: viewsDictionary)
        let stackView_V = NSLayoutConstraint.constraints(withVisualFormat:
            "V:|-20-[stackView]-20-|",
                                                         options: NSLayoutFormatOptions(rawValue: 0),
                                                         metrics: nil,
                                                         views: viewsDictionary)
        self.view.addConstraints(stackView_H)
        self.view.addConstraints(stackView_V)
        
    }
    func readpList()
    {
        /*
         Read the pList, we expect an array containing
         a set of dictionaries for each country.
         */
        if let path = Bundle.main.path(forResource: plistFileName, ofType: fileType)
        {
            if let array = NSArray(contentsOfFile: path) as? [[String: String]]
            {
                plistArray = array
                print(plistArray)
            }
        }
        
    }
    func chooseRandomCountry()
    {
        // select random country
        countryNumber = GKRandomSource.sharedRandom().nextInt(upperBound: plistArray.count)
        countryDict   = plistArray [countryNumber]
        
        // Extract country details from dictionaries
        var capLatitude:  Float  = 0.0
        var capLongitude: Float  = 0.0
        if let latCode = countryDict[countryCapLatID]
        {
            capLatitude = (latCode as NSString).floatValue
        }
        if let lonCode = countryDict[countryCapLonID]
        {
            capLongitude = (lonCode as NSString).floatValue
        }
        
        let capCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(capLatitude),longitude: CLLocationDegrees(capLongitude))
        
        let cTitle = countryDict[countryCapitalID]!
        let codeString = countryDict[countryCodeID]!
        let fileString = countryDict[countryFlagID]!
        
        // make info string for the notation
        let landString = countryDict[countryNameID]!
        let capString  = NSLocalizedString("Thecapitalof", comment: "The capital of ..")
        let infoString = "\(capString) \(landString)"
        
        // store country details to Country class.
        currentCountry = Country(title: cTitle, coordinate: capCoordinate, info: infoString, landCode: codeString, landName: landString, flagFileName: fileString)
        
    }
    func updateUI()
    {
        /*
         Update the labels with country name and capital
         Update button with a image of the country flag
         Centre the mapView to the capital's position.
         */
        countryNameLabel.text    = currentCountry?.landName
        countryCapitalLabel.text = currentCountry?.title
        
        if let imageName = currentCountry?.flagFileName
        {
            let image = UIImage(named: imageName)
            countryFlagButton.setBackgroundImage(image, for: .normal)
        }
        centerMapOnLocation(location: (currentCountry?.coordinate)!)
        mapView.addAnnotation(currentCountry!)
        
    }
    func centerMapOnLocation(location: CLLocationCoordinate2D)
    {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: false)
    }
    
    func flagTapped(sender: UIButton!)
    {
        // switch to next country
        chooseRandomCountry()
        updateUI()
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if annotation is Country
        {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
            if annotationView == nil
            {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
                annotationView!.canShowCallout = true
                
                let button     = UIButton(type: .detailDisclosure)
                annotationView!.rightCalloutAccessoryView = button
            }
            else
            {
                annotationView!.annotation = annotation
            }
            return annotationView
        }
        return nil
        
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        let country = view.annotation as! Country
        let placeName = country.title
        let placeInfo = country.info
        let ac = UIAlertController(title: placeName, message:
            placeInfo, preferredStyle: .alert)
        let okString = NSLocalizedString("OK", comment: "OK in Alert")
        ac.addAction(UIAlertAction(title: okString, style: .default))
        present(ac, animated: true)
    }
}

