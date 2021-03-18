//
//  TestViewController.swift
//  Captur
//
//  Created by Kotaro Ono on 2021/02/04.
//

import Foundation
import AVFoundation
import UIKit
import Photos

class TestViewController: UIScrollView {

// MARK: Variables
    
    // utility
    let windowSize: CGRect = UIScreen.main.bounds
    let windowWidth: CGFloat = UIScreen.main.bounds.width
    let windowHeight: CGFloat = UIScreen.main.bounds.height
    
    // UI
    var parentImageView = UIView()
    var dateLabel = UILabel()
    
    var mainImageView = UIImageView()
    var calendarImageView = UIImageView()
    var pinImageView = UIImageView()
    var albumImageView = UIImageView()
    
    var backgroundView = UIView()
    var cursorView = UIView()
    
    
    func setupBasics(){
        
    }
    
    func setupSlide1(){
        
        
        
        /*
         windowWidth = 375 worked /w radius of 40
         40/375 = appr 0.1067
         radius = 0.1067 * windoWidth
         */
//        buttonView.layer.cornerRadius = 0.1067*windowWidth
//        [
//         buttonView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: windowWidth*0.03),
//         buttonView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -windowWidth*0.03),
//            buttonView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -windowHeight*0.2),
//         buttonView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -windowWidth*0.01),
////         buttonView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//        ].forEach{ $0.isActive = true }
        
//        let viewWidth = buttonView.bounds.size.width
//        let viewHeight = buttonView.bounds.size.height
    }
        
}

