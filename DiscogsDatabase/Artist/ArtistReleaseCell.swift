//
//  ArtistReleaseCell.swift
//  DiscogsDatabase
//
//  Created by Andy on 06/10/2018.
//  Copyright © 2018 Andy Chukavin. All rights reserved.
//

import Foundation


import UIKit

class ArtistReleaseCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var thumbnailView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
