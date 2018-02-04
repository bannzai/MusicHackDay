//
//  Structures.swift
//  MusicHackDayApp
//
//  Created by Yudai.Hirose on 2018/02/04.
//  Copyright © 2018年 廣瀬雄大. All rights reserved.
//

import UIKit
import SwiftyJSON

struct Sound {
    var id: Int
    var url: String
    var name: String
    var artistName: String
    var imageUrl: String

    var mp3URL: String?
    
    init(
        id: Int,
        url: String,
        name: String,
        artistName: String,
        imageUrl: String
        ) {
        self.id = id
        self.url = url
        self.name = name
        self.artistName = artistName
        self.imageUrl = imageUrl
    }
    
    init(
        json: JSON
        ) {
        self.init(
            id: json["sound_id"].int!,
            url: json["sound_url"].string!,
            name: json["sound_name"].string!,
            artistName: json["artist_name"].string!,
            imageUrl: json["sound_image_url"].string!
        )
    }
}

class PartnerImageView: UIImageView {
    
}

struct Neighbour {
    var artist_name: String
    var sound_url: String
    var sound_name: String
    var distance: Int
    var lat: Double
    var lon: Double
    var token: String
    
    init(artist_name: String,
         sound_url: String,
         sound_name: String,
         distance: Int,
         lat: Double,
         lon: Double,
         token: String) {
        self.artist_name = artist_name
        self.sound_url = sound_url
        self.sound_name = sound_name
        self.distance = distance
        self.lat = lat
        self.lon = lon
        self.token = token
    }
}
