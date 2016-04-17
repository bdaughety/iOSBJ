//
//  BlackJackViewController.swift
//  BlackJack
//
//  Created by Benjamin Daughety on 1/18/16.
//  Copyright © 2016 Benjamin Daughety. All rights reserved.
//

import UIKit
import GameplayKit

class BlackJackViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var playerFirstCard: UIImageView!
    @IBOutlet weak var playerSecondCard: UIImageView!
    @IBOutlet weak var playerScoreLabel: UILabel!
    @IBOutlet weak var dealerFirstCard: UIImageView!
    @IBOutlet weak var dealerSecondCard: UIImageView!
    @IBOutlet weak var dealerScoreLabel: UILabel!
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet weak var hitButton: UIButton!
    @IBOutlet weak var standButton: UIButton!
    @IBOutlet weak var dealerOutcomeLabel: UILabel!
    @IBOutlet weak var playerOutcomeLabel: UILabel!
    @IBOutlet weak var gameTableView: UIView!
    @IBOutlet weak var balanceTextField: UITextField!
    @IBOutlet weak var doubleDownButton: UIButton!
    @IBOutlet weak var splitButton: UIButton!
    @IBOutlet weak var betLabel: UILabel!
    
    // MARK: Constants
    final let NEXT_CARD_SPACING: CGFloat = 16
    final let TWENTY_ONE_WITH_ACE: Int = 31
    final let BLACK_JACK: Int = 21
    final let MINIMUM_DECK_SIZE: Int = 26
    final let MINIMUM_BET: Double = 10
    final let PUSH: String = "Push"
    final let WIN: String = "Win"
    final let LOSE: String = "Lose"
    final let EMPTY_TEXT: String = ""
    
    // MARK: Properties
    var deck: [AnyObject] = []
    var playerNextCardPosition: CGFloat = 0.0
    var dealerNextCardPosition: CGFloat = 0.0
    let player = Player()
    var dealerHand = Hand()
    var currentPlayerHandIndex: Int = 0
    var allCardImages = [UIImageView]()
    let backOfCardImage = UIImage(named: "Back of Card")
    var dealerButtonTitleAttributesNormal: [String : AnyObject] = ["" : ""]
    var dealerButtonTitleAttributesSelected: [String : AnyObject] = ["" : ""]
    var deckBuilder: DeckBuilder = DeckBuilder(numberOfDecks: nil) // default number of decks = 7
    var tempDealButton: UIButton = UIButton()
    let splitHandOneFirstCardImageView = UIImageView()
    let splitHandOneSecondCardImageView = UIImageView()
    let splitHandTwoFirstCardImageView = UIImageView()
    let splitHandTwoSecondCardImageView = UIImageView()
    
    // MARK: Load and warnings
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        deck = deckBuilder.initDeck
        
        dealButton.enabled = true
        hitButton.enabled = false
        standButton.enabled = false
        doubleDownButton.enabled = false
        splitButton.enabled = false
        balanceTextField.enabled = false
        
        if player.bank <= MINIMUM_BET {
            player.bank = 1000
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var animateClearCards = false
    
    // MARK: Actions
    @IBAction func dealCards(sender: AnyObject) {
        setEnableButtonsForDeal()
        setupHands()
        dealCardsAndProcessBlackjacks()
        updatePlayerBankTextField()
//        clearCardImages()
    }

    @IBAction func hitPlayer(sender: AnyObject) {
        updatePlayerNextCardPosition()
        hitPlayerAndUpdateUI(false)
    }
    
    @IBAction func standPlayer(sender: AnyObject) {
        player.hands[currentPlayerHandIndex].stand()
        if currentPlayerHandIndex + 1 != player.hands.count {
            currentPlayerHandIndex += 1
            playerNextCardPosition = 0
        } else {
            setEnableButtonsForPlayerStand()
            processDealerTurn()
        }
    }
    
    @IBAction func doubleDown(sender: AnyObject) {
        let currentBet = player.hands[currentPlayerHandIndex].bet
        updatePlayerNextCardPosition()
        hitPlayerAndUpdateUI(true)
        betLabel.text = String(currentBet)
    }
    
    @IBAction func split(sender: AnyObject) {
        updatePlayerHandsForSplit()
        updateUIForSplit()
    }
    
    // MARK: Supporting Actions
    
    func updatePlayerHandsForSplit() {
        let newSplitHand = Hand()
        
        newSplitHand.hit(player.hands[currentPlayerHandIndex].getLastCardForSplit())
        player.hands[currentPlayerHandIndex].hit(deck.popLast() as! Card)
        newSplitHand.hit(deck.popLast() as! Card)
        
        player.hands.append(newSplitHand)
    }
    
    func updateUIForSplit() {
        splitHandOneFirstCardImageView.image = player.hands[currentPlayerHandIndex].cards[0].image
        splitHandOneSecondCardImageView.image = player.hands[currentPlayerHandIndex].cards[1].image
        splitHandOneFirstCardImageView.frame = playerFirstCard.frame.offsetBy(dx: -50, dy: 0)
        splitHandOneSecondCardImageView.frame = playerSecondCard.frame.offsetBy(dx: -50, dy: 0)
        
        splitHandTwoFirstCardImageView.image = player.hands[currentPlayerHandIndex + 1].cards[0].image
        splitHandTwoSecondCardImageView.image = player.hands[currentPlayerHandIndex + 1].cards[1].image
        splitHandTwoFirstCardImageView.frame = playerFirstCard.frame.offsetBy(dx: 50, dy: 0)
        splitHandTwoSecondCardImageView.frame = playerSecondCard.frame.offsetBy(dx: 50, dy: 0)
        
        allCardImages.append(splitHandOneFirstCardImageView)
        allCardImages.append(splitHandOneSecondCardImageView)
        allCardImages.append(splitHandTwoFirstCardImageView)
        allCardImages.append(splitHandTwoSecondCardImageView)
        
        gameTableView.addSubview(splitHandOneFirstCardImageView)
        gameTableView.addSubview(splitHandOneSecondCardImageView)
        gameTableView.addSubview(splitHandTwoFirstCardImageView)
        gameTableView.addSubview(splitHandTwoSecondCardImageView)
        
        // TODO: animate cards for split
        animateCardForSplit(splitHandOneFirstCardImageView, cardFrom: playerFirstCard, delay: 0)
        animateCardForSplit(splitHandTwoFirstCardImageView, cardFrom: playerSecondCard, delay: 0.5)
        animateCardBeingDealt(splitHandOneSecondCardImageView, cardImage: splitHandOneSecondCardImageView.image!, delay: 1)
        animateCardBeingDealt(splitHandTwoSecondCardImageView, cardImage: splitHandTwoSecondCardImageView.image!, delay: 1.5)
        
        playerFirstCard.image = nil
        playerSecondCard.image = nil
    }
    
    func animateCardForSplit(card: UIImageView, cardFrom: UIImageView, delay: Double) {
        let centerX = card.center.x
        let centerY = card.center.y
        card.center.x = cardFrom.center.x
        card.center.y = cardFrom.center.y
        
        UIView.animateWithDuration(
            0.5,
            delay: delay,
            options: [],
            animations: {
                card.center.x = centerX
                card.center.y = centerY
            },
            completion: nil)
    }
    
    func isDoubleDownEnabled() -> Bool {
        let currentBet = player.hands[currentPlayerHandIndex].bet
        if currentBet > player.bank {
            return false
        }
        return true
    }
    
    func playerHasSplit() -> Bool {
        return player.hands.count > 1
    }
    
    func updatePlayerNextCardPosition() {
        playerNextCardPosition += playerNextCardPosition.isZero ? NEXT_CARD_SPACING + NEXT_CARD_SPACING : NEXT_CARD_SPACING
    }
    
    func hitPlayerAndUpdateUI(doubleDown: Bool) {
        let hitCard = deck.popLast() as! Card
        let hitCardImageView = UIImageView()
        let playerHand = player.hands[currentPlayerHandIndex]
        
        if doubleDown {
            player.bank -= playerHand.bet
            balanceTextField.text = "$" + String(player.bank)
            playerHand.doubleDown(hitCard)
            betLabel.text = String(playerHand.bet)
        } else {
            playerHand.hit(hitCard)
        }
        
        if playerHasSplit() {
            if currentPlayerHandIndex == 0 {
                hitCardImageView.frame = splitHandOneFirstCardImageView.frame.offsetBy(dx: playerNextCardPosition, dy: playerNextCardPosition * -1)
            } else if currentPlayerHandIndex == 1 {
                hitCardImageView.frame = splitHandTwoFirstCardImageView.frame.offsetBy(dx: playerNextCardPosition, dy: playerNextCardPosition * -1)
            }
        } else {
            hitCardImageView.frame = playerFirstCard.frame.offsetBy(dx: playerNextCardPosition, dy: playerNextCardPosition * -1)
        }
        allCardImages.append(hitCardImageView)
        
        gameTableView.addSubview(hitCardImageView)
        animateCardBeingDealt(hitCardImageView, cardImage: hitCard.image!, delay: 0.0)
        
        playerScoreLabel.text = String(playerHand.determineFinalScore())
        
        if playerHand.busted || playerHand.standing {
            if currentPlayerHandIndex + 1 != player.hands.count {
                currentPlayerHandIndex += 1
                playerNextCardPosition = 0
            } else {
                setEnableButtonsForPlayerStand()
                
                dealerScoreLabel.text = String(dealerHand.determineFinalScore())
                dealerSecondCard.image = dealerHand.cards[1].image
                
                if playerHand.busted {
                    dealerOutcomeLabel.text = WIN
                    playerOutcomeLabel.text = LOSE
                } else if playerHand.determineFinalScore() == BLACK_JACK || doubleDown {
                    processDealerTurn()
                }
                betLabel.enabled = true
            }
        }
    }

    func clearCardImages() {
        for imageView in allCardImages {
            imageView.removeFromSuperview()
        }
        
        allCardImages.removeAll()
    }
    
    func animateCardsForClear(card: UIImageView) {
        UIView.animateWithDuration(
            0.5,
            delay: 0,
            options: [],
            animations: {
                card.center.y -= self.view.bounds.height
            },
            completion: nil)
    }
    
    func isBetValid(bet: String?) -> Bool {
        if let currentBet: Double = Double(betLabel.text!)! {
            return currentBet >= MINIMUM_BET
        }
        return false
    }
    
    func processDealerTurn() {
        dealerSecondCard.image = dealerHand.cards[1].image
        dealerScoreLabel.text = String(dealerHand.determineFinalScore())
        dealerNextCardPosition = 0.0
        var dealerHitCards: [UIImageView] = []
        
        while !isDealerStanding(dealerHand) {
            if dealerNextCardPosition.isZero {
                dealerNextCardPosition += NEXT_CARD_SPACING
            }
            dealerNextCardPosition += NEXT_CARD_SPACING
            
            let hitCardImageView = UIImageView()
            let hitCard = deck.popLast() as! Card
            
            dealerHand.hit(hitCard)
            hitCardImageView.frame = dealerFirstCard.frame.offsetBy(dx: dealerNextCardPosition, dy: 0)
            allCardImages.append(hitCardImageView)
            dealerHitCards.append(hitCardImageView)
            
            gameTableView.addSubview(hitCardImageView)
            
            dealerScoreLabel.text = String(dealerHand.determineFinalScore())
        }
        
        var delay = 0.0
        var index = 2
        if (dealerHitCards.count > 0) {
            for hitCardImageView in dealerHitCards {
                animateCardBeingDealt(hitCardImageView, cardImage: dealerHand.cards[index].image!, delay: delay)
                delay += 0.5
                index += 1
            }
        }
        
        // TODO: add label for multiple player hands
        let playerHand = player.hands[currentPlayerHandIndex]
        updateOutcomeLabelTextsPlayerNotBusted(playerHand)
        
        // TODO: handle bank is empty
        if player.bank <= MINIMUM_BET {
            player.bank = 1000
        }
        
        balanceTextField.text = "$" + String(player.bank)
    }
    
    func updateOutcomeLabelTextsPlayerNotBusted(playerHand: Hand) {
        if dealerHand.busted {
            dealerOutcomeLabel.text = LOSE
            playerOutcomeLabel.text = WIN
            player.bank += round(playerHand.bet * 2)
        } else {
            let dealerActualScore = dealerHand.determineFinalScore()
            let playerActualScore = playerHand.determineFinalScore()
            
            if dealerActualScore > playerActualScore {
                dealerOutcomeLabel.text = WIN
                playerOutcomeLabel.text = LOSE
            } else if dealerActualScore < playerActualScore {
                dealerOutcomeLabel.text = LOSE
                playerOutcomeLabel.text = WIN
                player.bank += round(playerHand.bet * 2)
            } else {
                dealerOutcomeLabel.text = PUSH
                playerOutcomeLabel.text = PUSH
                player.bank += playerHand.bet
            }
        }
        betLabel.enabled = true
    }
    
    // TODO: add this to dealer object
    func isDealerStanding(dealerHand: Hand) -> Bool {
        let dealerScore = dealerHand.determineFinalScore()
        
        if dealerScore >= 17 {
            dealerHand.stand()
            return true
        }
        
        return false
    }
    
    func setEnableButtonsForDeal() {
        dealButton.hidden = true
        dealButton.enabled = false
        hitButton.enabled = true
        standButton.enabled = true
        splitButton.enabled = false
        doubleDownButton.enabled = true
    }
    
    func setEnableButtonsForPlayerStand() {
        hitButton.enabled = false
        standButton.enabled = false
        dealButton.hidden = false
        dealButton.enabled = true
        doubleDownButton.enabled = false
        splitButton.enabled = false
    }
    
    func setupHands() {
        player.hands.removeAll()
        dealerHand = Hand()
        
        currentPlayerHandIndex = 0
        playerNextCardPosition = 0.0
        dealerOutcomeLabel.text = EMPTY_TEXT
        playerOutcomeLabel.text = EMPTY_TEXT
        dealerScoreLabel.text = EMPTY_TEXT
        playerScoreLabel.text = EMPTY_TEXT
        
        if deck.count < MINIMUM_DECK_SIZE {
            deckBuilder = DeckBuilder(numberOfDecks: nil) // default number of decks = 7
            deck = deckBuilder.initDeck
        }
    }
    
    func dealCardsAndProcessBlackjacks() {
        if animateClearCards {
            let tempPlayerFirstCard = UIImageView()
            tempPlayerFirstCard.image = playerFirstCard.image
            tempPlayerFirstCard.frame = playerFirstCard.frame
            let tempDealerFirstCard = UIImageView()
            tempDealerFirstCard.image = dealerFirstCard.image
            tempDealerFirstCard.frame = dealerFirstCard.frame
            let tempPlayerSecondCard = UIImageView()
            tempPlayerSecondCard.image = playerSecondCard.image
            tempPlayerSecondCard.frame = playerSecondCard.frame
            let tempDealerSecondCard = UIImageView()
            tempDealerSecondCard.image = dealerSecondCard.image
            tempDealerSecondCard.frame = dealerSecondCard.frame
            allCardImages.append(tempPlayerFirstCard)
            allCardImages.append(tempDealerFirstCard)
            allCardImages.append(tempPlayerSecondCard)
            allCardImages.append(tempDealerSecondCard)
            gameTableView.addSubview(tempPlayerFirstCard)
            gameTableView.addSubview(tempDealerFirstCard)
            gameTableView.addSubview(tempPlayerSecondCard)
            gameTableView.addSubview(tempDealerSecondCard)
            for imageView in allCardImages {
                animateCardsForClear(imageView)
            }
        }
        
        let playerHand = Hand()
        
        playerHand.bet = Double(betLabel.text!)!
        player.bank -= playerHand.bet
        betLabel.enabled = false
        
        deck.append(deckBuilder.findCardByImageName(CardsEnum.Seven_of_Clubs.rawValue)!)
        deck.append(deckBuilder.findCardByImageName(CardsEnum.Seven_of_Hearts.rawValue)!)
        deck.append(deckBuilder.findCardByImageName(CardsEnum.Seven_of_Spades.rawValue)!)
        
        var delay = 0.0
        if (animateClearCards) {
            delay += 0.5
        }
        var currentCard = deck.popLast() as! Card
        playerHand.hit(currentCard)
        animateCardBeingDealt(playerFirstCard, cardImage: currentCard.image!, delay: delay)
        delay += 0.5
        
        currentCard = deck.popLast() as! Card
        dealerHand.hit(currentCard)
        animateCardBeingDealt(dealerFirstCard, cardImage: currentCard.image!, delay: delay)
        delay += 0.5
        dealerScoreLabel.text = String(dealerHand.determineFinalScore())
        
        currentCard = deck.popLast() as! Card
        playerHand.hit(currentCard)
        animateCardBeingDealt(playerSecondCard, cardImage: currentCard.image!, delay: delay)
        delay += 0.5
        
        currentCard = deck.popLast() as! Card
        dealerHand.hit(currentCard)
        animateCardBeingDealt(dealerSecondCard, cardImage: backOfCardImage!, delay: delay)
        delay += 0.5
        
        player.hands.append(playerHand)
        doubleDownButton.enabled = isDoubleDownEnabled()
        
        if playerHand.hasBlackJack() {
            dealerScoreLabel.text = String(dealerHand.determineFinalScore())
            dealerSecondCard.image = dealerHand.cards[1].image
            
            setEnableButtonsForPlayerStand()
            
            // TODO: add insurance
            if dealerHand.hasBlackJack() {
                dealerOutcomeLabel.text = PUSH
                playerOutcomeLabel.text = PUSH
                player.bank += playerHand.bet
            } else {
                dealerOutcomeLabel.text = LOSE
                playerOutcomeLabel.text = WIN
                player.bank += round(playerHand.bet * 2.5)
            }
            betLabel.enabled = true
        } else if dealerHand.hasBlackJack() {
            // TODO: add insurance
            dealerScoreLabel.text = String(dealerHand.determineFinalScore())
            dealerSecondCard.image = dealerHand.cards[1].image
            
            setEnableButtonsForPlayerStand()
            
            dealerOutcomeLabel.text = WIN
            playerOutcomeLabel.text = LOSE
            betLabel.enabled = true
        } else if playerHand.cards[0].score == playerHand.cards[1].score {
            splitButton.enabled = true
        }
        animateClearCards = true
    }
    
    func updatePlayerBankTextField() {
        balanceTextField.text = "$" + String(player.bank)
    }
    
    // TODO: adjust layering of cards; also the layering of the curved line
    func animateCardBeingDealt(card: UIImageView, cardImage: UIImage, delay: Double) {
        card.center.x += view.bounds.width
        card.center.y -= view.bounds.height
        card.image = cardImage
        
        UIView.animateWithDuration(
            0.5,
            delay: delay,
            options: [],
            animations: {
                card.center.x -= self.view.bounds.width
                card.center.y += self.view.bounds.height
            },
            completion: {
                (value: Bool) in
                self.playerScoreLabel.text = String(self.player.hands[self.currentPlayerHandIndex].determineFinalScore())
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
