//
//  HomeTableViewCell.swift
//  NewsApp
//
//  Created by Minh Nguyen  on 4/19/20.
//  Copyright © 2020 Minh Nguyen . All rights reserved.
//

import UIKit

protocol HomeTableViewCellDelegate {
    func buttonTapped(cell: HomeTableViewCell)
}

class HomeTableViewCell: UITableViewCell {

    var delegate: HomeTableViewCellDelegate?
    @IBOutlet weak var homeThumbnail: UIImageView!
    @IBOutlet weak var homeSection: UILabel!
    @IBOutlet weak var homeTitle: UILabel!
    @IBOutlet weak var homeTime: UILabel!
    @IBOutlet weak var homeBookmark: UIButton!
    
    @IBAction func setBookmark(_ sender: UIButton) {
//        print("bookmark")
        self.delegate?.buttonTapped(cell: self)
    }
//    @IBAction func setfavorite(_ sender: Any) {
//        print("like")
//        self.delegate?.buttonTapped(cell: self)
//    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

}

