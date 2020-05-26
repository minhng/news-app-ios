//
//  BookmarksCollectionViewCell.swift
//  NewsApp
//
//  Created by Minh Nguyen  on 5/6/20.
//  Copyright © 2020 Minh Nguyen . All rights reserved.
//

import UIKit

protocol BookmarksCollectionViewCellDelegate {
    func buttonTapped(cell: BookmarksCollectionViewCell)
}

class BookmarksCollectionViewCell: UICollectionViewCell {
    
    var delegate: BookmarksCollectionViewCellDelegate?
    @IBOutlet weak var bookmarksThumbnail: UIImageView!
    @IBOutlet weak var bookmarksTitle: UILabel!
    @IBOutlet weak var bookmarksTime: UILabel!
    @IBOutlet weak var bookmarksSection: UILabel!
    @IBOutlet weak var bookmarksBookmark: UIButton!
    
    @IBAction func setBookmark(_ sender: UIButton) {
        self.delegate?.buttonTapped(cell: self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
    }
    
}
