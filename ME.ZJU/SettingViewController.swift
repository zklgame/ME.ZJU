//
//  SettingViewController.swift
//  ME.ZJU
//
//  Created by zklgame on 7/1/16.
//  Copyright © 2016 Zhejiang University. All rights reserved.
//

import UIKit

class SettingViewController: BaseViewController {
    
    @IBAction func quitLibrary(sender: UIButton) {
        self.confirmQuit(1)
    }
    
    @IBAction func quitAcademic(sender: UIButton) {
        self.confirmQuit(2)
    }
    
    func confirmQuit(type: Int) {
        var message: String?
        var okAction: UIAlertAction?
        switch type {
        case 1:
            message = "确定退出图书馆么？"
            okAction = UIAlertAction(title: "确定", style: .Default, handler: { [unowned self] (action) in
                self.clearLibLogin()
                
                if let nvcs = self.tabBarController?.viewControllers {
                    for nvc in nvcs {
                        if let navController = nvc as? UINavigationController {
                            for vc in navController.viewControllers {
                                if let mvc = vc as? LibraryMainViewController {
                                    while navController.topViewController != mvc {
                                        navController.popViewControllerAnimated(false)
                                    }
                                    
                                    mvc.defaultLogin()
                                    
                                    self.tabBarController?.selectedViewController = navController
                                }
                            }
                        }
                    }
                }
                
            })
        case 2:
            message = "确定退出教务网么？"
            okAction = UIAlertAction(title: "确定", style: .Default, handler: { [unowned self] (action) in
                self.clearAcaLogin()
                
                if let nvcs = self.tabBarController?.viewControllers {
                    for nvc in nvcs {
                        if let navController = nvc as? UINavigationController {
                            for vc in navController.viewControllers {
                                if let mvc = vc as? AcademicMainViewController {
                                    while navController.topViewController != mvc {
                                        navController.popViewControllerAnimated(false)
                                    }
                                    
                                    mvc.defaultLogin()

                                    self.tabBarController?.selectedViewController = navController
                                }
                            }
                        }
                    }
                }
                
            })
        default:
            return
        }
        
        let alert = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
    
        alert.addAction(cancelAction)
        alert.addAction(okAction!)
        self.presentViewController(alert, animated: true, completion: nil)
    }

}
