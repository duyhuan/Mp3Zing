//
//  Song.swift
//  ZingMp3
//
//  Created by techmaster on 2/22/17.
//  Copyright © 2017 techmaster. All rights reserved.
//

import Foundation
import UIKit

struct Song {
    var title = ""
    var artist = ""
    let thumbnail: UIImage
    let baseThumbnailOnline = "http://zmp3-photo.d.za.zdn.vn/thumb/94_94/"
    var thumbnailLocal = ""
    var sourceOnline = ""
    var sourceLocal = ""
    
    init(title: String, artist: String, thumbnailOnlinePath: String, sourceOnline: String) {
        self.title = title
        self.artist = artist
        let thumbnailOnline = baseThumbnailOnline + thumbnailOnlinePath
        let dataImage = NSData(contentsOf: URL(string: thumbnailOnline)!)
        self.thumbnail = (UIImage(data: dataImage as! Data))!
        self.sourceOnline = sourceOnline
    }
    
    init(title: String, artist: String, thumbnailLocal: String, sourceLocal: String) {
        self.title = title
        self.artist = artist
        self.thumbnailLocal = thumbnailLocal
        let dataImage = NSData(contentsOfFile: thumbnailLocal)
        self.thumbnail = UIImage(data: dataImage as! Data)!
        self.sourceLocal = sourceLocal
    }
}
