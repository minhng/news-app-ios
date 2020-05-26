//
//  WorldTableViewCell.swift
//  NewsApp
//
//  Created by Minh Nguyen  on 5/5/20.
//  Copyright © 2020 Minh Nguyen . All rights reserved.
//

import UIKit

protocol WorldTableViewCellDelegate {
    func buttonTapped(cell: WorldTableViewCell)
}

class WorldTableViewCell: UITableViewCell {

    var delegate: WorldTableViewCellDelegate?
    @IBOutlet weak var worldThumbnail: UIImageView!
    @IBOutlet weak var worldTitle: UILabel!
    @IBOutlet weak var worldTime: UILabel!
    @IBOutlet weak var worldSection: UILabel!
    @IBOutlet weak var worldBookmark: UIButton!
    
    @IBAction func setBookmark(_ sender: UIButton) {
        self.delegate?.buttonTapped(cell: self)
    }
    //    @IBOutlet weak var homeBookmark: UIButton!
//
//    @IBAction func setBookmark(_ sender: UIButton) {
//        print("bookmark")
//        self.delegate?.buttonTapped(cell: self)
//    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

