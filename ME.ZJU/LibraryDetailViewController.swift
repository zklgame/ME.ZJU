//
//  LibraryDetailViewController.swift
//  ME.ZJU
//
//  Created by zklgame on 6/12/16.
//  Copyright © 2016 Zhejiang University. All rights reserved.
//

import UIKit

import Alamofire
import Kanna

class LibraryDetailViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var url: String?
    var detailXib: String?
    
    // book, author, year, returnDate, fine, library, bid
    var bookData = [Dictionary<String, String>]()
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = CGFloat(0)
        
        self.tableView.addSubview(refreshControl)

        if let url = url {
            for data in LibraryMainCollectionData {
                if url == data["url"] {
                    if let xib = data["xib"] {
                        self.detailXib = xib
                        
                        if CellNib.current == self.detailXib {
                            self.tableView.estimatedRowHeight = CGFloat(238)
                        } else if CellNib.history == self.detailXib {
                            self.tableView.estimatedRowHeight = CGFloat(182)
                        } else if CellNib.appointment == self.detailXib {
                            self.tableView.estimatedRowHeight = CGFloat(294)
                        }

                        self.tableView.registerNib(UINib(nibName: xib, bundle: nil), forCellReuseIdentifier: xib)
                        
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
                
                let stringToMatch = ["著者", "题名", "出版年", "应还日期", "罚款", "分馆", "索书号"]
                var matchNum = 0
                
                if let data = data {
                    if let doc = Kanna.HTML(html: data, encoding: NSUTF8StringEncoding) {
                        for table in doc.css("table") {
                            matchNum = 0
                            
                            for th in table.css("th") {
                                if let text = th.text {
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
                                    var singleBookData = Dictionary<String, String>()

                                    let tds = tr.css("td")
                                    
                                    var j = 1
                                    
                                    if strongSelf.detailXib == CellNib.current || strongSelf.detailXib == CellNib.history {
                                        
                                        if strongSelf.detailXib == CellNib.current {
                                            j += 1
                                        }
                                        
                                        if let text = tds[j].text {
                                            singleBookData["author"] = strongSelf.getText(text)
                                            j += 1
                                        }
                                        if let text = tds[j].text {
                                            singleBookData["book"] = strongSelf.getText(text)
                                            j += 1
                                        }
                                        if let text = tds[j].text {
                                            singleBookData["year"] = strongSelf.getText(text)
                                            j += 1
                                        }
                                        
                                        if strongSelf.detailXib == CellNib.current {
                                            if let text = tds[j].text {
                                                singleBookData["returnDate"] = strongSelf.getText(text)
                                                j += 1
                                            }
                                            
                                            if let text = tds[j].text {
                                                singleBookData["fine"] = strongSelf.getText(text)
                                                j += 1
                                            }
                                            if let text = tds[j].text {
                                                singleBookData["library"] = strongSelf.getText(text)
                                                j += 1
                                            }
                                            if let text = tds[j].text {
                                                singleBookData["bid"] = strongSelf.getText(text)
                                                j += 1
                                            }
                                        } else if strongSelf.detailXib == CellNib.history {
                                            j += 2
                                            if let text = tds[j].text {
                                                singleBookData["returnDate"] = strongSelf.getText(text)
                                                j += 1
                                            }
                                            j += 2
                                            if let text = tds[j].text {
                                                singleBookData["library"] = strongSelf.getText(text)
                                                j += 1
                                            }
                                        }
                                        
                                    } else if strongSelf.detailXib == CellNib.appointment {
                                        if let text = tds[j].text {
                                            singleBookData["author"] = strongSelf.getText(text)
                                            j += 1
                                        }
                                        if let text = tds[j].text {
                                            singleBookData["book"] = strongSelf.getText(text)
                                            j += 1
                                        }
                                        if let text = tds[j].text {
                                            singleBookData["startDate"] = strongSelf.getText(text)
                                            j += 1
                                        }
                                        if let text = tds[j].text {
                                            singleBookData["endDate"] = strongSelf.getText(text)
                                            j += 1
                                        }
                                        j += 1
                                        if let text = tds[j].text {
                                            singleBookData["library"] = strongSelf.getText(text)
                                            j += 1
                                        }
                                        if let text = tds[j].text {
                                            singleBookData["requestStatus"] = strongSelf.getText(text)
                                            j += 1
                                        }
                                        if let text = tds[j].text {
                                            singleBookData["bid"] = strongSelf.getText(text)
                                            j += 1
                                        }
                                        j += 1
                                        if let text = tds[j].text {
                                            singleBookData["bookTakenAddress"] = strongSelf.getText(text)
                                            j += 1
                                        }
                                        if let text = tds[j].text {
                                            singleBookData["bookStatus"] = strongSelf.getText(text)
                                            j += 1
                                        }
                                    }
                                    
                                    strongSelf.bookData.append(singleBookData)
                                }
                                break
                            }
                        }
                    }
                }
                
                strongSelf.refreshControl.endRefreshing()
                strongSelf.refreshControl.removeFromSuperview()
                strongSelf.tableView.reloadData()
            }
        }
    }
}

extension LibraryDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let xib = self.detailXib {
            if xib == CellNib.current {
                let cell = self.tableView.dequeueReusableCellWithIdentifier(xib, forIndexPath: indexPath) as! LibraryDetailCurrentLoanCell
                
                let data = self.bookData[indexPath.row]
                cell.authorLabel.text = data["author"]
                cell.bookLabel.text = data["book"]
                cell.yearLabel.text = data["year"]
                cell.bidLabel.text = data["bid"]
                cell.libraryLabel.text = data["library"]
                cell.returnDateLabel.text = data["returnDate"]
                cell.fineLabel.text = data["fine"]
                
//                cell.author = data["author"]
//                cell.book = data["book"]
//                cell.year = data["year"]
//                cell.bid = data["bid"]
//                cell.library = data["library"]
//                cell.returnDate = data["returnDate"]
//                cell.fine = data["fine"]
                
                
                                
                return cell
            } else if xib == CellNib.history {
                let cell = self.tableView.dequeueReusableCellWithIdentifier(xib, forIndexPath: indexPath) as! LibraryDetailHistoryLoanCell
                
                let data = self.bookData[indexPath.row]
                cell.authorLabel.text = data["author"]
                cell.bookLabel.text = data["book"]
                cell.yearLabel.text = data["year"]
                cell.libraryLabel.text = data["library"]
                cell.returnDateLabel.text = data["returnDate"]
                
//                cell.author = data["author"]
//                cell.book = data["book"]
//                cell.year = data["year"]
//                cell.library = data["library"]
//                cell.returnDate = data["returnDate"]
                
                return cell
            } else if xib == CellNib.appointment {
                let cell = self.tableView.dequeueReusableCellWithIdentifier(xib, forIndexPath: indexPath) as! LibraryDetailAppointmentCell
                
                let data = self.bookData[indexPath.row]
                cell.authorLabel.text = data["author"]
                cell.bookLabel.text = data["book"]
                cell.bidLabel.text = data["bid"]
                cell.libraryLabel.text = data["library"]
                cell.startDateLabel.text = data["startDate"]
                cell.endDateLabel.text = data["endDate"]
                cell.requestStatusLabel.text = data["requestStatus"]
                cell.bookStatusLabel.text = data["bookStatus"]
                cell.bookTakenAddressLabel.text = data["bookTakenAddress"]

//                cell.author = data["author"]
//                cell.book = data["book"]
//                cell.bid = data["bid"]
//                cell.library = data["library"]
//                cell.startDate = data["startDate"]
//                cell.endDate = data["endDate"]
//                cell.requestStatus = data["requestStatus"]
//                cell.bookStatus = data["bookStatus"]
//                cell.bookTakenAddress = data["bookTakenAddress"]
                
                return cell
            }
            
        }
        
        return UITableViewCell()
    }
    
}








