//
//  SportTableViewCell.swift
//  NewsApp
//
//  Created by Minh Nguyen  on 5/5/20.
//  Copyright © 2020 Minh Nguyen . All rights reserved.
//

import UIKit

protocol SportTableViewCellDelegate {
    func buttonTapped(cell: SportTableViewCell)
}

class SportTableViewCell: UITableViewCell {

    var delegate: SportTableViewCellDelegate?
    @IBOutlet weak var sportThumbnail: UIImageView!
    @IBOutlet weak var sportTitle: UILabel!
    @IBOutlet weak var sportTime: UILabel!
    @IBOutlet weak var sportSection: UILabel!
    
    @IBOutlet weak var sportBookmark: UIButton!
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
