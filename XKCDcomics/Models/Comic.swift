//
//  Comic.swift
//  XKCDcomics
//
//  Created by Otto A Robsahm on 15/11/2025.
//

import Foundation

// Comic data model from XKCD
struct Comic: Codable, Identifiable {
    let num: Int
    let title: String
    let img: String
    let alt: String
    let transcript: String
    let day: String
    let month: String
    let year: String

    // Identifier
    var id: Int { num }

    // Convert the day-month-year string into a Swift Date object.
    var date: Date? {
        let dateString = "\(year)-\(month)-\(day)"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-M-d"
        return formatter.date(from: dateString)
    }
}
