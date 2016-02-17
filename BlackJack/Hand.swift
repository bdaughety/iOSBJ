//
//  Hand.swift
//  BlackJack
//
//  Created by Benjamin Daughety on 1/23/16.
//  Copyright © 2016 Benjamin Daughety. All rights reserved.
//

import Foundation

class Hand {
    final let BLACK_JACK: Int = 21
    
    var busted: Bool
    var cards: [Card]
    var score: Int
    var standing: Bool
    var aceCount: Int
    var bet: Double
    
    init() {
        self.busted = false
        self.cards = [Card]()
        self.score = 0
        self.standing = false
        self.aceCount = 0
        self.bet = 0
    }
    
    func hit(card: Card) {
        if let cardHitting: Card = card {
            self.cards.append(cardHitting)
            self.score += card.score
            if card.name.containsString("Ace") {
                self.aceCount++
            }
        }
        
        determineBusted()
    }
    
    func determineBusted() {
        if hasAce() {
            if self.score >= 31 {
                stand()
                if self.score > 31 {
                    self.busted = true
                }
            } else if self.score == 21 {
                stand()
            }
        } else if self.score >= 21 {
            stand()
            if self.score > 21 {
                self.busted = true
            }
        }
    }
    
    func hasAce() -> Bool {
        for card in self.cards {
            if card.name.containsString("Ace") {
                return true
            }
        }
        return false
    }
    
    func stand() {
        self.standing = true
    }
    
    func hasBlackJack() -> Bool {
        return cards.count == 2 && score == 21
    }
    
    func determineFinalScore() -> Int {
        if !hasAce() || hasBlackJack() {
            return score
        }
        
        var finalScore = score
        
        for _ in 0..<aceCount {
            if finalScore > BLACK_JACK {
                finalScore -= 10
            }
        }
        
        return finalScore
    }
    
    func doubleDown(card: Card) {
        bet += bet
        stand()
        hit(card)
    }
}