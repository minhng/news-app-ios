//
//  ViewController.swift
//  NewsApp
//
//  Created by Minh Nguyen  on 4/16/20.
//  Copyright © 2020 Minh Nguyen . All rights reserved.
//
import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation
import SwiftSpinner
import Kingfisher

class DetailView: UIViewController {

    @IBOutlet weak var detailTitle: UILabel!
    @IBOutlet weak var detailImage: UIImageView!
    @IBOutlet weak var detailDate: UILabel!
    @IBOutlet weak var detailSection: UILabel!
    @IBOutlet weak var detailDescription: UILabel!
    var data: AnyObject?
    var urlString: String?
    var jsonImgString: String = ""
    var isBookmarked: Bool = false
    var bookmarkStored: [String: Any]?
    var bookmarkId: String?
    var userDefault = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let jsonResponse = JSON(data!)["response"]["content"]
        self.bookmarkId = jsonResponse["id"].stringValue
        self.navigationItem.title = jsonResponse["webTitle"].stringValue
        self.urlString = jsonResponse["webUrl"].stringValue
        checkBookmark()
        setUpNavbar()

        self.detailTitle.text = jsonResponse["webTitle"].stringValue
        let urlArray = jsonResponse["blocks"]["main"]["elements"][0]["assets"].arrayValue
        if (urlArray.endIndex==0 || urlArray[urlArray.endIndex-1]["file"].stringValue.isEmpty) {
            self.detailImage.image = UIImage(named: "default-guardian")
        } else {
            let imgString = urlArray[urlArray.endIndex-1]["file"].stringValue
            self.jsonImgString = imgString
            let url = URL(string: imgString)
            self.detailImage.kf.setImage(with: url)
        }
        self.detailSection.text = jsonResponse["sectionName"].stringValue
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let jsonDate = formatter.date(from: jsonResponse["webPublicationDate"].stringValue)!
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd MMM yyyy"
        let articleDate = dateFormatterPrint.string(from: jsonDate)
        self.detailDate.text = articleDate
        
        let desArray = jsonResponse["blocks"]["body"].arrayValue
        var textArray = ""
        for i in desArray {
            textArray += i["bodyHtml"].stringValue
        }
        if let labelTextFormatted = textArray.htmlToAttributedString {
            let textAttributes = [
                NSMutableAttributedString.Key.font: UIFont.systemFont(ofSize: 17)
                ] as [NSMutableAttributedString.Key: Any]
            labelTextFormatted.addAttributes(textAttributes, range: NSRange(location: 0, length: labelTextFormatted.length))
            self.detailDescription.attributedText = labelTextFormatted
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
    }
    
    func checkBookmark() {
        self.bookmarkStored = userDefault.object(forKey: "bookmark") as? [String: Any]
        if bookmarkStored == nil {
            bookmarkStored = [:]
        }
        if let savedKeys = self.bookmarkStored?.keys {
            if savedKeys.contains(self.bookmarkId!) {
                self.isBookmarked = true
            }
        }
    }
    
    func setUpNavbar() {
        self.navigationItem.largeTitleDisplayMode = .never
        let bookmarkBtn = UIBarButtonItem(image: UIImage(systemName: "bookmark"), style: .plain, target: self, action: #selector(bookmarkTapped))
        if isBookmarked {
            bookmarkBtn.image = UIImage(systemName: "bookmark.fill")
        }
        let twitterBtn = UIBarButtonItem(image: UIImage(named: "twitter"), style: .plain, target: self, action: #selector(twitterTapped))
        self.navigationItem.rightBarButtonItems = [twitterBtn, bookmarkBtn]
    }

     func setFavorite(cellResult: AnyObject?) {
        let jsonResponse = JSON(cellResult!)["response"]["content"]
        let title = jsonResponse["webTitle"].stringValue
        let news_id = jsonResponse["id"].stringValue
        let image = self.jsonImgString
        let section = jsonResponse["sectionName"].stringValue
        let date = jsonResponse["webPublicationDate"].stringValue
        self.view.makeToast("Article bookmarked. Check out the Bookmarks tab to view", duration: 3.0, position: .bottom)
        let bookData = ["title": title, "image": image, "section": section, "date": date]
        self.bookmarkStored![news_id] = bookData
        userDefault.set(self.bookmarkStored, forKey: "bookmark")
    }
//
    func removeFavorite(cellResult: AnyObject?) {
        let news_id = JSON(cellResult!)["response"]["content"]["id"].stringValue
//        print("news_id: ", news_id, cellResult)
        self.view.makeToast("Article removed from Bookmarks", duration: 3.0, position: .bottom)
        self.bookmarkStored?.removeValue(forKey: news_id)
        userDefault.set(self.bookmarkStored, forKey: "bookmark")
    }
    
    @objc func bookmarkTapped() {
        if isBookmarked {
            removeFavorite(cellResult: data)
            self.isBookmarked = false
        } else {
            setFavorite(cellResult: data)
            self.isBookmarked = true
        }
        setUpNavbar()
//        self.viewWillAppear(true)
    }
    
    @objc func twitterTapped() {
        let csci = "CSCI_571_NewsApp"
        let twitURL = "https://twitter.com/intent/tweet?text=\(self.urlString!)&hashtags=\(csci)"
        UIApplication.shared.open(NSURL(string: twitURL)! as URL)
    }
    
    @IBAction func didTapView(sender: AnyObject) {
        UIApplication.shared.open(NSURL(string: self.urlString!)! as URL)
    }
}

extension String {
    var htmlToAttributedString: NSMutableAttributedString? {
        guard let data = data(using: .utf8) else { return NSMutableAttributedString() }
        do {
            return try NSMutableAttributedString(data: data, options: [.documentType: NSMutableAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSMutableAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

