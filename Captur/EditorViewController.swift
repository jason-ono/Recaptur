//
//  EditorViewController.swift
//  Captur
//
//  Created by Kotaro Ono on 2021/01/27.
//

import Foundation
import AVFoundation
import UIKit
import Photos
import CoreLocation
import MapKit

class EditorViewController: UIViewController {

    /*
     EditorViewController completes the following task
     - set up the UI for viewing a photo and editing its metadata
     - passes in a photo taken and displays it
     - provides buttons to initiate new windows for metadata edit (location & timestamp)
     - saves a photo to photo library with user-provided metadata
     */
    
// MARK: Variables
    
    // utility
    let windowSize: CGRect = UIScreen.main.bounds
    let windowWidth: CGFloat = UIScreen.main.bounds.width
    let windowHeight: CGFloat = UIScreen.main.bounds.height
    
    // UI
    var image : UIImage!
    var imageView = UIImageView()
    var parentStackView = UIStackView()
    var labelStackView = UIStackView()
    var dateLabel = UILabel()
    var locationLabel = UILabel()
    var dateButtonParentView = UIView()
    var dateButton = UIButton()
    var locationButtonParentView = UIView()
    var locationButton = UIButton()
    
    // Date
    var defaultDate : Date?
    var userDate = Date()
    var datePicker = UIDatePicker()
    var toolBar = UIToolbar()
    
    // location
    var userLocation = CLLocation()
    var locationManager = CLLocationManager()
    
    // haptic
    let feedbackGenerator: Any? = {
        if #available(iOS 10.0, *) {
            let generator: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            return generator
        } else {
            return nil
        }
    }()
    
// MARK: Methods
    
    /*
     - initiates location manager
     - calls UI setup funcs
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        setupUI()
        setupLocationManager()
    }
    
    /*
     - called in previous VC
     - passes in photo taken as a local field
     */
    func passPhoto(_ rectImage: UIImage){
        self.image = rectImage
        setupImageView()
    }

    /*
     - set the passed in photo as the image
     */
    func setupImageView(){
        imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    /*
     - UI setup
     - AutoLayout setup
     */
    func setupUI(){
        // background
        view.backgroundColor = .black
        
        // navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveMeta))
        
        // initial setup
        setupButtonView()
        setupButtons()
        setupDateLabelAndPicker()
        setupLocationLabel()
        
        [dateButtonParentView, locationButtonParentView, labelStackView
        ].forEach{ $0.translatesAutoresizingMaskIntoConstraints = false }
        
        parentStackView.axis = .horizontal
        parentStackView.distribution = .equalSpacing
        
        labelStackView.axis = .vertical
        labelStackView.distribution = .fillEqually
        
        // add to views
        view.addSubview(imageView)
        view.addSubview(parentStackView)
        
        parentStackView.addArrangedSubview(dateButtonParentView)
        parentStackView.addArrangedSubview(labelStackView)
        parentStackView.addArrangedSubview(locationButtonParentView)
        
        dateButtonParentView.addSubview(dateButton)
        locationButtonParentView.addSubview(locationButton)
        
        labelStackView.addArrangedSubview(dateLabel)
        labelStackView.addArrangedSubview(locationLabel)
 
        // AutoLayout
        [imageView.widthAnchor.constraint(equalToConstant: windowWidth),
         imageView.heightAnchor.constraint(equalToConstant: imageView.image!.size.height),
         imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
         imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
         imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
         imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -windowHeight*0.15),
         imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
         imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ].forEach{ $0.isActive = true }
        
        [parentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: windowWidth*0.03),
         parentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -windowWidth*0.03),
         parentStackView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: windowWidth*0.03),
         parentStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -windowWidth*0.01)
        ].forEach{ $0.isActive = true }
        
        [labelStackView.widthAnchor.constraint(equalTo: parentStackView.widthAnchor, multiplier: 0.5),
         dateButtonParentView.widthAnchor.constraint(equalTo: parentStackView.widthAnchor, multiplier: 0.2),
         locationButtonParentView.widthAnchor.constraint(equalTo: parentStackView.widthAnchor, multiplier: 0.2),
         dateButtonParentView.leadingAnchor.constraint(equalTo: parentStackView.leadingAnchor),
         labelStackView.leadingAnchor.constraint(equalTo: dateButtonParentView.trailingAnchor),
         locationButtonParentView.leadingAnchor.constraint(equalTo: labelStackView.trailingAnchor),
         locationButtonParentView.trailingAnchor.constraint(equalTo: parentStackView.trailingAnchor)
        ].forEach{ $0.isActive = true }

        [dateLabel.bottomAnchor.constraint(equalTo: locationLabel.topAnchor)].forEach{ $0.isActive = true }
        
        [dateButton.centerXAnchor.constraint(equalTo: dateButtonParentView.centerXAnchor),
         dateButton.centerYAnchor.constraint(equalTo: dateButtonParentView.centerYAnchor),
         locationButton.centerXAnchor.constraint(equalTo: locationButtonParentView.centerXAnchor),
         locationButton.centerYAnchor.constraint(equalTo: locationButtonParentView.centerYAnchor)
        ].forEach{ $0.isActive = true }
        
        // update location
        if locationManager.location != nil{
            processLocationData(locationManager.location!)
        }
    }
    
    /*
     - to enable AutoLayout
     */
    func setupButtonView(){
        parentStackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupButtons(){
        let config = UIImage.SymbolConfiguration(pointSize: 35)
        
        let buttonDateImage = UIImage(systemName: "calendar.badge.plus", withConfiguration: config)
        dateButton.setImage(buttonDateImage, for: .normal)
        dateButton.addTarget(self, action: #selector(showDatePicker), for: .touchUpInside)
        dateButton.tintColor = .orange
        dateButton.translatesAutoresizingMaskIntoConstraints = false
        dateButton.addInnerShadow()
        
        let buttonLocationImage = UIImage(systemName: "mappin.and.ellipse", withConfiguration: config)
        locationButton.setImage(buttonLocationImage, for: .normal)
        /*
            locationPressed should actually bring about a new map window
            remember to migrate the method to the map
        */
        locationButton.addTarget(self, action: #selector(locationPressed), for: .touchUpInside)
        locationButton.tintColor = .orange
        locationButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupDateLabelAndPicker(){
        // Label
        dateLabel.font = UIFont(name: "CrystalItalic-", size: 35)
        dateLabel.textAlignment = .center
        dateLabel.minimumScaleFactor = 0.5
        dateLabel.adjustsFontSizeToFitWidth = true
        dateLabel.textColor = .orange
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Picker
        datePicker.autoresizingMask = .flexibleWidth
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.backgroundColor = .systemGray6
        datePicker.setValue(UIColor.orange, forKey: "textColor")
        
        if defaultDate == nil{
            defaultDate = Date()
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-y"
        dateLabel.text = formatter.string(from: defaultDate!)
        datePicker.date = defaultDate!
    }
    
    func setupLocationManager(){
        locationManager.delegate = self
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            
        }
    }
    
    func processLocationData(_ location: CLLocation){
        var locationString = "."
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let validPlacemarks = placemarks{
                if let validFirstItem = validPlacemarks.first{
                    // for US address, set "cityName, XX" where XX stands for state
                    if validFirstItem.country == "United States"{
                        locationString = "\(validFirstItem.locality!), \(validFirstItem.administrativeArea!)"
                        self.locationLabel.text = locationString.uppercased()
                    // otherwise, set "cityName, countryName" style
                    } else {
                        if (validFirstItem.locality == nil){
                            if (validFirstItem.administrativeArea == nil ) {
                                if (validFirstItem.country == nil ) {
                                    locationString = "UNDEFINED"
                                } else {
                                    locationString = "\(validFirstItem.country!)"
                                }
                            } else {
                                locationString = "\(validFirstItem.administrativeArea!), \(validFirstItem.country!)"
                            }
                        } else {
                            locationString = "\(validFirstItem.locality!), \(validFirstItem.country!)"
                        }
                        self.locationLabel.text = locationString.uppercased()
                    }
                }
            }
        }
    }
    
    func setupLocationLabel(){
        locationLabel.text = "-"
        locationLabel.font = UIFont(name: "CrystalItalic-", size: 35)
        locationLabel.textAlignment = .center
        locationLabel.minimumScaleFactor = 0.5
        locationLabel.adjustsFontSizeToFitWidth = true
        locationLabel.textColor = .orange
//        dateLabel.adjustsFontSizeToFitWidth = true
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupLabelStackView(){
        labelStackView.axis = .vertical
        labelStackView.distribution = .fillEqually
        labelStackView.addSubview(dateLabel)
        labelStackView.addSubview(locationLabel)
    }
    
// MARK: Button functions
    
    @objc func showDatePicker(){
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        datePicker.alpha = 0
        toolBar.alpha = 0
        
        view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        [datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
         datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
         datePicker.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ].forEach{ $0.isActive = true }
    
        view.addSubview(toolBar)
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: #selector(savePressed))
        saveButton.tintColor = .orange
        toolBar.setItems([saveButton], animated: true)
        
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        [toolBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
         toolBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
         toolBar.bottomAnchor.constraint(equalTo: datePicker.topAnchor),
        ].forEach{ $0.isActive = true }
        
        UIView.animate(withDuration: 0.3) { self.datePicker.alpha = 1; self.toolBar.alpha = 1 }
    }

    @objc func locationPressed(){
        let mapVC = MapViewController()
        mapVC.userLocation = self.userLocation
        mapVC.delegate = self
        self.present(mapVC, animated: true, completion: nil)
    }
    
    @objc func savePressed(){
        navigationItem.rightBarButtonItem?.isEnabled = true
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-y"
        userDate = datePicker.date
        dateLabel.text = formatter.string(from: datePicker.date)
        UIView.animate(withDuration: 0.3) { self.datePicker.alpha = 0; self.toolBar.alpha = 0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35){
            self.datePicker.removeFromSuperview()
            self.toolBar.removeFromSuperview()
        }
    }
    
    /*
        - called by navigationItem.rightBarButtonItem
        - saves the scannd image, then fetch it immediately after as the newest item in photo
          library to edit its metadata with user-provided information
     */
    @objc func saveMeta(){
        // generate tapback when save is pressed
        if #available(iOS 10.0, *), let generator = feedbackGenerator as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
        // save the image once to the photo library
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        // wait for the system to renew the library
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
            // make change in the photolibrary
            PHPhotoLibrary.shared().performChanges({
                let fetchOptions = PHFetchOptions()
                // re-fetch the latest image in the library, which is the image we just saved
                fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
                fetchOptions.fetchLimit = 1
                let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
                // error check
                if(fetchResult.count == 0){
                    print("fetch error")
                }else{
                    // make a request object
                    let asset = fetchResult.firstObject
                    let request = PHAssetChangeRequest(for: asset!)
                    // re-write the metadata with user-provided data
                    request.creationDate = self.userDate
                    request.location = self.userLocation
                }
            }, completionHandler: {_, error in
                if error != nil{
                    print("error occured")
                }
            })
        }
        // wait until the photo library syncs
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7){
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // Make the navigation bar background clear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    // Restore the navigation bar to default
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
    }
}

extension EditorViewController : CLLocationManagerDelegate {}

extension EditorViewController : MapViewControllerDelegate{
    func passData(_ location: CLLocation) {
        userLocation = location
        processLocationData(userLocation)
    }
}

// decorative
extension UIButton {
    func addInnerShadow() {
        let innerShadow = CALayer()
        innerShadow.frame = bounds

        // Shadow path (1pt ring around bounds)
        let radius = self.frame.size.height/2
        let path = UIBezierPath(roundedRect: innerShadow.bounds.insetBy(dx: -1, dy:-1), cornerRadius:radius)
        let cutout = UIBezierPath(roundedRect: innerShadow.bounds, cornerRadius:radius).reversing()

        path.append(cutout)
        innerShadow.shadowPath = path.cgPath
        innerShadow.masksToBounds = true
        // Shadow properties
        innerShadow.shadowColor = UIColor.black.cgColor
        innerShadow.shadowOffset = CGSize(width: 0, height: 3)
        innerShadow.shadowOpacity = 0.8
        innerShadow.shadowRadius = 5
        innerShadow.cornerRadius = self.frame.size.height/2
        layer.addSublayer(innerShadow)
    }
}
