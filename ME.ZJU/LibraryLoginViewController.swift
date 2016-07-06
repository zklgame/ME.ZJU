//
//  LoginViewController.swift
//  ME.ZJU
//
//  Created by zklgame on 6/11/16.
//  Copyright © 2016 Zhejiang University. All rights reserved.
//

import UIKit

import Alamofire

class LibraryLoginViewController: BaseViewController {
    
    // MARK: outlets and actions
    @IBOutlet weak var StudentIDField: UITextField!
    @IBOutlet weak var PasswordField: UITextField!
    
    @IBAction func toLogin(sender: UIButton) {
        self.toLogin()
    }
    
    @IBAction func exitEditing(sender: UITextField) {
        self.toLogin()
    }
    
    // MARK: life circles
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let tap = UITapGestureRecognizer(target: self, action: #selector(LibraryLoginViewController.viewTapped(_:)))
        self.view.addGestureRecognizer(tap)
                
        self.title = "图书馆"
    }
    
    // MARK: tap gesture functions
    func viewTapped(tap: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // MARK: login func
    func toLogin() {
        if let studentId = self.StudentIDField.text, password = self.PasswordField.text {
            if "" == studentId || "" == password {
                self.simpleAlert("学号或密码不能为空")
                return
            }
            
            self.login(studentId, password: password)
        }
    }
    
    func login(studentId: String, password: String) {
        
        Alamofire.request(.POST, URLs.libLogin, parameters: [
            "func": "login-session",
            "login_source": "bor-info",
            "bor_library": "ZJU50",
            "bor_id": studentId,
            "bor_verification": password
            ], encoding: .URL, headers: nil).response {[weak self] (_, _, data, error) in
                if let strongSelf = self {
                    if error != nil {
                        strongSelf.simpleAlert(ErrorMsg.network)
                        return
                    }
                    
                    if let data = data {
                        if let result = NSString.init(data: data, encoding: NSUTF8StringEncoding) {
                            if result.containsString("证号或密码错误") {
                                strongSelf.simpleAlert("学号或密码错误")
                                return
                            }
                            
                            strongSelf.saveLibLogin(studentId, password: password)
                            strongSelf.toMain(result)
                        }
                    }
            }
        }
    }
    
    // MARK: to main
    func toMain(data: NSString) {
        if let vcs = self.navigationController?.viewControllers {
            for vc in vcs {
                if let mvc = vc as? LibraryMainViewController {
                    mvc.data = data
                    break
                }
            }
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }

}








