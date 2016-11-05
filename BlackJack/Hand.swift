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
    
    func hit(_ card: Card) {
        if let cardHitting: Card = card {
            self.cards.append(cardHitting)
            self.score += card.score
            if card.name.contains("Ace") {
                self.aceCount += 1
            }
        }
        
        determineBusted()
        if determineFinalScore() == 21 {
            stand()
        }
    }
    
    func determineBusted() {
        if determineFinalScore() > 21 {
            stand()
            self.busted = true
        }
    }
    
    func hasAce() -> Bool {
        for card in self.cards {
            if card.name.contains("Ace") {
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
    
    func doubleDown(_ card: Card) {
        bet += bet
        stand()
        hit(card)
    }
    
    func getLastCardForSplit() -> Card {
        let card = cards.popLast()!
        updateScore()
        return card
    }
    
    func updateScore() {
        var updatedScore = 0
        for card in cards {
            updatedScore += card.score
        }
        score = updatedScore
    }
}
