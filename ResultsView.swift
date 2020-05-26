//
//  ResultsView.swift
//  NewsApp
//
//  Created by Minh Nguyen  on 5/4/20.
//  Copyright © 2020 Minh Nguyen . All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner
import Kingfisher

class ResultsView: UIViewController, UITableViewDelegate, UITableViewDataSource, ResultsTableViewCellDelegate {
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadRefreshedData), for: .valueChanged)
        return refreshControl
    }()
    
    @objc
    func loadRefreshedData() {
        loadSampleNews()
        refresher.endRefreshing()
    }
    
    func setFavorite(cellResult: News) {
            let title = cellResult.title
            let news_id = cellResult.id
            let image = cellResult.image
            let section = cellResult.section
            let date = cellResult.date
            self.view.makeToast("Article bookmarked. Check out the Bookmarks tab to view", duration: 3.0, position: .bottom)
            let bookData = ["title": title, "image": image, "section": section, "date": date]
            self.bookmarkStored![news_id] = bookData
            userDefault.set(self.bookmarkStored, forKey: "bookmark")
        }
    //
        func removeFavorite(cellResult: News) {
            let news_id = cellResult.id
            self.view.makeToast("Article removed from Bookmarks", duration: 3.0, position: .bottom)
            self.bookmarkStored?.removeValue(forKey: news_id)
            userDefault.set(self.bookmarkStored, forKey: "bookmark")
        }
        
        func buttonTapped(cell: ResultsTableViewCell) {
            let index = self.resultsTable.indexPath(for: cell)!.section
            if self.isBookmarked[index] {
                removeFavorite(cellResult: self.news[index])
            } else {
                setFavorite(cellResult: self.news[index])
            }
            self.isBookmarked[index] = !self.isBookmarked[index]
            DispatchQueue.main.async(execute: self.resultsTable.reloadData)
        }
        
        func contextTapped(index: Int) {
            if self.isBookmarked[index] {
                removeFavorite(cellResult: self.news[index])
            } else {
                setFavorite(cellResult: self.news[index])
            }
            self.isBookmarked[index] = !self.isBookmarked[index]
            DispatchQueue.main.async(execute: self.resultsTable.reloadData)
        }
        
        func checkBookmark() {
            self.isBookmarked = [Bool](repeating: false, count: 50)
            if let savedKeys = self.bookmarkStored?.keys {
                for (index, data) in (self.news.enumerated()) {
                    if savedKeys.contains(data.id) {
                        self.isBookmarked[index] = true
                    }
                }
            }
        }
    
    let cellSpacingHeight: CGFloat = 5
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.news.count
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ResultsTableViewCell", for: indexPath) as? ResultsTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ResultsTableViewCell.")
        }
        let new = news[indexPath.section]
        cell.backgroundColor = UIColor.systemGray5
        cell.layer.borderColor = UIColor.systemGray5.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        cell.delegate = self
        
        cell.resultsTitle.text = new.title
        if new.image.isEmpty {
            cell.resultsThumbnail.image = UIImage(named: "default-guardian")
        } else {
            let url = URL(string: new.image)
            cell.resultsThumbnail.kf.setImage(with: url)
        }
        cell.resultsSection.text = new.section
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let newsDate = formatter.date(from: new.date)!
        
        let elapsedTime = currentDate.timeIntervalSince(newsDate)
        // convert from seconds to hours, rounding down to the nearest hour
        let hours = floor(elapsedTime / 60 / 60)
        let minutes = floor((elapsedTime - (hours * 60 * 60)) / 60)
        let seconds = floor((elapsedTime - (hours * 60 * 60)) / 60 / 60)
        if (hours != 0) {
            cell.resultsTime.text = String(Int(hours))+"h ago"
        } else if (minutes != 0) {
            cell.resultsTime.text = String(Int(minutes))+"m ago"
        } else {
            cell.resultsTime.text = String(Int(seconds))+"s ago"
        }
        if isBookmarked[indexPath.section]{
            cell.resultsBookmark.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        } else {
            cell.resultsBookmark.setImage(UIImage(systemName: "bookmark"), for: .normal)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let new = news[indexPath.section]
            let params:Parameters = [
                "id": new.id
            ]
            SwiftSpinner.show("Loading Detailed Article..")
            Alamofire.request("https://minh-ios-backend-9.wl.r.appspot.com/article", parameters: params).responseJSON {
                response in
                switch response.result {
                case .success: do {
                    self.jsonDetails = JSON(response.value!)
                    print("success get details")
                    self.myPerformSegue(identifier: "showDetails")
                    SwiftSpinner.hide()
                    DispatchQueue.main.async(execute: self.resultsTable.reloadData)
                }
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let item = news[indexPath.section]

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            // Create an action for sharing
            let share = UIAction(title: "Share with Twitter", image: UIImage(named: "twitter")) { action in
                print("Sharing \(item)")
                let csci = "CSCI_571_NewsApp"
                let twitString = "https://theguardian.com/"+item.id
                let twitURL = "https://twitter.com/intent/tweet?text=\(twitString)&hashtags=\(csci)"
                UIApplication.shared.open(NSURL(string: twitURL)! as URL)
            }
            let bookmark = UIAction(title: "Bookmark", image: UIImage(systemName: "bookmark")) { action in
                self.contextTapped(index: indexPath.section)
                print("Bookmarking \(item)")
            }
            return UIMenu(title: "Menu", children: [share, bookmark])
        }
    }

    @IBOutlet weak var resultsTable: UITableView!
    var data: AnyObject?
    var jsonDetails: Any?
    var news = [News]()
    var isBookmarked = [Bool](repeating: false, count: 50)
    var result: NSArray?
    var bookmarkStored: [String: Any]?
    var userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        loadSampleNews()
//        resultsTable.delegate = self
//        resultsTable.dataSource = self
//        setUpNavBar()
//        resultsTable.refreshControl = refresher
//        bookmarkStored = userDefault.object(forKey: "bookmark") as? [String: Any]
//        if bookmarkStored == nil {
//            bookmarkStored = [:]
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSampleNews()
        resultsTable.delegate = self
        resultsTable.dataSource = self
        setUpNavBar()
        resultsTable.refreshControl = refresher
    }
    
    func setUpNavBar() {
        navigationItem.title = "Search Results"
    }
    
    private func loadSampleNews() {
        let jsonResponse = JSON(data!)["response"]["results"].arrayValue
        for result in jsonResponse {
            let newsTitle = result["webTitle"].stringValue
            let urlArray = result["blocks"]["main"]["elements"][0]["assets"].arrayValue
//            let urlArray = jsonResponse["blocks"]["main"]["elements"][0]["assets"].arrayValue
            var newsThumbnail = ""
            if !(urlArray.endIndex==0 || urlArray[urlArray.endIndex-1]["file"].stringValue.isEmpty) {
                newsThumbnail = urlArray[urlArray.endIndex-1]["file"].stringValue
            }
//            let newsThumbnail = result["fields"]["thumbnail"].stringValue
            let newsSection = result["sectionName"].stringValue
            let newsDate = result["webPublicationDate"].stringValue
            let newsId = result["id"].stringValue
            guard let new = News(title: newsTitle, image: newsThumbnail, section: newsSection, date: newsDate, id: newsId) else {
                fatalError("Unable to instantiate meal1")
            }
            var tempFlag = false
            for i in self.news {
                if i.id == newsId {
                    tempFlag = true
                }
            }
            if !tempFlag {
                self.news += [new]
            }
        }
        self.bookmarkStored = self.userDefault.object(forKey: "bookmark") as? [String: Any]
        if self.bookmarkStored == nil {
            self.bookmarkStored = [:]
        }
        self.checkBookmark()
        DispatchQueue.main.async(execute: self.resultsTable.reloadData)

    }
        

    private func myPerformSegue(identifier: String) {
        performSegue(withIdentifier: identifier, sender: send)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            let detailView: DetailView = segue.destination as! DetailView
            detailView.data = self.jsonDetails as AnyObject
        }
    }
}
