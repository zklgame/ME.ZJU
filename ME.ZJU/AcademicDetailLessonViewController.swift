//
//  AcademicDetailLessonViewController.swift
//  ME.ZJU
//
//  Created by zklgame on 6/19/16.
//  Copyright © 2016 Zhejiang University. All rights reserved.
//

import UIKit

import Alamofire
import Kanna

class AcademicDetailLessonViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var semesterBtns: [UIButton]!
    
    @IBAction func changeSemester(sender: UIButton) {
        semesterIndex = sender.tag
        for btn in semesterBtns {
            btn.backgroundColor = UIColor.clearColor()
        }
        sender.backgroundColor = UIColor(red: 0, green: 204.0/255, blue: 1, alpha: 1)
        
        self.tableView.reloadData()
    }
    
    var url: String?
    var cellIdentifier: String?
    var semesterIndex = 1
    var shouldShowCells = false
    
    var lessonData = [Int : Dictionary<Int, Dictionary<Int, Dictionary<String, String>>>]()
    
    func initLessonData() {
        // 短，春，夏
        for i in 0 ..< 3 {
            self.lessonData[i] = Dictionary<Int, Dictionary<Int, Dictionary<String, String>>>()
            // 周一 - 周日
            for j in 0 ..< 7 {
                self.lessonData[i]?[j] = Dictionary<Int, Dictionary<String, String>>()
                // 第1节 - 第14节
                for k in 0 ..< 14 {
                    self.lessonData[i]?[j]?[k] = Dictionary<String, String>()
                }
            }
        }
    }
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initLessonData()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = CGFloat(0)
        
        self.tableView.addSubview(refreshControl)
        
        if let url = url, studentId = self.getAcaStudentId() {
            for data in AcademicMainCollectionData {
                if url == data["url"] {
                    self.url = URLs.acaBase + url + studentId
                    if let cellIdentifier = data["cellIdentifier"] {
                        self.cellIdentifier = cellIdentifier
                        
                        if CellIdentifier.lesson == self.cellIdentifier {
                            self.tableView.estimatedRowHeight = CGFloat(127)
                        }
                        
                        self.refreshControl.beginRefreshing()
                        self.getData()
                        
                        break
                    }
                }
            }
        }
    }
    
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
    
    // MARK: get data
    func getData2(viewstate: String) {
        let (year, month) = self.getCurrentYearMonth()
        let postYear = "\(year - 1)-\(year)"

        var postMonthValue = "2|春、夏"
        if (month >= 8) {
            postMonthValue = "1|秋、冬"
            for btn in self.semesterBtns {
                if 1 == btn.tag {
                    btn.setTitle("秋", forState: .Normal)
                } else if 2 == btn.tag {
                    btn.setTitle("冬", forState: .Normal)
                }
            }
        }
        
        Alamofire.request(.POST, self.url!, parameters: [
            "__VIEWSTATE": viewstate,
            "__EVENTTARGET": "xnd",
            "__EVENTARGUMENT": "",
            "xnd": postYear,
            "xqd": postMonthValue,
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
//                                    for i in 1 ..< trs.count {
                                        var singleData = Dictionary<String, String>()
                                        
                                        let tds = tr.css("td")
                                        
                                        var j = 0
                                        
                                        if strongSelf.cellIdentifier == CellIdentifier.lesson {
                                            j += 1
                                            if let text = tds[j].text {
                                                singleData["lesson"] = strongSelf.getText(text)
                                                j += 1
                                            }
                                            if let html = tds[j].at_css("a")?.innerHTML {
                                                let components = strongSelf.getText(html).componentsSeparatedByString("<br>")
                                                var teachers = ""
                                                let count = components.count
                                                for i in 0 ..< count - 1 {
                                                    teachers += components[i] + ", "
                                                }
                                                teachers += components[count - 1]
                                                
                                                singleData["teacher"] = teachers
                                                j += 1
                                                
                                            }
                                            var timeComponents = [String](), placeComponents = [String]()
                                            var semester: String = ""
                                            
                                            if let text = tds[j].text {
                                                semester = strongSelf.getText(text)
                                                j += 1
                                            }
                                            
                                            if let html = tds[j].innerHTML {
                                                timeComponents = strongSelf.getText(html).componentsSeparatedByString("<br>")
                                                j += 1
                                                
                                            }
                                            if let html = tds[j].innerHTML {
                                                placeComponents = strongSelf.getText(html).componentsSeparatedByString("<br>")
                                                j += 1
                                            }
                                            
                                            if ([""] == timeComponents || [""] == placeComponents) {
                                                continue
                                            }
                                            
                                            let timePlaceArray = strongSelf.getLessonTimePlace(timeComponents, places: placeComponents)
                                            for item in timePlaceArray {
                                                let day = item.0 / 100
                                                let classTime = item.0 % 100
                                                singleData["place"] = item.1
                                                if semester.containsString("短") {
                                                    strongSelf.lessonData[0]?[day]?[classTime]? = singleData
                                                }
                                                if semester.containsString("秋") || semester.containsString("春") {
                                                    strongSelf.lessonData[1]?[day]?[classTime]? = singleData
                                                }
                                                if semester.containsString("冬") || semester.containsString("夏") {
                                                    strongSelf.lessonData[2]?[day]?[classTime]? = singleData
                                                }
                                                
                                            }
                                        }
                                    }
                                    break
                                }
                            }
                        }
                    }
                    
                    strongSelf.refreshControl.endRefreshing()
                    strongSelf.refreshControl.removeFromSuperview()
                    strongSelf.shouldShowCells = true
                    strongSelf.tableView.reloadData()
                    
                }
        }
    }
    
    func getLessonTimePlace(times: [String], places: [String]) -> [(Int, String)] {
        var result = [(Int, String)]()
        let count = times.count
        for i in 0 ..< count {
            var day = 8
            if times[i].containsString("周一") {
                day = 1
            } else if times[i].containsString("周二") {
                day = 2
            } else if times[i].containsString("周三") {
                day = 3
            } else if times[i].containsString("周四") {
                day = 4
            } else if times[i].containsString("周五") {
                day = 5
            } else if times[i].containsString("周六") {
                day = 6
            } else if times[i].containsString("周日") {
                day = 7
            }
            
            let range = times[i].startIndex.advancedBy(3) ..< times[i].endIndex.predecessor()
            let numberString = times[i].substringWithRange(range)
            let numbers = numberString.componentsSeparatedByString(",")
            for number in numbers {
                if let a = Int(number) {
                    var place: String
                    if i >= places.count {
                        place = places.last!
                    } else {
                        place = places[i]
                    }
                    result.append((day * 100 + a, place))
                }
            }
        }
        return result
    }
}


extension AcademicDetailLessonViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.shouldShowCells {
            return 1
        }
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 13
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cellIdentifier = self.cellIdentifier {
            if cellIdentifier == CellIdentifier.lesson {
                let cell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! AcademicDetailLessonCell
                
                let weekday = self.getCurrentWeekday()
                let todayData = self.lessonData[self.semesterIndex]?[weekday]
                if let data = todayData {
                    if let item = data[indexPath.row + 1] {
                        let classTime = self.getClassTime(indexPath.row + 1)
                        cell.classTimeLabel.text = "第\(indexPath.row + 1)节 " + classTime
                        cell.lessonLabel.text = item["lesson"]
                        cell.teacherLabel.text = item["teacher"]
                        cell.placeLabel.text = item["place"]
                        
                        return cell
                    }
                }
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let weekday = self.getCurrentWeekday()
        let todayData = self.lessonData[self.semesterIndex]?[weekday]
        var lessonNum = 0
        if let data = todayData {
            for item in data.values {
                if item != [:] {
                    lessonNum += 1
                }
            }
        }
        let weekString = self.getWeekString(weekday)
        if lessonNum != 0 {
            return "今天是星期\(weekString)，共\(lessonNum)节课，加油！"
        } else {
            return "今天是星期\(weekString)，无课。"
        }
    }

}








