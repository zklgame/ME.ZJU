//
//  AcademicLoginViewController.swift
//  ME.ZJU
//
//  Created by zklgame on 6/15/16.
//  Copyright © 2016 Zhejiang University. All rights reserved.
//

import UIKit

import Alamofire

class AcademicLoginViewController: BaseViewController {

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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(AcademicLoginViewController.viewTapped(_:)))
        self.view.addGestureRecognizer(tap)
        
        self.title = "教务网"
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
        Alamofire.request(.POST, URLs.acaLogin, parameters: [
            "__VIEWSTATE": "dDwxNTc0MzA5MTU4Ozs+RGE82+DpWCQpVjFtEpHZ1UJYg8w=",
            "RadioButtonList1": "学生",
            "__EVENTTARGET": "Button1",
            "__EVENTARGUMENT": "",
            "TextBox1": studentId,
            "TextBox2": password
            ], encoding: .URL, headers: nil).response {[weak self] (_, response, data, error) in
                if let strongSelf = self {
                    if error != nil {
                        strongSelf.simpleAlert(ErrorMsg.network)
                        return
                    }
                    
                    if let data = data {
                        let enc = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
                        if let result = NSString.init(data: data, encoding: enc) {
                            if result.containsString("密码错误") || result.containsString("用户名不存在") {
                                strongSelf.simpleAlert("学号或密码错误")
                                return
                            }
                            
                            if let url = response?.URL {
                                strongSelf.saveAcaLogin(studentId, password: password)
                                strongSelf.toMain(url.absoluteString, data: result)
                            }
                        }
                    }
                }
        }
    }
    
    // MARK: to main
    func toMain(url: NSString, data: NSString) {
        if let vcs = self.navigationController?.viewControllers {
            for vc in vcs {
                if let mvc = vc as? AcademicMainViewController {
                    mvc.data = data
                    mvc.url = url
                    break
                }
            }
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }

}
