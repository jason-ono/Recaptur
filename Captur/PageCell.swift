//
//  PageCell.swift
//  Captur
//
//  Created by Kotaro Ono on 2021/02/13.
//

import Foundation
import UIKit

protocol PageCellDelegate: class{
    func dismissPressed()
}

class PageCell : UICollectionViewCell, UICollectionViewDelegate {
    
    // UI
    var parentImageView = UIView()
    var dateLabel = UILabel()
    var dismissButton = UIButton()
    
    var mainImageView = UIImageView()
    var calendarImageView = UIImageView()
    var pinImageView = UIImageView()
    var albumImageView = UIImageView()
    
    var backgroundUIView = UIView()
    var cursorView = UIView()
    
    var idString = String()
    
    weak var cellDelegate: PageCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        callCorrectMethod()
    }
    
    func callCorrectMethod(){
        if (idString == "1"){
            setupSlide1()
        }
        if (idString == "2") {
            setupSlide2()
        }
        if (idString == "3") {
            setupSlide3()
        }
        if (idString == "4") {
            setupSlide4()
        }
    }
    
    func setupBasics(){
        
        /*
        // https://stackoverflow.com/questions/17041669/creating-a-blurring-overlay-view
        if !UIAccessibility.isReduceTransparencyEnabled {
            backgroundColor = .clear

            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        } else {
            backgroundColor = .black
        }
 */
        backgroundColor = .clear
        
        addSubview(parentImageView)
        addSubview(dateLabel)
        
        parentImageView.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.textColor = .orange
        
        // UIFontで指定するのはファイル名ではなく「PostScript名」です。　PostScript名はMacの標準アプリ「Font Book」で調べることができます。
        dateLabel.font = UIFont(name: "SFProDisplay-Medium", size: 20)
//        dateLabel.adjustsFontSizeToFitWidth = true
        dateLabel.textAlignment = .center
        dateLabel.minimumScaleFactor = 0.5
        dateLabel.adjustsFontSizeToFitWidth = true
        
        [parentImageView.widthAnchor.constraint(equalTo: widthAnchor),
         parentImageView.heightAnchor.constraint(equalTo: parentImageView.widthAnchor, multiplier: 0.65),
         parentImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
         parentImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -frame.height*0.1)
        ].forEach{ $0.isActive = true }
        
        [dateLabel.topAnchor.constraint(equalTo: parentImageView.bottomAnchor, constant: frame.height*0.02),
         dateLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.88),
         dateLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ].forEach{ $0.isActive = true }
    }
    
    func setupSlide1(){
        
        setupBasics()
        setupPhotoCaptureScene()
        
        dateLabel.text = "Place your photo on a plain background."
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
//            UIView.animate(withDuration: 0.5) {
//                self.backgroundUIView.alpha = 1
//            }
//        }
        self.backgroundUIView.alpha = 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            UIView.animate(withDuration: 1) {
                self.mainImageView.alpha = 1
            }
        }
    }
    
    func setupSlide2(){
        
        setupBasics()
        setupPhotoCaptureScene()
        
        dateLabel.text = "Capture the photo once it is recognized."
        backgroundUIView.alpha = 1
        mainImageView.alpha = 1
//        mainImageView.frame.size = mainImageView.intrinsicContentSize

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

        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            UIView.animate(withDuration: 1) {
                self.cursorView.alpha = 1
            }
        }
    }
    
    func setupSlide3(){
//        resetView()
        setupBasics()
        dateLabel.text = "Edit the timestamp and location data."
        
        calendarImageView.alpha = 1
        pinImageView.alpha = 1
        
        let mainIconSize = frame.width * 0.8/3.75
        let mainConfig = UIImage.SymbolConfiguration(pointSize: mainIconSize)
        let mainImage = UIImage(systemName: "photo.fill", withConfiguration: mainConfig)
        mainImageView.image = mainImage
        mainImageView.tintColor = .orange
        mainImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let subIconSize = frame.width * 0.4/3.75
        let subConfig = UIImage.SymbolConfiguration(pointSize: subIconSize)
        
        let calendarImage = UIImage(systemName: "calendar", withConfiguration: subConfig)
        calendarImageView.image = calendarImage
        calendarImageView.tintColor = .orange
        calendarImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let pinImage = UIImage(systemName: "mappin.and.ellipse", withConfiguration: subConfig)
        pinImageView.image = pinImage
        pinImageView.tintColor = .orange
        pinImageView.translatesAutoresizingMaskIntoConstraints = false
        
        parentImageView.addSubview(mainImageView)
        parentImageView.addSubview(calendarImageView)
        parentImageView.addSubview(pinImageView)
        
        
        print(parentImageView.frame.size.width, "ay")
        
        [mainImageView.centerXAnchor.constraint(equalTo: parentImageView.centerXAnchor),
         mainImageView.centerYAnchor.constraint(equalTo: parentImageView.centerYAnchor, constant: 0.18*frame.width)
        ].forEach{ $0.isActive = true }
        
        [calendarImageView.centerXAnchor.constraint(equalTo: parentImageView.centerXAnchor, constant: -0.25*frame.width),
         calendarImageView.centerYAnchor.constraint(equalTo: parentImageView.centerYAnchor, constant: 0.07*frame.width)
        ].forEach{ $0.isActive = true }
        
        [pinImageView.centerXAnchor.constraint(equalTo: parentImageView.centerXAnchor, constant: 0.22*frame.width),
         pinImageView.centerYAnchor.constraint(equalTo: parentImageView.centerYAnchor, constant: -0.03*frame.width)
        ].forEach{ $0.isActive = true }
        
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            UIView.animate(withDuration: 1) {
                self.calendarImageView.alpha = 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            UIView.animate(withDuration: 1) {
                self.pinImageView.alpha = 1
            }
        }
 */
    }
    
    func setupSlide4(){
        willRemoveSubview(backgroundUIView)
        willRemoveSubview(mainImageView)
        setupBasics()
        dateLabel.text = "Edit photos from your photo library."
        mainImageView.isHidden = true
        backgroundUIView.isHidden = true
        
        let mainIconSize = frame.width * 0.8/3.75
        let mainConfig = UIImage.SymbolConfiguration(pointSize: mainIconSize)
        let albumImage = UIImage(systemName: "person.2.square.stack.fill", withConfiguration: mainConfig)
        albumImageView.image = albumImage
        albumImageView.tintColor = .orange
        albumImageView.translatesAutoresizingMaskIntoConstraints = false
        
        parentImageView.addSubview(albumImageView)
        
        [albumImageView.centerXAnchor.constraint(equalTo: parentImageView.centerXAnchor),
         albumImageView.centerYAnchor.constraint(equalTo: parentImageView.centerYAnchor, constant: 0.1*frame.width)
        ].forEach{ $0.isActive = true }
        
        dismissButton.setTitle("Get Started", for: .normal)
        dismissButton.setTitleColor(.orange, for: .normal)
        dismissButton.addTarget(self, action: #selector(dismissButtonPressed), for: .touchUpInside)
        dismissButton.titleLabel?.font = UIFont(name: "SFProDisplay-Medium", size: 20)
        dismissButton.titleLabel?.textAlignment = .center
        dismissButton.titleLabel?.minimumScaleFactor = 0.5
        dismissButton.titleLabel?.adjustsFontSizeToFitWidth = true
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.isUserInteractionEnabled = true
        isUserInteractionEnabled = true
        
        addSubview(dismissButton)
        
        [dismissButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.3),
         dismissButton.heightAnchor.constraint(equalTo: dismissButton.widthAnchor,multiplier: 0.3),
         dismissButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -0.05*frame.width),
         dismissButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -0.05*frame.width)
        ].forEach{ $0.isActive = true }
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
        
        let iconSize = frame.width * 1/3.75
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
        
        
//        mainImageView.frame = CGRect(x: 0, y: 0, width: mainImageView.image!.size.width, height: mainImageView.image!.size.height)
//
//        print(mainImageView.frame.width, "ore")
    }
    
    func resetView(){
        
        for subview in subviews {
            subview.removeFromSuperview()
        }
        removeConstraints(constraints)
        
        removeAllConstraintsFromView(view: dateLabel)
        removeAllConstraintsFromView(view: mainImageView)
        removeAllConstraintsFromView(view: calendarImageView)
        removeAllConstraintsFromView(view: pinImageView)
        removeAllConstraintsFromView(view: albumImageView)
        removeAllConstraintsFromView(view: backgroundUIView)
        removeAllConstraintsFromView(view: cursorView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func dismissButtonPressed(){
        print("I am being pressed")
        cellDelegate?.dismissPressed()
    }
}

extension UIView {
    func removeAllConstraintsFromView(view: UIView) {
        for c in view.constraints {
            view.removeConstraint(c)
        }
    }
}

