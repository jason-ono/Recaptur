//
//  MapViewController.swift
//  Captur
//
//  Created by Kotaro Ono on 2021/02/09.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController : UIViewController, MKMapViewDelegate {
    
    var mapView = MKMapView()
    
    var toolBar = UIToolbar()
    
    var userLocation = CLLocation()
    
    let pin = MKPointAnnotation()
    
    var tapRecognizer = UITapGestureRecognizer()
    
    var delegate: MapViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI(){
        view.addSubview(mapView)
        view.addSubview(toolBar)
        mapView.delegate = self
        setupToolBar()
        
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        [toolBar.topAnchor.constraint(equalTo: view.topAnchor),
         toolBar.widthAnchor.constraint(equalTo: view.widthAnchor),
//         toolBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//         toolBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
         toolBar.bottomAnchor.constraint(equalTo: mapView.topAnchor)
        ].forEach{ $0.isActive = true }
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        [mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
         mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
         mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ].forEach{ $0.isActive = true }
        
        setupPin()
    }
    
    func setupToolBar(){
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: #selector(closeVC))
        saveButton.tintColor = .orange
        toolBar.setItems([saveButton], animated: true)
    }
    
    func setupPin(){
        // pin
        pin.title = "Selected Location"
        let coordinate = userLocation.coordinate
//        let sampleCoordinate = CLLocationCoordinate2D(latitude: 40.74, longitude: -73.98)
        pin.coordinate = coordinate
        mapView.addAnnotation(pin)
        
        // Gesture Recognition
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        mapView.addGestureRecognizer(tapRecognizer)
    }
    
    
    @objc func closeVC(){
        if delegate != nil{
            delegate?.passData(userLocation)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleTap(_ gestureRecognizer : UIGestureRecognizer){

//
//        if gestureRecognizer.state != .began { return }

        print("unko")
        
        mapView.removeAnnotation(pin)
        
        let touchPoint = gestureRecognizer.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)

        pin.coordinate = touchMapCoordinate
        userLocation = CLLocation(latitude: touchMapCoordinate.latitude, longitude: touchMapCoordinate.longitude)
        
        mapView.addAnnotation(pin)
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }

        return annotationView
    }
}

protocol MapViewControllerDelegate {
    func passData(_ location: CLLocation)
}
