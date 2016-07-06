//
//  AcademicMainViewController.swift
//  ME.ZJU
//
//  Created by zklgame on 6/15/16.
//  Copyright © 2016 Zhejiang University. All rights reserved.
//

import UIKit

import Alamofire
import Kanna

class AcademicMainViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: data
    var data: NSString?
    var url: NSString?
    var shouldShowCVs = false
    
    let refreshControl = UIRefreshControl()
    
    // MARK: life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // pull to refresh
        self.collectionView.alwaysBounceVertical = true
        refreshControl.addTarget(self, action: #selector(AcademicMainViewController.pullToRefresh), forControlEvents: .ValueChanged)
        self.collectionView.addSubview(refreshControl)
        
        self.refreshControl.beginRefreshing()
        self.title = "教务网"
        
        defaultLogin()
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let data = self.data, url = self.url {
            self.parseData(url, data: data)
        }
    }
    
    // MARK: pull to refresh
    func pullToRefresh() {
        self.defaultLogin()
    }
    
    // MARK: login
    func defaultLogin() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let studentId = userDefaults.objectForKey(Defaults.acaStudentId) as? String, password = userDefaults.objectForKey(Defaults.acaPassword) as? String {
            if "" == studentId || "" == password {
                self.toLogin()
            } else {
                self.login(studentId, password: password)
            }
        } else {
            self.toLogin()
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
                        strongSelf.toLogin()
                        return
                    }
                    
                    if let data = data {
                        let enc = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
                        if let result = NSString.init(data: data, encoding: enc) {
                            if result.containsString("密码错误") || result.containsString("用户名不存在") {
                                strongSelf.clearAcaLogin()
                                strongSelf.toLogin()
                                return
                            }
                            
                            if let url = response?.URL {
                                strongSelf.parseData(url.absoluteString, data: result)
                            }
                        }
                    }
                }
        }
    }
    
    // MARK: to login
    func toLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewControllerWithIdentifier("AcademicLoginViewController") as! AcademicLoginViewController
        
        loginVC.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    
    // MARK: parse data
    func parseData(url: NSString, data: NSString) {
        self.getMainMenu()
    }
    
    func getMainMenu() {
        self.refreshControl.endRefreshing()
        self.navigationController?.navigationBarHidden = false
        
        self.shouldShowCVs = true
        self.collectionView.reloadData()
    }
    
    // MARK: segue
    var dstUrl: String?
    var dstTitle: String?
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifier.achievement {
            if let dvc = segue.destinationViewController as? AcademicDetailAchievementViewController {
                dvc.url = self.dstUrl
                dvc.title = self.dstTitle
            }
        } else if segue.identifier == SegueIdentifier.lesson {
            if let dvc = segue.destinationViewController as? AcademicDetailLessonViewController {
                dvc.url = self.dstUrl
                dvc.title = self.dstTitle
            }
        }
    }
}

extension AcademicMainViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if shouldShowCVs {
            return 1
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return AcademicMainCollectionData.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AcademicMainCollectionViewCell", forIndexPath: indexPath) as! AcademicMainCollectionViewCell
        cell.itemLabel.text = AcademicMainCollectionData[indexPath.row]["item"]
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        return CGSize(width: (screenWidth - 26) / 2, height: (screenWidth - 24) / 2)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8, 8, 8, 8)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let url = AcademicMainCollectionData[indexPath.row]["url"], segueIdentifier = AcademicMainCollectionData[indexPath.row]["segueIdentifier"]{
            if "" != url {
                self.dstUrl = url
                self.dstTitle = AcademicMainCollectionData[indexPath.row]["item"]
                self.performSegueWithIdentifier(segueIdentifier, sender: self)
            }
        }
    }
    
}







