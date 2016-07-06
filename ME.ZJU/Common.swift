//
//  LoginDelegate.swift
//  ME.ZJU
//
//  Created by zklgame on 6/11/16.
//  Copyright © 2016 Zhejiang University. All rights reserved.
//

import Foundation

struct  URLs {
    static let libLogin = "http://webpac.zju.edu.cn:80/F"
    static let acaBase = "http://jwbinfosys.zju.edu.cn/"
    static let acaLogin = acaBase + "default2.aspx"
    static let acaQuery = acaBase + "xsmain_cx.htm?dqszj="
}

struct Defaults {
    static let libStudentId = "lib student id"
    static let libPassword = "lib password"
    
    static let acaStudentId = "aca student id"
    static let acaPassword = "aca password"
}

struct ErrorMsg {
    static let network = "网络异常\n请联网后重试"
}

struct CellNib {
    static let current = "LibraryDetailCurrentLoanCell"
    static let history = "LibraryDetailHistoryLoanCell"
    static let appointment = "LibraryDetailAppointmentCell"
}

struct CellIdentifier {
    static let achievement = "AcademicDetailAchievementCell"
    static let lesson = "AcademicDetailLessonCell"
    static let achievementHeader = "AcademicDetailAchievementHeader"
}

struct SegueIdentifier {
    static let achievement = "toDetailAchievement"
    static let lesson = "toDetailLesson"
}

var LibraryMainCollectionData = [
    ["item": "外借", "detail": "", "url": "", "key": "bor-loan", "xib": CellNib.current],
    ["item": "借阅历史", "detail": "", "url": "", "key": "bor-history-loan", "xib": CellNib.history],
    ["item": "预约请求", "detail": "", "url": "", "key": "bor-hold", "xib": CellNib.appointment],
    ["item": "当前欠款", "detail": "", "url": "", "key": ""],
]

var AcademicMainCollectionData = [
    ["item": "个人课表", "url": "xskbcx.aspx?xh=", "cellIdentifier": "AcademicDetailLessonCell", "segueIdentifier": SegueIdentifier.lesson],
    ["item": "成绩查询", "url": "xscj.aspx?xh=", "cellIdentifier": "AcademicDetailAchievementCell", "segueIdentifier": SegueIdentifier.achievement],
]






