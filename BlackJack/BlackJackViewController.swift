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
    @IBOutlet weak var dealButton: UIBarButtonItem!
    @IBOutlet weak var hitButton: UIBarButtonItem!
    @IBOutlet weak var standButton: UIBarButtonItem!
    @IBOutlet weak var dealerOutcomeLabel: UILabel!
    @IBOutlet weak var playerOutcomeLabel: UILabel!
    @IBOutlet weak var gameTableView: UIView!
    @IBOutlet weak var playerHandView: UIView!
    @IBOutlet weak var dealerHandView: UIView!
    @IBOutlet weak var balanceTextField: UITextField!
    @IBOutlet weak var doubleDownButton: UIBarButtonItem!
    @IBOutlet weak var splitButton: UIBarButtonItem!
    @IBOutlet weak var betTextField: UITextField!
    
    // MARK: Constants
    final let NEXT_CARD_SPACING: CGFloat = 32
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
    
    // MARK: Load and warnings
    override func viewDidLoad() {
        super.viewDidLoad()
        
        betTextField.delegate = self

        // Do any additional setup after loading the view.
        deck = deckBuilder.initDeck
        
        dealButton.enabled = false
        hitButton.enabled = false
        standButton.enabled = false
        doubleDownButton.enabled = false
        splitButton.enabled = false
        betTextField.enabled = true
        balanceTextField.enabled = false
        
        if player.bank <= MINIMUM_BET {
            player.bank = 1000
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let bet = textField.text
        dealButton.enabled = isBetValid(bet)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: Actions
    @IBAction func dealCards(sender: AnyObject) {
        clearCardImages()
        setEnableButtonsForDeal()
        setupHands()
        dealCardsAndProcessBlackjacks()
        updatePlayerBankTextField()
    }

    @IBAction func hitPlayer(sender: AnyObject) {
        updatePlayerNextCardPosition()
        hitPlayerAndUpdateUI(false)
    }
    
    @IBAction func standPlayer(sender: AnyObject) {
        player.hands[currentPlayerHandIndex].stand()
        if player.hands.count > 1 {
            currentPlayerHandIndex += 1
        }
        setEnableButtonsForPlayerStand()
        processDealerTurn()
    }
    
    @IBAction func doubleDown(sender: AnyObject) {
        let currentBet = player.hands[currentPlayerHandIndex].bet
        updatePlayerNextCardPosition()
        hitPlayerAndUpdateUI(true)
        betTextField.text = String(currentBet)
    }
    
    @IBAction func split(sender: AnyObject) {
        updatePlayerHandsForSplit()
        updateUIForSplit()
    }
    
    // MARK: Supporting Actions
    
    func updatePlayerHandsForSplit() {
        let currentHand = player.hands[currentPlayerHandIndex]
        let newSplitHand = Hand()
        
        newSplitHand.hit(currentHand.cards.popLast()!)
        currentHand.hit(deck.popLast() as! Card)
        newSplitHand.hit(deck.popLast() as! Card)
    }
    
    func updateUIForSplit() {
        let currentHandView = UIView()
        let newSplitHandView = UIView()
        let currentHandFirstCardImageView = UIImageView()
        let currentHandSecondCardImageView = UIImageView()
        let newSplitHandFirstCardImageView = UIImageView()
        let newSplitHandSecondCardImageView = UIImageView()
        
        currentHandView
        
        gameTableView.addSubview(newSplitHandView)
    }
    
    func isDoubleDownEnabled() -> Bool {
        let currentBet = player.hands[currentPlayerHandIndex].bet
        if currentBet > player.bank {
            return false
        }
        return true
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
            betTextField.text = String(playerHand.bet)
        } else {
            playerHand.hit(hitCard)
        }
        hitCardImageView.image = hitCard.image
        hitCardImageView.frame = playerFirstCard.frame.offsetBy(dx: playerNextCardPosition, dy: 0)
        allCardImages.append(hitCardImageView)
        
        hitCardImageView.startAnimating()
        playerHandView.addSubview(hitCardImageView)
        hitCardImageView.stopAnimating()
        
        playerScoreLabel.text = String(playerHand.determineFinalScore())
        
        if playerHand.busted || playerHand.standing {
            hitButton.enabled = false
            standButton.enabled = false
            dealButton.enabled = true
            doubleDownButton.enabled = false
            splitButton.enabled = false
            dealButton.titleTextAttributesForState(UIControlState.Selected)
            
            dealerScoreLabel.text = String(dealerHand.determineFinalScore())
            dealerSecondCard.image = dealerHand.cards[1].image
            
            if playerHand.busted {
                dealerOutcomeLabel.text = WIN
                playerOutcomeLabel.text = LOSE
            } else if playerHand.determineFinalScore() == BLACK_JACK || doubleDown {
                processDealerTurn()
            }
            betTextField.enabled = true
        }
    }
    
    func clearCardImages() {
        allCardImages.append(playerFirstCard)
        allCardImages.append(dealerFirstCard)
        allCardImages.append(playerSecondCard)
        allCardImages.append(dealerSecondCard)
        
        for imageView in allCardImages {
            imageView.image = nil
        }
        allCardImages.removeAll()
    }
    
    func isBetValid(bet: String?) -> Bool {
        if let currentBet: Double = Double(betTextField.text!)! {
            return currentBet >= MINIMUM_BET
        }
        return false
    }
    
    func processDealerTurn() {
        dealerSecondCard.image = dealerHand.cards[1].image
        dealerScoreLabel.text = String(dealerHand.determineFinalScore())
        dealerNextCardPosition = 0.0
        
        while !isDealerStanding(dealerHand) {
            if dealerNextCardPosition.isZero {
                dealerNextCardPosition += NEXT_CARD_SPACING
            }
            dealerNextCardPosition += NEXT_CARD_SPACING
            
            let hitCardImageView = UIImageView()
            let hitCard = deck.popLast() as! Card
            
            dealerHand.hit(hitCard)
            hitCardImageView.image = hitCard.image
            hitCardImageView.frame = dealerFirstCard.frame.offsetBy(dx: dealerNextCardPosition, dy: 0)
            allCardImages.append(hitCardImageView)
            
            dealerHandView.addSubview(hitCardImageView)
            
            dealerScoreLabel.text = String(dealerHand.determineFinalScore())
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
        betTextField.enabled = true
    }
    
    func isDealerStanding(dealerHand: Hand) -> Bool {
        let dealerScore = dealerHand.determineFinalScore()
        
        if dealerScore >= 17 {
            dealerHand.stand()
            return true
        }
        
        return false
    }
    
    func setEnableButtonsForDeal() {
        dealButton.enabled = false
        hitButton.enabled = true
        standButton.enabled = true
        splitButton.enabled = false
        doubleDownButton.enabled = true
    }
    
    func setEnableButtonsForPlayerStand() {
        hitButton.enabled = false
        standButton.enabled = false
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
        let playerHand = Hand()
        
        playerHand.bet = Double(betTextField.text!)!
        player.bank -= playerHand.bet
        betTextField.enabled = false
        
        var currentCard = deck.popLast() as! Card
        playerHand.hit(currentCard)
        animateCardBeingDealt(playerFirstCard, cardImage: currentCard.image!, delay: 0.0)
        
        currentCard = deck.popLast() as! Card
        dealerHand.hit(currentCard)
        animateCardBeingDealt(dealerFirstCard, cardImage: currentCard.image!, delay: 0.5)
        dealerScoreLabel.text = String(dealerHand.determineFinalScore())
        
        currentCard = deck.popLast() as! Card
        playerHand.hit(currentCard)
        animateCardBeingDealt(playerSecondCard, cardImage: currentCard.image!, delay: 1.0)
        
        currentCard = deck.popLast() as! Card
        dealerHand.hit(currentCard)
        animateCardBeingDealt(dealerSecondCard, cardImage: backOfCardImage!, delay: 1.5)
        
        player.hands.append(playerHand)
        doubleDownButton.enabled = isDoubleDownEnabled()
        
        if playerHand.hasBlackJack() {
            dealerScoreLabel.text = String(dealerHand.determineFinalScore())
            dealerSecondCard.image = dealerHand.cards[1].image
            
            hitButton.enabled = false
            standButton.enabled = false
            dealButton.enabled = true
            doubleDownButton.enabled = false
            splitButton.enabled = false
            dealButton.titleTextAttributesForState(UIControlState.Selected)
            
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
            betTextField.enabled = true
        } else if dealerHand.hasBlackJack() {
            // TODO: add insurance
            dealerScoreLabel.text = String(dealerHand.determineFinalScore())
            dealerSecondCard.image = dealerHand.cards[1].image
            
            hitButton.enabled = false
            standButton.enabled = false
            dealButton.enabled = true
            doubleDownButton.enabled = false
            splitButton.enabled = false
            dealButton.titleTextAttributesForState(UIControlState.Selected)
            
            dealerOutcomeLabel.text = WIN
            playerOutcomeLabel.text = LOSE
            betTextField.enabled = true
        }
    }
    
    func updatePlayerBankTextField() {
        balanceTextField.text = "$" + String(player.bank)
    }
    
    func animateCardBeingDealt(image: UIImageView, cardImage: UIImage, delay: Double) {
        image.center.x += view.bounds.width
        image.image = cardImage
        
        UIView.animateWithDuration(
            0.5,
            delay: delay,
            options: [],
            animations: {
                image.center.x -= self.view.bounds.width
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
