//
//  ViewController.swift
//  Captur
//
//  Created by Kotaro Ono on 2021/01/21.
//

import UIKit
import AVFoundation
import Photos
import Vision
import QuartzCore
import PhotosUI

class ViewController: UIViewController, UINavigationControllerDelegate {

    /*
     Structure
     
     - VDL()
        - startCaptureSession()
             - setupInputs()
             - setupPreviewlayer()
             - setupOutputs()
             - setupPreviewlayer()
        - setupView()
     - captureOutput(***) [AVCaptureVideoDataOutputSampleBufferDelegate Extension]
         - detectRectangle(CVPixelBuffer)
             - removeMask()
             - drawBoundingBox(VNRectangleObservation)
                 - createLayer(CGRect)
             - if isTapped:
                 - doPerspectiveCorrection(VNRectangleObservation, CVPixelBuffer)
                     - (instantiates a new VC)
     */
    
// MARK: Var / Const
    
    // Capture session
    var captureSession : AVCaptureSession!
    
    // Device
    var backCamera : AVCaptureDevice!
    
    // Input
    var sampleInput : AVCaptureInput!
    
    // Output
    var sampleOutput : AVCaptureVideoDataOutput!
    
    // Preview
    var previewLayer : AVCaptureVideoPreviewLayer!
    
    // Rect Detection
    var maskLayer = CAShapeLayer()
    
    // UI
    var previewUIView = UIView()
    
    let albumButton : UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 25)
        let buttonImage = UIImage(systemName: "photo.fill.on.rectangle.fill", withConfiguration: config)
        button.setImage(buttonImage, for: .normal)
        button.tintColor = .orange
        button.layer.masksToBounds = false
        button.addTarget(self, action: #selector(albumPressed), for: .touchUpInside)
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 2
        button.layer.shadowOffset = CGSize(width: 2, height: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let infoButton : UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 25)
        let buttonImage = UIImage(systemName: "info.circle", withConfiguration: config)
        button.setImage(buttonImage, for: .normal)
        button.tintColor = .orange
        button.layer.masksToBounds = false
        button.addTarget(self, action: #selector(infoPressed), for: .touchUpInside)
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 2
        button.layer.shadowOffset = CGSize(width: 2, height: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let captureButton : UIButton = {
        let button = UIButton()
//        let buttonImage = UIImage(named: "Shutter")
//        button.setImage(buttonImage, for: .normal)
        var radius : CGFloat!
        button.layer.borderWidth = 6
        // https://stackoverflow.com/questions/39702895/how-to-have-uiview-as-a-circle-with-corner-radius-with-xcode-8
        button.layer.borderColor = UIColor.orange.cgColor
        button.backgroundColor = .clear
        button.clipsToBounds = true
        button.layer.masksToBounds = false
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 2
        button.layer.shadowOffset = CGSize(width: 2, height: 1)
        button.addTarget(self, action: #selector(captureImage(_:)), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    // info UI
    // slide 1, base
    var blurEffectView = UIVisualEffectView()
    var guideView = UIView()
    var parentImageView = UIView()
    var dateLabel = UILabel()
    var tapSuggestLabel = UILabel()
    var backgroundUIView = UIView()
    var mainImageView = UIImageView()
    
    // slide 2
    var cursorView = UIView()
    
    // slide 3
    var imageBoxView = UIView()
    var calendarImageView = UIImageView()
    var pinImageView = UIImageView()
    var albumImageView = UIImageView()
    
    var picker = UIImagePickerController()
    
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
    
    // aux booleans
    var isTapped = false
    
    // Screen Dimensions
    let windowSize: CGRect = UIScreen.main.bounds
    let windowWidth: CGFloat = UIScreen.main.bounds.width
    let windowHeight: CGFloat = UIScreen.main.bounds.height
    
// MARK: Overriden Methods

    // VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startCaptureSession()
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        captureButton.layer.cornerRadius = captureButton.frame.width / 2
    }

    override func viewDidAppear(_ animated: Bool) {
        let videoQueue = DispatchQueue(label: "videoQueue")
        self.sampleOutput.setSampleBufferDelegate(self, queue: videoQueue)
        self.captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.sampleOutput.setSampleBufferDelegate(nil, queue: nil)
        self.captureSession.stopRunning()
    }
    
    @objc func captureImage(_ sender: UIButton?){
        isTapped = true
    }
    
// MARK: Recording Methods
    
    func startCaptureSession(){
        DispatchQueue.main.async{ // background
            // start session
            self.captureSession = AVCaptureSession()
            
            // begin config
            self.captureSession.beginConfiguration()
            
            // setup input
            self.setupInputs()
            
            // setup preview layer
            self.setupPreviewlayer()
           
 
            // setup output
            self.setupOutputs()
            
            self.captureSession.commitConfiguration()
            
//            self.captureSession.startRunning()
            
        }
    }
    
    func setupInputs(){
        // register back camera
        if let photoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            backCamera = photoDevice
        } else {
            fatalError("no applicable camera detected")
        }
        
        // create an input
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: backCamera), self.captureSession.canAddInput(videoDeviceInput) else {
            fatalError("input creation failed")
        }
        sampleInput = videoDeviceInput
        
        // add an input to the session
        self.captureSession.addInput(videoDeviceInput)
    }

    func setupPreviewlayer(){
        // create a preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        
        previewLayer.videoGravity = .resizeAspectFill
        
        /*
        self.view.layer.addSublayer(self.previewLayer)
        self.previewLayer.frame = self.view.frame
         */
        
        previewUIView.layer.addSublayer(previewLayer)
        previewLayer.frame = previewUIView.frame
        
        
        /*
        // add the layer
        view.layer.insertSublayer(previewLayer, below: captureButton.layer)
        // set the frame
        previewLayer.frame = self.view.layer.frame
        */
    }


    func setupOutputs(){
        // create an output
        sampleOutput = AVCaptureVideoDataOutput()
        
        /*
        // create a queue to be used
        let videoQueue = DispatchQueue(label: "videoQueue")
        // delegate setup
        self.sampleOutput.setSampleBufferDelegate(self, queue: videoQueue)
        */
 
        // other setup
        self.sampleOutput.alwaysDiscardsLateVideoFrames = true
        
        // add output if it's possible
        if captureSession.canAddOutput(sampleOutput){
            captureSession.addOutput(sampleOutput)
        } else {
            fatalError("vide output could not be added")
        }
        guard let connection = self.sampleOutput.connection(with: AVMediaType.video), connection.isVideoOrientationSupported else { return }
        connection.videoOrientation = .portrait
    }
    
    func setupView(){
        view.backgroundColor = .black
        
        
        // previewUIView
        previewUIView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(previewUIView)
        [previewUIView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
         previewUIView.topAnchor.constraint(equalTo: view.topAnchor),
         previewUIView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
         previewUIView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ].forEach{ $0.isActive = true }
 
        // shutter button
        view.addSubview(captureButton)
        [captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
         captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
         captureButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.2),
         captureButton.heightAnchor.constraint(equalTo: captureButton.widthAnchor)
        ].forEach{ $0.isActive = true }
        self.view.bringSubviewToFront(captureButton)
        
        
        // album button
        view.addSubview(albumButton)
        [albumButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//         albumButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//         albumButton.trailingAnchor.constraint(equalTo: captureButton.leadingAnchor),
         albumButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -windowWidth*0.3),
         albumButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor),
         albumButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
         albumButton.heightAnchor.constraint(equalTo: albumButton.widthAnchor)
        ].forEach{ $0.isActive = true }
        self.view.bringSubviewToFront(albumButton)
 
        // info button
        view.addSubview(infoButton)
        [infoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//         albumButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//         albumButton.trailingAnchor.constraint(equalTo: captureButton.leadingAnchor),
         infoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: windowWidth*0.3),
         infoButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor),
         infoButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
         infoButton.heightAnchor.constraint(equalTo: infoButton.widthAnchor)
        ].forEach{ $0.isActive = true }
        self.view.bringSubviewToFront(infoButton)
        
//        [
//        captureButton.leadingAnchor.constraint(equalTo: albumButton.trailingAnchor)
//       ].forEach{ $0.isActive = true }
        
        /*
        captureButton.addTarget(self, action: #selector(captureImage(_:)), for: .touchUpInside)
        captureButton.isUserInteractionEnabled = true
        */
    }
    
// MARK: Rectangle Detection / Processing
    
    func detectRectangle(in image: CVPixelBuffer){
        // define a request (not yet performed tho)
        let request = VNDetectRectanglesRequest(completionHandler: { (request: VNRequest, error: Error?) in
            DispatchQueue.main.async{
                // results created
                guard let results = request.results as? [VNRectangleObservation] else { return }
                self.removeMask()
                
                // rect defined from the results
                guard let rect = results.first else {return}
                
                // draw a bounding box based on the observation
                self.drawBoundingBox(rect: rect)
                
                // only called when the picture is captured
                if self.isTapped{
                    // set the boolean back to false
                    self.isTapped = false
                    // extract the image
                        // takes in the detected rectange and the original frame
                    self.doPerspectiveCorrection(rect, from: image)
                }
            }
        })
        
        // setup of request
        request.minimumAspectRatio = VNAspectRatio(1.3)
        request.maximumAspectRatio = VNAspectRatio(1.6)
        request.minimumSize = Float(0.5)
        request.maximumObservations = 1
        
        // perform the request
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, options: [:])
        try? imageRequestHandler.perform([request])
    }
    
    func drawBoundingBox(rect : VNRectangleObservation){
        
        // transform struct for normazlized coordinate of Vision (left bottom 0,0) into image coordinate (left top 0,0)
            // x remains the same, y is reversed
            // move the amount of hegative previewLayer frame height /w .translatedBy method
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -self.previewLayer.frame.height)
        
        // scale struct
        let scale = CGAffineTransform.identity.scaledBy(x: self.previewLayer.frame.width, y: self.previewLayer.frame.height)

        // .applying is specifically for CGAffineTransform struct
        let bounds = rect.boundingBox.applying(scale).applying(transform)
        self.createLayer(in: bounds)
    }
    
    func createLayer(in rect: CGRect){
        
        maskLayer = CAShapeLayer()
        maskLayer.frame = rect
        maskLayer.cornerRadius = 0
        maskLayer.opacity = 0.6
        maskLayer.borderColor = UIColor.orange.cgColor
        maskLayer.borderWidth = 4.0
          
//        previewLayer.addSublayer(maskLayer)
        previewLayer.insertSublayer(maskLayer, at: 1)
    }
    
    func removeMask(){
        maskLayer.removeFromSuperlayer()
    }
    
// MARK: Extract rectangle
    
    func doPerspectiveCorrection(_ observation: VNRectangleObservation, from buffer: CVImageBuffer){
        
        // buffer is the frame of the image
        // creating a CIImage representation of the image frame
        var ciImage = CIImage(cvImageBuffer: buffer)
        
        // CGPoint objects, a point (coordinate) in (x,y) system
        let topLeft = observation.topLeft.scaled(to: ciImage.extent.size)
        let topRight = observation.topRight.scaled(to: ciImage.extent.size)
        let bottomLeft = observation.bottomLeft.scaled(to: ciImage.extent.size)
        let bottomRight = observation.bottomRight.scaled(to: ciImage.extent.size)
        
        /*
         CIPerspectiveCorrection
         "transforming an arbitrary quadrilateral region in the source image to a rectangular output image."
         takes in four CIVector
         Check out:
         https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIPerspectiveCorrection
         */
        
        ciImage = ciImage.applyingFilter("CIPerspectiveCorrection", parameters: [
                                            "inputTopLeft": CIVector(cgPoint: topLeft),
                                            "inputTopRight": CIVector(cgPoint: topRight),
                                            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
                                            "inputBottomRight": CIVector(cgPoint: bottomRight),
        ])
        
        // save photo template
        let context = CIContext()
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
        let output = UIImage(cgImage: cgImage!)
        
        if #available(iOS 10.0, *), let generator = feedbackGenerator as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
        
        let editorVC = EditorViewController()
        editorVC.passPhoto(output)
//        editorVC.modalPresentationStyle = .fullScreen
        UIView.animate(withDuration: 0.3) {}
        navigationController?.pushViewController(editorVC, animated: false)
        
//        self.present(editorVC, animated: false, completion: nil)
//        UIImageWriteToSavedPhotosAlbum(output, nil, nil, nil)
    }
    
// MARK: Info
    @objc func infoPressed(){
        if !UIAccessibility.isReduceTransparencyEnabled {
            view.backgroundColor = .clear

            let blurEffect = UIBlurEffect(style: .dark)
            blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurEffectView.alpha = 0
            view.addSubview(blurEffectView)
            
            showPage1()
        } else {}
    }

    func showPage1(){
        setupBasics()
        setupPhotoCaptureScene()
        
        dateLabel.text = "Place your photo on plain background."
        tapSuggestLabel.text = "Tap to proceed"
        self.backgroundUIView.alpha = 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.7){
            UIView.animate(withDuration: 0.75) {
                self.mainImageView.alpha = 1
            }
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.showPage2))
        guideView.addGestureRecognizer(tap)
    }
    
    @objc func showPage2(){
        guideView.removeGestureRecognizer(guideView.gestureRecognizers![0])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.showPage3))
        guideView.addGestureRecognizer(tap)
        
        parentImageView.addSubview(cursorView)
        cursorView.alpha = 0
        cursorView.backgroundColor = .clear
        cursorView.translatesAutoresizingMaskIntoConstraints = false
        cursorView.layer.borderWidth = 3
        cursorView.layer.cornerRadius = 7
        cursorView.layer.borderColor = UIColor.orange.cgColor

        [cursorView.widthAnchor.constraint(equalTo: mainImageView.widthAnchor, multiplier: 0.95),
         cursorView.heightAnchor.constraint(equalTo: mainImageView.heightAnchor, multiplier: 0.88),
         cursorView.centerXAnchor.constraint(equalTo: parentImageView.centerXAnchor),
         cursorView.centerYAnchor.constraint(equalTo: parentImageView.centerYAnchor)
        ].forEach{ $0.isActive = true }

        
        UIView.animate(withDuration: 0.5) {
            self.dateLabel.alpha = 0
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75){
            UIView.animate(withDuration: 1) {
                self.dateLabel.text = "Capture the photo once it is recognized."
                self.dateLabel.alpha = 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
            UIView.animate(withDuration: 1) {
                
                self.cursorView.alpha = 1
            }
        }
        
    }
    
    @objc func showPage3(){
//        backgroundUIView.layer.allowsGroupOpacity = true
        
        DispatchQueue.main.asyncAfter(deadline: .now()){
            UIView.animate(withDuration: 1) {
                self.parentImageView.alpha = 0
//                self.cursorView.alpha = 0
//                self.mainImageView.alpha = 0
                self.dateLabel.alpha = 0
            }
        }
        
        
        // the reason mainImageView and cursorView immediately goes away is these are
        // edited below, ithink
        
        guideView.removeGestureRecognizer(guideView.gestureRecognizers![0])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.removeGuide))
        guideView.addGestureRecognizer(tap)
        
        guideView.addSubview(imageBoxView)
        imageBoxView.translatesAutoresizingMaskIntoConstraints = false
        
//        dateLabel.text = "Edit the timestamp and location data."
        
        imageBoxView.alpha = 0
//        calendarImageView.alpha = 1
//        pinImageView.alpha = 1
        
        let mainIconSize = view.frame.width * 0.8/3.75
        let mainConfig = UIImage.SymbolConfiguration(pointSize: mainIconSize)
        let mainImage = UIImage(systemName: "photo.fill", withConfiguration: mainConfig)
        mainImageView.image = mainImage
        mainImageView.tintColor = .orange
        mainImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let subIconSize = view.frame.width * 0.4/3.75
        let subConfig = UIImage.SymbolConfiguration(pointSize: subIconSize)
        
        let calendarImage = UIImage(systemName: "calendar", withConfiguration: subConfig)
        calendarImageView.image = calendarImage
        calendarImageView.tintColor = .orange
        calendarImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let pinImage = UIImage(systemName: "mappin.and.ellipse", withConfiguration: subConfig)
        pinImageView.image = pinImage
        pinImageView.tintColor = .orange
        pinImageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageBoxView.addSubview(mainImageView)
        imageBoxView.addSubview(calendarImageView)
        imageBoxView.addSubview(pinImageView)
        
        /*
        parentImageView.addSubview(mainImageView)
        parentImageView.addSubview(calendarImageView)
        parentImageView.addSubview(pinImageView)
 */
        [imageBoxView.widthAnchor.constraint(equalTo: guideView.widthAnchor, multiplier: 0.9),
         imageBoxView.heightAnchor.constraint(equalTo: imageBoxView.widthAnchor, multiplier: 0.65),
         imageBoxView.centerXAnchor.constraint(equalTo: guideView.centerXAnchor),
         imageBoxView.centerYAnchor.constraint(equalTo: guideView.centerYAnchor, constant: view.frame.height * -0.13)
        ].forEach{ $0.isActive = true }
 
        [mainImageView.centerXAnchor.constraint(equalTo: imageBoxView.centerXAnchor),
         mainImageView.centerYAnchor.constraint(equalTo: imageBoxView.centerYAnchor, constant: 0.18*view.frame.width)
        ].forEach{ $0.isActive = true }
        
        [calendarImageView.centerXAnchor.constraint(equalTo: imageBoxView.centerXAnchor, constant: -0.25*view.frame.width),
         calendarImageView.centerYAnchor.constraint(equalTo: imageBoxView.centerYAnchor, constant: 0.07*view.frame.width)
        ].forEach{ $0.isActive = true }
        
        [pinImageView.centerXAnchor.constraint(equalTo: imageBoxView.centerXAnchor, constant: 0.22*view.frame.width),
         pinImageView.centerYAnchor.constraint(equalTo: imageBoxView.centerYAnchor, constant: -0.03*view.frame.width)
        ].forEach{ $0.isActive = true }
        
//        UIView.animate(withDuration: 0.5) {
//            self.dateLabel.alpha = 0
//
//        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.75){
            UIView.animate(withDuration: 1) {
                self.dateLabel.text = "Edit the timestamp and location data."
                self.dateLabel.alpha = 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5){
            UIView.animate(withDuration: 1) {
                self.imageBoxView.alpha = 1
            }
        }
    }
    
    @objc func removeGuide(){
        
    }
    
    func setupBasics(){
        
        view.addSubview(guideView)
        view.bringSubviewToFront(guideView)
        
        guideView.alpha = 0
        
        guideView.frame = self.view.bounds
        
        guideView.addSubview(parentImageView)
        guideView.addSubview(dateLabel)
        guideView.addSubview(tapSuggestLabel)
        
        guideView.backgroundColor = .clear
        
        parentImageView.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        tapSuggestLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.textColor = .orange
        tapSuggestLabel.textColor = .orange
        tapSuggestLabel.isHidden = true
        
        dateLabel.font = UIFont(name: "SFProDisplay-Medium", size: 20)
        dateLabel.textAlignment = .center
        dateLabel.minimumScaleFactor = 0.5
        dateLabel.adjustsFontSizeToFitWidth = true
        
        tapSuggestLabel.font = UIFont(name: "SFProDisplay-Medium", size: 20)
        tapSuggestLabel.textAlignment = .center
        tapSuggestLabel.minimumScaleFactor = 0.5
        tapSuggestLabel.adjustsFontSizeToFitWidth = true
        
        [parentImageView.widthAnchor.constraint(equalTo: guideView.widthAnchor, multiplier: 0.9),
         parentImageView.heightAnchor.constraint(equalTo: parentImageView.widthAnchor, multiplier: 0.65),
         parentImageView.centerXAnchor.constraint(equalTo: guideView.centerXAnchor),
         parentImageView.centerYAnchor.constraint(equalTo: guideView.centerYAnchor, constant: view.frame.height * -0.1)
        ].forEach{ $0.isActive = true }
        
        [dateLabel.topAnchor.constraint(equalTo: parentImageView.bottomAnchor, constant: guideView.frame.height*0.02),
         dateLabel.widthAnchor.constraint(equalTo: guideView.widthAnchor, multiplier: 0.8),
         dateLabel.centerXAnchor.constraint(equalTo: guideView.centerXAnchor)
        ].forEach{ $0.isActive = true }
        
        [tapSuggestLabel.centerYAnchor.constraint(equalTo: guideView.centerYAnchor, constant: guideView.frame.height*0.35),
         tapSuggestLabel.widthAnchor.constraint(equalTo: guideView.widthAnchor, multiplier: 0.3),
         tapSuggestLabel.centerXAnchor.constraint(equalTo: guideView.centerXAnchor)
        ].forEach{ $0.isActive = true }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
            UIView.animate(withDuration: 0.5) {
                self.blurEffectView.alpha = 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25){
            UIView.animate(withDuration: 0.5) {
                
                self.guideView.alpha = 1
                
                self.tapSuggestLabel.isHidden = false
                self.tapSuggestLabel.blink()
            }
        }
    }
    
    
    func setupPhotoCaptureScene(){
        
        // backgroundUIView
        parentImageView.addSubview(backgroundUIView)
        backgroundUIView.translatesAutoresizingMaskIntoConstraints = false
        backgroundUIView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        backgroundUIView.layer.cornerRadius = 7
        backgroundUIView.alpha = 0
        
        [backgroundUIView.widthAnchor.constraint(equalTo: parentImageView.widthAnchor, multiplier: 0.75),
         backgroundUIView.heightAnchor.constraint(equalTo: backgroundUIView.widthAnchor, multiplier: 0.65),
         backgroundUIView.centerXAnchor.constraint(equalTo: parentImageView.centerXAnchor),
         backgroundUIView.centerYAnchor.constraint(equalTo: parentImageView.centerYAnchor)
        ].forEach{ $0.isActive = true }
        
        let iconSize = view.frame.width * 1/3.75
        let config = UIImage.SymbolConfiguration(pointSize: iconSize)
        let mainImage = UIImage(systemName: "photo.fill", withConfiguration: config)
        
        mainImageView.image = mainImage
        mainImageView.alpha = 0
        mainImageView.tintColor = .systemGray2
//        mainImageView.contentMode = .scaleAspectFit    // super important
        
        backgroundUIView.addSubview(mainImageView)
        mainImageView.translatesAutoresizingMaskIntoConstraints = false

        [mainImageView.centerXAnchor.constraint(equalTo: backgroundUIView.centerXAnchor),
         mainImageView.centerYAnchor.constraint(equalTo: backgroundUIView.centerYAnchor)
        ].forEach{ $0.isActive = true }
        
    }
    
// MARK: UIImagePicker
    @objc func albumPressed(){
        
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        picker.delegate = self
//        picker.navigationBar.tintColor = UIColor.white
//        picker.navigationBar.barTintColor = UIColor.gray
        
        let barApperance = UINavigationBar.appearance()
        barApperance.tintColor = .orange
        
        present(picker, animated: true, completion: {
//            self.picker.navigationBar.isTranslucent = false
//            self.picker.navigationBar.barTintColor = .orange
        })
    }
    
}

// MARK: Extensions

extension ViewController : AVCaptureVideoDataOutputSampleBufferDelegate{
    // Notifies the delegate that a new video frame was written
    // Called whenever the output captures and outputs a new video frame
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // sampleBuffer is a frame
        // try to convert this into a CVImageBuffer
            // this is necessary because VNImageRequestHandler takes in cvImageBuffer
        guard let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        
        self.detectRectangle(in: cvBuffer)
        
        
        /*
        Comment this back in for normal camera app
         
        if !isTapped{
            return // terminate the method, the shutter is not pressed
        }
         
        // get a CIImage from a CVImageBuffer
        let ciImage = CIImage(cvImageBuffer: cvBuffer)
        
        // get a UIImage from CIIMage
        let uiImage = UIImage(ciImage: ciImage)
        
        DispatchQueue.main.async {
            self.capturedImageView.image = uiImage
            self.takePicture = false
        }
         */
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

extension ViewController : UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let editorVC = EditorViewController()
            editorVC.passPhoto(image)
            UIView.animate(withDuration: 0.3) {}
            navigationController?.pushViewController(editorVC, animated: false)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

// Uncomment when deleting TempVC

/*
extension UIImagePickerController {
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.navigationBar.barTintColor = .orange
    }
}

extension CGPoint {
   func scaled(to size: CGSize) -> CGPoint {
       return CGPoint(x: self.x * size.width,
                      y: self.y * size.height)
   }
}

extension UIView {
    func asCircle() {
        self.layer.cornerRadius = 0.5 * bounds.size.width
        self.layer.masksToBounds = true
    }
    
}
extension UILabel {
    func blink() {
        self.alpha = 0.0;
        
        UIView.animate(withDuration: 2.5, //Time duration you want,
                       delay: 1.5,
                       options: [.curveEaseInOut], // add .autoreverse, .repeat here to repeat
            animations: { [weak self] in self?.alpha = 0.7 },
            completion: { [weak self] _ in self?.alpha = 0.7 })
    }

    func stopBlink() {
        layer.removeAllAnimations()
        alpha = 1
    }
}
*/
