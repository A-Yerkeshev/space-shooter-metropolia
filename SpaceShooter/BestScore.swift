//
//  BestScore.swift
//  SpaceShooter
//
//  Created by Anna Lindén on 5.12.2024.
//
import Foundation
import SwiftData

@Model
class BestScore {
    var name: String
    var score: Int
    var date: Date

    init(name: String, score: Int, date: Date) {
        self.name = name
        self.score = score
        self.date = date
    }
}


