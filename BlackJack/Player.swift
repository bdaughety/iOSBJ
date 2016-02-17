//
//  Player.swift
//  BlackJack
//
//  Created by Benjamin Daughety on 1/24/16.
//  Copyright © 2016 Benjamin Daughety. All rights reserved.
//

import Foundation

class Player {
    var hands: [Hand]
    var bank: Double
    
    init() {
        hands = [Hand]()
        bank = Double.init()
    }
}