//
//  BlackJackTests.swift
//  BlackJackTests
//
//  Created by Benjamin Daughety on 12/27/15.
//  Copyright © 2015 Benjamin Daughety. All rights reserved.
//

import XCTest
@testable import BlackJack

class BlackJackTests: XCTestCase {
    
    var viewController = BlackJackViewController()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(withIdentifier: "BlackJackVC") as! BlackJackViewController
        
        _ = viewController.view // force loading subviews and setting outlets
        
        viewController.viewDidLoad()
//        viewController.betTextField.text = "100.00"
        buildMinimumTestDeck()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMultipleAcesInOneHand() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let deckBuilder = viewController.deckBuilder
        viewController.deck.append(deckBuilder.findCardByImageName(CardsEnum.Ace_of_Hearts.rawValue)!)
        viewController.deck.append(deckBuilder.findCardByImageName(CardsEnum.Ace_of_Hearts.rawValue)!)
        viewController.deck.append(deckBuilder.findCardByImageName(CardsEnum.Ten_of_Diamonds.rawValue)!)
        viewController.deck.append(deckBuilder.findCardByImageName(CardsEnum.Six_of_Hearts.rawValue)!)
        viewController.deck.append(deckBuilder.findCardByImageName(CardsEnum.Three_of_Clubs.rawValue)!)
        viewController.deck.append(deckBuilder.findCardByImageName(CardsEnum.Jack_of_Spades.rawValue)!)
        
        viewController.dealCards(UIBarButtonItem())
        viewController.standPlayer(UIBarButtonItem())
        
        assert(viewController.dealerOutcomeLabel.text == "Win")
        assert(viewController.playerOutcomeLabel.text == "Lose")
    }
    
    func testPlayerAutoStandOnTwentyOne() {
        viewController.deck.append(viewController.deckBuilder.findCardByImageName(CardsEnum.Five_of_Clubs.rawValue)!)
        viewController.deck.append(viewController.deckBuilder.findCardByImageName(CardsEnum.Ten_of_Diamonds.rawValue)!)
        viewController.deck.append(viewController.deckBuilder.findCardByImageName(CardsEnum.Five_of_Clubs.rawValue)!)
        viewController.deck.append(viewController.deckBuilder.findCardByImageName(CardsEnum.Seven_of_Clubs.rawValue)!)
        viewController.deck.append(viewController.deckBuilder.findCardByImageName(CardsEnum.Ace_of_Hearts.rawValue)!)
        
        viewController.dealCards(UIBarButtonItem())
        viewController.hitPlayer(UIBarButtonItem())
        
        assert(viewController.player.hands[0].standing)
        assert(viewController.dealerOutcomeLabel.text == "Lose")
        assert(viewController.playerOutcomeLabel.text == "Win")
    }
    
    func buildMinimumTestDeck() {
        viewController.deck = [AnyObject]()
        for _ in 0..<26 {
            viewController.deck.append(viewController.deckBuilder.findCardByImageName(CardsEnum.Two_of_Diamonds.rawValue)!)
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
