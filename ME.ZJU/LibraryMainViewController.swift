//
//  LibraryMainViewController
//  ME.ZJU
//
//  Created by zklgame on 6/11/16.
//  Copyright © 2016 Zhejiang University. All rights reserved.
//

import UIKit

import Alamofire
import Kanna

class LibraryMainViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: data
    var data: NSString?
    var shouldShowCVs = false
    
    let refreshControl = UIRefreshControl()
    
    // MARK: life circle
    override func viewDidLoad() {
        super.viewDidLoad()

        // pull to refresh
        self.collectionView.alwaysBounceVertical = true
        refreshControl.addTarget(self, action: #selector(LibraryMainViewController.pullToRefresh), forControlEvents: .ValueChanged)
        self.collectionView.addSubview(refreshControl)
        
        self.collectionView.registerNib(UINib(nibName: "LibraryMainCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LibraryMainCollectionViewCell")
        
        self.refreshControl.beginRefreshing()
        self.title = "图书馆"
        
        defaultLogin()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let data = data {
            self.parseData(data)
        }        
    }
    
    // MARK: pull to refresh
    func pullToRefresh() {
        self.defaultLogin()
    }
    
    // MARK: login
    func defaultLogin() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let studentId = userDefaults.objectForKey(Defaults.libStudentId) as? String, password = userDefaults.objectForKey(Defaults.libPassword) as? String {
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
        
        Alamofire.request(.POST, URLs.libLogin, parameters: [
            "func": "login-session",
            "login_source": "bor-info",
            "bor_library": "ZJU50",
            "bor_id": studentId,
            "bor_verification": password
            ], encoding: .URL, headers: nil).response {[weak self] (_, _, data, error) in
                if let strongSelf = self {
                    if error != nil {
                        strongSelf.toLogin()
                        return
                    }
                    
                    if let data = data {
                        if let result = NSString.init(data: data, encoding: NSUTF8StringEncoding) {
                            if result.containsString("证号或密码错误") {
                                strongSelf.clearLibLogin()
                                strongSelf.toLogin()
                                return
                            }
                            
                            strongSelf.parseData(result)
                            
                        }
                    }
                }
        }
    }
    
    // MARK: to login
    func toLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewControllerWithIdentifier("LibraryLoginViewController") as! LibraryLoginViewController
        
        loginVC.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    
    // MARK: parse data
    func parseData(data: NSString) {
        if let doc = Kanna.HTML(html: data as String, encoding: NSUTF8StringEncoding) {
            for node in doc.css("a") {
                if let href = node["href"] {
                    if href.containsString("bor-info") {
                        self.getMainMenu(getUrl(href))
                        
                        break
                    }
                }
            }
        }
    }
    
    func getMainMenu(url: String) {
        Alamofire.request(.GET, url).response {[weak self] (_, _, data, error) in
            if let strongSelf = self {
                if nil != error {
                    strongSelf.simpleAlert(ErrorMsg.network)
                }
                
                if let data = data {
                    if let doc = Kanna.HTML(html: data, encoding: NSUTF8StringEncoding) {
                        let count = LibraryMainCollectionData.count
                        
                        for node in doc.css("a") {
                            if let href = node["href"] {
                                
                                for i in 0 ..< count {
                                    if let key = LibraryMainCollectionData[i]["key"] {
                                        if "" != key && href.containsString(key) {
                                            LibraryMainCollectionData[i]["url"] = strongSelf.getUrl(href)
                                            if let nodeText = node.text {
                                                LibraryMainCollectionData[i]["detail"] = strongSelf.getText(nodeText)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        var isNext = false
                        for node in doc.css("td") {
                            if let nodeText = node.text {
                                if isNext {
                                    LibraryMainCollectionData[3]["detail"] = strongSelf.getText(nodeText)
                                    break
                                }
                                if "当前过期外借欠款" == strongSelf.getText(nodeText) {
                                    isNext = true
                                }
                            }
                            
                        }
                    }
                }
                
                strongSelf.refreshControl.endRefreshing()
                strongSelf.navigationController?.navigationBarHidden = false
                
                strongSelf.shouldShowCVs = true
                strongSelf.collectionView.reloadData()
            }
        }
    }
    
    // MARK: segue
    var dstUrl: String?
    var dstTitle: String?
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toDetail" {
            if let dvc = segue.destinationViewController as? LibraryDetailViewController {
                dvc.url = self.dstUrl
                dvc.title = self.dstTitle
            }
        }
    }

}

extension LibraryMainViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if shouldShowCVs {
            return 1
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return LibraryMainCollectionData.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LibraryMainCollectionViewCell", forIndexPath: indexPath) as! LibraryMainCollectionViewCell
        cell.itemLabel.text = LibraryMainCollectionData[indexPath.row]["item"]
        cell.detailLabel.text = LibraryMainCollectionData[indexPath.row]["detail"]
        
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
        if let url = LibraryMainCollectionData[indexPath.row]["url"] {
            if "" != url {
                let cell = collectionView.cellForItemAtIndexPath(indexPath) as! LibraryMainCollectionViewCell
                if cell.detailLabel.text == "0" {
                    return
                }
                self.dstUrl = url
                self.dstTitle = LibraryMainCollectionData[indexPath.row]["item"]
                self.performSegueWithIdentifier("toDetail", sender: self)
            }
        }
    }
}








