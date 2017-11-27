//
//  ArtistTableViewCell.swift
//  DiscogsDatabase
//
//  Created by Andy on 27/11/2017.
//  Copyright © 2017 Andy. All rights reserved.
//

import UIKit

class ArtistTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var thumbnailView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
