//
//  RootTabBarController.swift
//  ME.ZJU
//
//  Created by zklgame on 7/1/16.
//  Copyright © 2016 Zhejiang University. All rights reserved.
//

import UIKit

class RootTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        
        let navController = tabBarController.selectedViewController as!UINavigationController
        
        if let selectedTag = tabBarController.tabBar.selectedItem?.tag {
            switch selectedTag {
            case 1:
                if let _ = navController.topViewController as? LibraryLoginViewController {
                    return false
                }
            case 2:
                if let _ = navController.topViewController as? AcademicLoginViewController {
                    return false
                }
            default:
                return true
            }
        }
        
        return true
    }
    
}
