//
//  AcademicDetailViewController.swift
//  ME.ZJU
//
//  Created by zklgame on 6/17/16.
//  Copyright © 2016 Zhejiang University. All rights reserved.
//

import UIKit

import Alamofire
import Kanna

class AcademicDetailAchievementViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var url: String?
    var cellIdentifier: String?
    
    var data = Dictionary<Int, [Dictionary<String, String>]> ()

    var maxDataKey = 0
    
    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = CGFloat(0)
        self.tableView.estimatedSectionHeaderHeight = CGFloat(0)
        
        self.tableView.addSubview(refreshControl)
        
        if let url = url, studentId = self.getAcaStudentId() {
            for data in AcademicMainCollectionData {
                if url == data["url"] {
                    self.url = URLs.acaBase + url + studentId
                    if let cellIdentifier = data["cellIdentifier"] {
                        self.cellIdentifier = cellIdentifier
                        
                        if CellIdentifier.achievement == self.cellIdentifier {
                            self.tableView.estimatedRowHeight = CGFloat(99)
                            self.tableView.estimatedSectionHeaderHeight = CGFloat(69)
                        }
                        
                        self.refreshControl.beginRefreshing()
                        self.getData()
                        
                        break
                    }
                }
            }
        }
    }
    
    // MARK: get data
    func getData() {
        Alamofire.request(.GET, self.url!).response {[weak self] (_, _, data, error) in
            if let strongSelf = self {
                if nil != error {
                    strongSelf.simpleAlert(ErrorMsg.network)
                    return
                }
                
                if let data = data {
                    let enc = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
                    if let doc = Kanna.HTML(html: data, encoding: enc) {
                        for input in doc.css("input") {
                            if let name = input["name"], value = input["value"] {
                                if name == "__VIEWSTATE" {
                                    strongSelf.getData2(value)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getData2(viewstate: String) {
        Alamofire.request(.POST, self.url!, parameters: [
            "__VIEWSTATE": viewstate,
            "Button2": "在校学习成绩查询",
            ], encoding: .URL, headers: nil).response {[weak self] (_, _, data, error) in
            if let strongSelf = self {
                if nil != error {
                    strongSelf.simpleAlert(ErrorMsg.network)
                    return
                }

                let stringToMatch = ["选课课号", "课程名称", "成绩", "学分", "绩点", "课程代码", "教师姓名", "学期", "上课时间", "上课地点"]
                var matchNum = 0
                
                if let data = data {
                    let enc = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
                    if let doc = Kanna.HTML(html: data, encoding: enc) {
                        for table in doc.css("table") {
                            matchNum = 0
                            
                            for td in table.css("td") {
                                if let text = td.text {
                                    for i in 0 ..< stringToMatch.count {
                                        if strongSelf.getText(text) == stringToMatch[i] {
                                            matchNum += 1
                                            break
                                        }
                                    }
                                }

                                if matchNum >= 3 {
                                    break
                                }
                            }

                            if matchNum >= 3 {
                                let trs = table.css("tr")
                                
                                var isFirstTr = true
                                for tr in trs {
                                    if isFirstTr {
                                        isFirstTr = false
                                        continue
                                    }
//                                for i in 1 ..< trs.count {
                                    var singleData = Dictionary<String, String>()

                                    let tds = tr.css("td")

                                    var j = 0

                                    if strongSelf.cellIdentifier == CellIdentifier.achievement {
                                        var achievementTime = 0

                                        if let text = tds[j].text {
                                            let sereis = strongSelf.getText(text)
                                            
                                            let rangeOfYear = sereis.startIndex.advancedBy(1) ..< sereis.startIndex.advancedBy(5)
                                            let rangeOfSemester = sereis.startIndex.advancedBy(11) ..< sereis.startIndex.advancedBy(12)
                                            
                                            if let year = Int(sereis.substringWithRange(rangeOfYear)), semester = Int(sereis.substringWithRange(rangeOfSemester)) {
                                                achievementTime = year * 10 + semester
                                                j += 1
                                            } else {
                                                return
                                            }
                                        }

                                        if let text = tds[j].text {
                                            singleData["lesson"] = strongSelf.getText(text)
                                            j += 1
                                        }
                                        
                                        j += 1
                                        if let text = tds[j].text {
                                            singleData["credit"] = strongSelf.getText(text)
                                            j += 1
                                        }
                                        if let text = tds[j].text {
                                            singleData["score"] = strongSelf.getText(text)
                                            j += 1
                                        }
                                        
                                        if strongSelf.data[achievementTime] == nil {
                                            strongSelf.data[achievementTime] = [Dictionary<String, String>]()
                                        }
                                        strongSelf.data[achievementTime]?.append(singleData)

                                    }
                                }
                                break
                            }
                        }
                    }
                }
                
                var isFirst = true
                for key in strongSelf.data.keys {
                    if isFirst {
                        strongSelf.maxDataKey = key
                        isFirst = false
                    }
                    if strongSelf.maxDataKey < key {
                        strongSelf.maxDataKey = key
                    }
                }
                strongSelf.refreshControl.endRefreshing()
                strongSelf.refreshControl.removeFromSuperview()
                strongSelf.tableView.reloadData()
                
            }
        }
    }
}


extension AcademicDetailAchievementViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return data.keys.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let a = section / 2
        let b = section % 2
        let key = self.maxDataKey - a * 10 - b
        
        if let datas = self.data[key] {
            return datas.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cellIdentifier = self.cellIdentifier {
            if cellIdentifier == CellIdentifier.achievement {
                let cell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! AcademicDetailAchievementCell

                let a = indexPath.section / 2
                let b = indexPath.section % 2
                let key = self.maxDataKey - a * 10 - b
                
                if let data = self.data[key]?[indexPath.row] {
                    cell.lessonLabel.text = data["lesson"]
                    if let credit = data["credit"] {
                        cell.creditLabel.text = credit + " 学分"
                    }
                    cell.scoreLabel.text = data["score"]
                }

                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.cellIdentifier == CellIdentifier.achievement {
            let a = section / 2
            let b = section % 2
            let key = self.maxDataKey - a * 10 - b
            var avgScore = 0.0
            var credits = 0.0
            var semesterString = ""
            var lessonCount = 0

            if let datas = self.data[key] {
                lessonCount = datas.count
                for data in datas {
                    if let credit = data["credit"], score = data["score"] {
                        if let dCredit = Double(credit), dScore = Double(score) {
                            avgScore += dCredit * dScore
                            credits += dCredit
                        }
                    }
                }
                avgScore /= credits
            }

            let year = key / 10
            let semester = key % 10
            if 1 == semester {
                semesterString = "\(year)年 秋冬学期"
            } else{
                semesterString = "\(year)年 春夏学期"
            }
            let avgScoreString = NSString(format: "%.2f", avgScore)

            let headerCell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.achievementHeader) as! AcademicDetailAchievementHeader
            headerCell.semesterLabel.text = semesterString
            headerCell.infoLabel.text = "课程数量:\(lessonCount), 总学分:\(credits), 均绩:\(avgScoreString)"
            
            headerCell.backgroundColor = UIColor(red: CGFloat(153.0 / 255), green: CGFloat(153.0 / 255), blue: CGFloat(153.0 / 255), alpha: 1)
            return headerCell
        }
        return nil
    }
}








