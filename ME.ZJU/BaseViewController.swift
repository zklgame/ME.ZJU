//
//  BaseViewController.swift
//  ME.ZJU
//
//  Created by zklgame on 6/11/16.
//  Copyright © 2016 Zhejiang University. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    // MARK: simple alert
    func simpleAlert(alertTitle: String = "", message: String = "", okTitle: String = "OK") {
        let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: okTitle, style: .Default, handler: nil)
        alert.addAction(okAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: user defaults
    func saveLibLogin(studentId: String, password: String) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(studentId, forKey: Defaults.libStudentId)
        userDefaults.setObject(password, forKey: Defaults.libPassword)
        userDefaults.synchronize()
    }
    
    func saveAcaLogin(studentId: String, password: String) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(studentId, forKey: Defaults.acaStudentId)
        userDefaults.setObject(password, forKey: Defaults.acaPassword)
        userDefaults.synchronize()
    }

    func clearLibLogin() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.removeObjectForKey(Defaults.libStudentId)
        userDefaults.removeObjectForKey(Defaults.libPassword)
        userDefaults.synchronize()
    }
    
    func clearAcaLogin() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.removeObjectForKey(Defaults.acaStudentId)
        userDefaults.removeObjectForKey(Defaults.acaPassword)
        userDefaults.synchronize()
    }
    
    func checkLibUser() -> Bool {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if userDefaults.objectForKey(Defaults.libStudentId) != nil {
            return true
        }
        return false
    }
    
    func checkAcaUser() -> Bool {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if userDefaults.objectForKey(Defaults.acaStudentId) != nil {
            return true
        }
        return false
    }
    
    func getAcaStudentId() -> String? {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let sid = userDefaults.objectForKey(Defaults.acaStudentId) as? String {
            return sid
        }
        return nil
    }
    
    // MARK: get url, text
    func getUrl(href: String) -> String {
        var url: String
        let components = href.componentsSeparatedByString("'")
        if components.count > 1 {
            url = components[1]
        } else {
            url = href
        }
        
        return url
    }
    
    func getText(s: String) -> String {
        let whitespace = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        return s.stringByTrimmingCharactersInSet(whitespace)
    }

    // MARK: get time
    func getCurrentYearMonth() -> (Int, Int) {
        let components1 = NSCalendar.currentCalendar().components(.Year, fromDate: NSDate())
        let components2 = NSCalendar.currentCalendar().components(.Month, fromDate: NSDate())
        return (components1.year, components2.month)
    }
    
    // 1 - 7
    func getCurrentWeekday() -> Int {
        let components = NSCalendar.currentCalendar().components(.Weekday, fromDate: NSDate())
        if 1 == components.weekday {
            return 7
        } else {
            return components.weekday - 1
        }
    }
    
    func getClassTime(index: Int) -> String {
        switch index {
        case 1:
            return "8:00 - 8:45"
        case 2:
            return "8:50 - 9:35"
        case 3:
            return "9:50 - 10:35"
        case 4:
            return "10:40 - 11:25"
        case 5:
            return "11:30 - 12:15"
        case 6:
            return "13:15 - 14:00"
        case 7:
            return "14:05 - 14:50"
        case 8:
            return "14:55 - 15:40"
        case 9:
            return "15:55 - 16:40"
        case 10:
            return "16:45 - 17:30"
        case 11:
            return "18:30 - 19:15"
        case 12:
            return "19:20 - 20:05"
        case 13:
            return "20:10 - 20:55"
        default:
            return ""
        }
    }

    func getWeekString(index: Int) -> String {
        switch index {
        case 1:
            return "一"
        case 2:
            return "二"
        case 3:
            return "三"
        case 4:
            return "四"
        case 5:
            return "五"
        case 6:
            return "六"
        case 7:
            return "日"
        default:
            return ""
        }
    }
    


}
