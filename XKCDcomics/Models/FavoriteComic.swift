//
//  FavoriteComic.swift
//  XKCDcomics
//
//  Created by Otto A Robsahm on 15/11/2025.
//

import Foundation
import SwiftData

// Persistent storage model for favorited comics
@Model
final class FavoriteComic {
    @Attribute(.unique) var num: Int
    var title: String
    var img: String
    var alt: String
    var transcript: String
    var day: String
    var month: String
    var year: String
    var savedDate: Date
    @Attribute(.externalStorage) var imageData: Data?

    init(
        num: Int,
        title: String,
        img: String,
        alt: String,
        transcript: String,
        day: String,
        month: String,
        year: String,
        imageData: Data? = nil
    ) {
        self.num = num
        self.title = title
        self.img = img
        self.alt = alt
        self.transcript = transcript
        self.day = day
        self.month = month
        self.year = year
        self.savedDate = Date()
        self.imageData = imageData
    }

    // Create from Comic struct
    convenience init(from comic: Comic, imageData: Data? = nil) {
        self.init(
            num: comic.num,
            title: comic.title,
            img: comic.img,
            alt: comic.alt,
            transcript: comic.transcript,
            day: comic.day,
            month: comic.month,
            year: comic.year,
            imageData: imageData
        )
    }

    // Convert back to Comic struct
    func toComic() -> Comic {
        Comic(
            num: num,
            title: title,
            img: img,
            alt: alt,
            transcript: transcript,
            day: day,
            month: month,
            year: year
        )
    }
}