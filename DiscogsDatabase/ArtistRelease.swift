//
//  ArtistRelease.swift
//  DiscogsDatabase
//
//  Created by Andy on 30/11/2017.
//  Copyright © 2017 Andy Chukavin. All rights reserved.
//

import Foundation
import UIKit

struct ArtistRelease {
    let artist: String?
    let type: String?
    let title: String?
    let year: Int?
    let thumbnailUrl: URL?
    var thumbnailImage: UIImage?
    let url: URL?
}
