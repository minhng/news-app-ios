//
//  BusinessTableViewCell.swift
//  NewsApp
//
//  Created by Minh Nguyen  on 5/5/20.
//  Copyright © 2020 Minh Nguyen . All rights reserved.
//

import UIKit

protocol BusinessTableViewCellDelegate {
    func buttonTapped(cell: BusinessTableViewCell)
}

class BusinessTableViewCell: UITableViewCell {

    var delegate: BusinessTableViewCellDelegate?
    @IBOutlet weak var businessThumbnail: UIImageView!
    @IBOutlet weak var businessTitle: UILabel!
    @IBOutlet weak var businessTime: UILabel!
    @IBOutlet weak var businessSection: UILabel!
    @IBOutlet weak var businessBookmark: UIButton!
    
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


