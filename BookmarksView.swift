//
//  BookmarksView.swift
//  NewsApp
//
//  Created by Minh Nguyen  on 5/6/20.
//  Copyright © 2020 Minh Nguyen . All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner
import Kingfisher


class BookmarksView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, BookmarksCollectionViewCellDelegate {
    
    @IBOutlet weak var bookmarksCollection: UICollectionView!
    var jsonDetails: Any?
    var news = [News]()
    var newsCount: Int = 0
    var bookmarkStored: [String: Any]?
    var userDefault = UserDefaults.standard
    var isBookmarked = [Bool](repeating: false, count: 50)

    @IBOutlet weak var noBookmarks: UIView!
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
          let padding: CGFloat =  50
          let collectionViewSize = collectionView.frame.size.width - padding

          return CGSize(width: collectionViewSize/2, height: collectionViewSize/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.newsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookmarksCollectionViewCell", for: indexPath) as? BookmarksCollectionViewCell  else {
            fatalError("The dequeued cell is not an instance of BookmarksCollectionViewCell.")
        }
        let favData = Array(bookmarkStored!)[indexPath.row].value as! [String: String]
        cell.backgroundColor = UIColor.systemGray5
        cell.layer.borderColor = UIColor.systemGray5.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        cell.delegate = self
        
        cell.bookmarksTitle.text = favData["title"]
        cell.bookmarksSection.text = favData["section"]
        if favData["image"]!.isEmpty {
            cell.bookmarksThumbnail.image = UIImage(named: "default-guardian")
        } else {
            let url = URL(string: favData["image"]!)
            cell.bookmarksThumbnail.kf.setImage(with: url)
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let newsDate = formatter.date(from: favData["date"]!)
        formatter.dateFormat = "dd MMM yyyy"
        cell.bookmarksTime.text = formatter.string(from: newsDate!)
        cell.bookmarksBookmark.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let favData = Array(bookmarkStored!)[indexPath.row]
        let params:Parameters = [
            "id": favData.key
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
                DispatchQueue.main.async(execute: self.bookmarksCollection.reloadData)
            }
            case .failure(let error):
                print(error)
            }
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
//        let item = news[indexPath.section]
//
//        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
//            // Create an action for sharing
//            let share = UIAction(title: "Share with Twitter", image: UIImage(named: "twitter")) { action in
//                print("Sharing \(item)")
//                let csci = "CSCI_571_NewsApp"
//                let twitString = "https://theguardian.com/"+item.id
//                let twitURL = "https://twitter.com/intent/tweet?text=\(twitString)&hashtags=\(csci)"
//                UIApplication.shared.open(NSURL(string: twitURL)! as URL)
//            }
//            let bookmark = UIAction(title: "Bookmark", image: UIImage(systemName: "bookmark")) { action in
//                self.contextTapped(index: indexPath.section)
//                print("Bookmarking \(item)")
//            }
//            return UIMenu(title: "Menu", children: [share, bookmark])
//        }
//    }
    
    func contextTapped(index: Int) {
        if self.isBookmarked[index] {
            removeFavorite(cellResult: self.news[index])
        } else {
            setFavorite(cellResult: self.news[index])
        }
        self.isBookmarked[index] = !self.isBookmarked[index]
        DispatchQueue.main.async(execute: self.bookmarksCollection.reloadData)
    }
    
     func setFavorite(cellResult: News) {
        let title = cellResult.title
        let news_id = cellResult.id
        let image = cellResult.image
        let section = cellResult.section
        let date = cellResult.date
        self.view.window?.makeToast("Article bookmarked. Check out the Bookmarks tab to view", duration: 3.0, position: .bottom)
        let bookData = ["title": title, "image": image, "section": section, "date": date]
        self.bookmarkStored![news_id] = bookData
        userDefault.set(self.bookmarkStored, forKey: "bookmark")
    }
//
    func removeFavorite(cellResult: News) {
        let news_id = cellResult.id
        self.view.window?.makeToast("Article removed from Bookmarks", duration: 3.0, position: .bottom)
        self.bookmarkStored?.removeValue(forKey: news_id)
        userDefault.set(self.bookmarkStored, forKey: "bookmark")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadBookmarks()
        bookmarksCollection.dataSource = self
        bookmarksCollection.delegate = self
    }
    
    func buttonTapped(cell: BookmarksCollectionViewCell) {
        let index = self.bookmarksCollection.indexPath(for: cell)!
        self.view.makeToast("Article removed from Bookmarks", duration: 3.0, position: .bottom)
//        print("debug: ", index, Array(self.bookmarkStored!), Array(self.bookmarkStored!)[index.row].key)
        self.bookmarkStored!.removeValue(forKey: Array(self.bookmarkStored!)[index.row].key)
        userDefault.set(self.bookmarkStored, forKey: "bookmark")
//        self.newsCount -= 1
        loadBookmarks()
        DispatchQueue.main.async(execute: self.bookmarksCollection.reloadData)
        
    }
    
    func loadBookmarks() {
        self.bookmarkStored = (userDefault.object(forKey: "bookmark") as? [String: Any])!
        self.newsCount = (bookmarkStored!.count)
        if bookmarkStored == nil {
            bookmarkStored = [:]
        }
        if self.newsCount == 0 {
            self.noBookmarks.isHidden = false
        } else {
            self.noBookmarks.isHidden = true
        }
        DispatchQueue.main.async(execute: self.bookmarksCollection.reloadData)
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
