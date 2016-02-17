//
//  DeckBuilder.swift
//  BlackJack
//
//  Created by Benjamin Daughety on 1/24/16.
//  Copyright © 2016 Benjamin Daughety. All rights reserved.
//

import Foundation
import UIKit
import GameplayKit

class DeckBuilder {
    var singleDeck = [AnyObject]()
    var initDeck = [AnyObject]()
    let defaultNumberOfDecks: Int = 7
    
    init(numberOfDecks: Int?) {
        if numberOfDecks != nil {
            initDeck = createAndShuffleDeck(numberOfDecks)
        } else {
            initDeck = createAndShuffleDeck(defaultNumberOfDecks)
        }
    }
    
    private func createAndShuffleDeck(numberOfDecks: Int?) -> [AnyObject] {
        var finalNumber: Int = defaultNumberOfDecks
        
        if numberOfDecks != nil {
            finalNumber = numberOfDecks!
        }
        
        var deck = [AnyObject]()
        var tempDeck = [Card]()
        
        for index in 0..<52 {
            var suitIndex: Int
            
            if index < 13 {
                suitIndex = index
                tempDeck.append(Card(suit: Suits.Spades, position: index, score: getScoreByIndex(suitIndex)))
            } else if index < 26 {
                suitIndex = index - 13
                tempDeck.append(Card(suit: Suits.Clubs, position: index, score: getScoreByIndex(suitIndex)))
            } else if index < 39 {
                suitIndex = index - 26
                tempDeck.append(Card(suit: Suits.Diamonds, position: index, score: getScoreByIndex(suitIndex)))
            } else {
                suitIndex = index - 39
                tempDeck.append(Card(suit: Suits.Hearts, position: index, score: getScoreByIndex(suitIndex)))
            }
        }
        
        singleDeck = tempDeck
        
        for _ in 1...finalNumber {
            for card in tempDeck {
                deck.append(card)
            }
        }
        
        return GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(deck)
    }
    
    func getScoreByIndex(index: Int) -> Int {
        var score: Int
        switch index {
        case 0 : score = 11
        case 10, 11, 12 : score = 10
        default : score = index + 1
        }
        return score
    }
    
    func findCardByPosition(position: Int) -> Card? {
        if singleDeck.count > 0 {
            for card in singleDeck {
                let currentCard = card as! Card
                if currentCard.position == position {
                    return currentCard
                }
            }
        }
        return nil
    }
    
    func findCardByImageName(imageName: String) -> Card? {
        if singleDeck.count > 0 {
            for card in singleDeck {
                let currentCard = card as! Card
                if currentCard.name == imageName {
                    return currentCard
                }
            }
        }
        return nil
    }
    
}