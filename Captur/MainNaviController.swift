//
//  MainNaviController.swift
//  Captur
//
//  Created by Kotaro Ono on 2021/02/08.
//

import Foundation
import UIKit

class MainNaviController: UINavigationController, UITabBarControllerDelegate{
    var vcArray: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isAppAlreadyLaunchedOnce(){
            // set this back to ViewController()
            let firstVC = TempViewController()
            // let firstVC = ViewController()
            self.viewControllers.append(firstVC)
            vcArray.append(firstVC)
            self.navigationBar.tintColor = .orange
            
            // do something to call showPage1
        }else{
            // set this back to ViewController()
            let firstVC = TempViewController()
            // let firstVC = ViewController()
            self.viewControllers.append(firstVC)
            vcArray.append(firstVC)
            self.navigationBar.tintColor = .orange
        }
    }
    
    func isAppAlreadyLaunchedOnce()->Bool{
        let defaults = UserDefaults.standard

        if let isAppAlreadyLaunchedOnce = defaults.string(forKey: "isAppAlreadyLaunchedOnce"){
            print("App already launched : \(isAppAlreadyLaunchedOnce)")
            return true
        }else{
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            print("App launched first time")
            return false
        }
    }
}
