//
//  Card.swift
//  BlackJack
//
//  Created by Benjamin Daughety on 1/18/16.
//  Copyright © 2016 Benjamin Daughety. All rights reserved.
//

import Foundation
import UIKit

class Card: AnyObject {
    
    var suit: Suits
    var position: Int
    var image: UIImage?
    var score: Int
    var name: String
    
    init(suit: Suits, position: Int, score: Int) {
        self.suit = suit
        self.position = position
        self.image = UIImage(named: CardsEnum.allValues[position].rawValue)!
        self.score = score
        self.name = CardsEnum.allValues[position].rawValue
    }
    
}