//
//  PoliticsTableViewCell.swift
//  NewsApp
//
//  Created by Minh Nguyen  on 5/5/20.
//  Copyright © 2020 Minh Nguyen . All rights reserved.
//

import UIKit

protocol PoliticsTableViewCellDelegate {
    func buttonTapped(cell: PoliticsTableViewCell)
}

class PoliticsTableViewCell: UITableViewCell {
    
    var delegate: PoliticsTableViewCellDelegate?
    @IBOutlet weak var politicsThumbnail: UIImageView!
    @IBOutlet weak var politicsTitle: UILabel!
    @IBOutlet weak var politicsTime: UILabel!
    @IBOutlet weak var politicsSection: UILabel!
    
    @IBOutlet weak var politicsBookmark: UIButton!
    @IBAction func setBookmark(_ sender: UIButton) {
        self.delegate?.buttonTapped(cell: self)
    }

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
