//
//  StatMenu.swift
//  Shaky Rocket
//
//  Created by macbook on 4/20/20.
//  Copyright © 2020 example. All rights reserved.
//

import Foundation
import SpriteKit

class StatMenu: SKShapeNode {
    
    var okButtonTapped = false

    func configure(score: Int, highScore: Int, newCoins: Int, startingCoins: Int, isUserRewarded: Bool) {
        
        let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        scoreLabel.text = "Score: 0"
        scoreLabel.name = "scoreLabel"
        scoreLabel.color = .white
        scoreLabel.fontSize = 32
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: 0, y: 50)
        addChild(scoreLabel)
        
        let highScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        highScoreLabel.text = "HighScore: \(highScore)"
        highScoreLabel.name = "highScoreLabel"
        highScoreLabel.color = .white
        highScoreLabel.fontSize = 32
        highScoreLabel.horizontalAlignmentMode = .center
        highScoreLabel.position = CGPoint(x: 0, y: 0)
        addChild(highScoreLabel)
        
        if newCoins > 0 {
            let coin1 = SKSpriteNode(imageNamed: "coin")
            coin1.name = "coin1"
            coin1.size = CGSize(width: 15, height: 15)
            coin1.position = CGPoint(x: -75, y: -60)
            addChild(coin1)
        }
        
        if startingCoins > 0 {
            let coin2 = SKSpriteNode(imageNamed: "coin")
            coin2.size = CGSize(width: 15, height: 15)
            coin2.position = CGPoint(x: 75, y: -60)
            addChild(coin2)
        }
        
        //112.5, 117.5, 125.5
        
        let coinNumber = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        coinNumber.text = "\(startingCoins)"
        coinNumber.name = "coinNumber"
        coinNumber.color = .white
        coinNumber.fontSize = 32
        coinNumber.horizontalAlignmentMode = .center
        if startingCoins >= 1000 {
            coinNumber.position = CGPoint(x: 127.5, y: -70)
        } else if startingCoins >= 100 {
            coinNumber.position = CGPoint(x: 119.5, y: -70)
        } else {
            coinNumber.position = CGPoint(x: 114.5, y: -70)
        }
        addChild(coinNumber)
        
        update(time: 0.6, score: score, highScore: highScore, number: 1, newCoins: newCoins, startingCoins: startingCoins, isUserRewarded: isUserRewarded)
    }
    
    func update(time: Double, score: Int, highScore: Int, number: Int, newCoins: Int, startingCoins: Int, isUserRewarded: Bool) {
        let defaults = UserDefaults.standard
        
        guard let url = Bundle.main.url(forResource: "ScoreIncrease", withExtension: ".wav") else {return}
        
        let scoreIncreaseSound = SKAudioNode(url: url)
        scoreIncreaseSound.autoplayLooped = false
        scoreIncreaseSound.name = "ScoreIncreaseSound"
        addChild(scoreIncreaseSound)
        
        let scoreIncreaseSound2 = SKAudioNode(url: url)
        scoreIncreaseSound2.autoplayLooped = false
        
        if number > score {
            if score > highScore {
                if let highScoreLabel = self.childNode(withName: "highScoreLabel") as? SKLabelNode {
                    highScoreLabel.text = "HighScore: \(score)"
                    let emitter1 = SKEmitterNode(fileNamed: "Confetti")!
                    emitter1.position = CGPoint(x: 200, y: 0)
                    emitter1.zPosition = -1
                    emitter1.zRotation = -CGFloat.pi/4
                    
                    let emitter2 = SKEmitterNode(fileNamed: "Confetti")!
                    emitter2.position = CGPoint(x: -200, y: 0)
                    emitter2.zPosition = -1
                    emitter2.zRotation = CGFloat.pi/4
                    
                    if defaults.bool(forKey: "soundFXOn") {
                        if let url = Bundle.main.url(forResource: "Cheers", withExtension: ".wav") {
                            let cheers = SKAudioNode(url: url)
                            cheers.autoplayLooped = false
                            addChild(cheers)
                            cheers.run(SKAction.play())
                        }
                    }
                    
                    addChild(emitter1)
                    addChild(emitter2)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
                        [weak self] in
                        
                        if newCoins > 0 {
                            self?.sendCoin(newCoins: newCoins, startingCoins: startingCoins)
                        } else {
                            self?.showButton()
                        }
                    })
                    //here bruh
                    return
                }
            } else {
            
            if newCoins > 0 {
                sendCoin(newCoins: newCoins, startingCoins: startingCoins)
            } else {
                showButton()
            }
            //here bruh
            return
            }
        }
        
        let wait = SKAction.wait(forDuration: 0.25)
        
        let removeNode = SKAction.customAction(withDuration: 0.01, actionBlock: {
            [] _,_ in
            
            scoreIncreaseSound.removeFromParent()
        })
        
        let sequence = SKAction.sequence([SKAction.play(), wait, removeNode])
        
        if time > 0.01 {
            DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
                [weak self] in
                if let scoreLabel = self?.childNode(withName: "scoreLabel") as? SKLabelNode {
                    scoreLabel.text = "Score: \(number)"
                    if defaults.bool(forKey: "soundFXOn") {
                        scoreIncreaseSound.run(sequence)
                    }
                    
                    if number < score/2 {
                        self?.update(time: time*0.85, score: score, highScore: highScore, number: number + 1, newCoins: newCoins, startingCoins: startingCoins, isUserRewarded: isUserRewarded)
                    } else {
                        self?.update(time: time*(1/0.85), score: score, highScore: highScore, number: number + 1, newCoins: newCoins, startingCoins: startingCoins, isUserRewarded: isUserRewarded)
                    }
                }
            })
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
                [weak self] in
                if let scoreLabel = self?.childNode(withName: "scoreLabel") as? SKLabelNode {
                    scoreLabel.text = "Score: \(number)"
                    if defaults.bool(forKey: "soundFXOn") {
                        scoreIncreaseSound.run(sequence)
                    }
                    
                    if number < score/2 {
                        self?.update(time: time*0.85, score: score, highScore: highScore, number: number + 1, newCoins: newCoins, startingCoins: startingCoins, isUserRewarded: isUserRewarded)
                    } else {
                        self?.update(time: time*(1/0.85), score: score, highScore: highScore, number: number + 1, newCoins: newCoins, startingCoins: startingCoins, isUserRewarded: isUserRewarded)
                    }
                }
            })
        }
    }
    
    func addCoin() {
        let coin = SKSpriteNode(imageNamed: "coin")
        coin.size = CGSize(width: 15, height: 15)
        coin.position = CGPoint(x: -75, y: -60)
        coin.name = "coin"
        addChild(coin)
    }
    
    func sendCoin(newCoins: Int, startingCoins: Int) {
        let defaults = UserDefaults.standard
        
        if newCoins > 1 {
            addCoin()
        } else if newCoins == 1 {
            addCoin()
            childNode(withName: "coin1")?.removeFromParent()
        } else {
            showButton()
            return
        }
        
        guard let coin = childNode(withName: "coin") as? SKSpriteNode else {return}
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -75, y: -60))
        path.addQuadCurve(to: CGPoint(x: 75, y: -60), control: CGPoint(x: 0, y: 0))
        
        let follow = SKAction.follow(path, asOffset: false, orientToPath: false, duration: 0.20)
        
        let addToScore = SKAction.customAction(withDuration: .leastNonzeroMagnitude, actionBlock: {
            [weak self] _,_ in
            
            if let label = self?.childNode(withName: "coinNumber") as? SKLabelNode {
                if startingCoins + 1 >= 1000 {
                    label.position = CGPoint(x: 127.5, y: -70)
                } else if startingCoins + 1 >= 100 {
                    label.position = CGPoint(x: 119.5, y: -70)
                }
                label.text = "\(startingCoins + 1)"
                if let url = Bundle.main.url(forResource: "CoinIncrease", withExtension: ".wav") {
                    let sound = SKAudioNode(url: url)
                    sound.autoplayLooped = false
                    self?.addChild(sound)
                    
                    let wait = SKAction.wait(forDuration: 0.5)
                    
                    let removeNode = SKAction.customAction(withDuration: .leastNonzeroMagnitude, actionBlock: {
                        [] _,_ in
                        
                        sound.removeFromParent()
                    })
                    
                    let sequence2 = SKAction.sequence([SKAction.play(),wait, removeNode])
                    
                    if defaults.bool(forKey: "soundFXOn") {
                        sound.run(sequence2)
                    }
                }
            }
            
            if startingCoins == 0 {
                let startingCoin = SKSpriteNode(imageNamed: "coin")
                startingCoin.size = coin.size
                startingCoin.position = CGPoint(x: 75, y: -60)
                self?.addChild(startingCoin)
            }
            
            coin.removeFromParent()
            self?.sendCoin(newCoins: newCoins - 1, startingCoins: startingCoins + 1)
            
        })
        
        let sequence = SKAction.sequence([follow, addToScore])
        
        coin.run(sequence)
    }
    
    func showButton() {
        let button = SKSpriteNode(imageNamed: "element_grey_rectangle_glossy")
        button.position = CGPoint(x: -75, y: -50)
        button.size = CGSize(width: 144, height: 72)
        button.alpha = 0
        button.name = "okButton"
        button.zPosition = 2
        
        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        label.fontSize = 36
        label.position = CGPoint(x: 0, y: -13)
        label.text = "Ok"
        label.horizontalAlignmentMode = .center
        label.zPosition = 2
        label.fontColor = UIColor.init(red: 0.9, green: 0.25, blue: 0.25, alpha: 1)

        button.addChild(label)
        addChild(button)
        
        let fadeIn = SKAction.fadeIn(withDuration: 3.5)
        
        button.run(fadeIn)
        label.run(fadeIn)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        
        let objects = nodes(at: location)
        
        for node in objects {
            if node.name == "okButton" {
                node.run(SKAction.scale(by: 0.9, duration: 0.0001))
                let defaults = UserDefaults.standard
                
                if defaults.bool(forKey: "soundFXOn") {
                    if let url = Bundle.main.url(forResource: "PressDownButtonSound", withExtension: ".wav") {
                        let sound = SKAudioNode(url: url)
                        sound.isPositional = false
                        sound.autoplayLooped = false
                        
                        addChild(sound)
                        
                        let play = SKAction.play()
                        let turnUp = SKAction.changeMass(to: 1, duration: 0.001)
                        let removeNode = SKAction.customAction(withDuration: 0.01, actionBlock: {
                            [] _,_ in
                            sound.removeFromParent()
                        })
                        let sequence = SKAction.sequence([play, turnUp, SKAction.wait(forDuration: 2), removeNode])
                        
                        sound.run(sequence)
                        
                    }
                }
                okButtonTapped = true
                break
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        
        let objects = nodes(at: location)
        
        guard let okButton = childNode(withName: "okButton") as? SKSpriteNode else {return}
        
        if !objects.contains(okButton) {
            if okButtonTapped {
                biggerButton(node: okButton, touchEndInside: false)
                
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        
        let objects = nodes(at: location)
        
        for node in objects {
            if node.name == "okButton" {
                if okButtonTapped {
                    biggerButton(node: node, touchEndInside: true)
                }
                break
            }
        }
    }
    
    func biggerButton(node: SKNode, touchEndInside: Bool) {
        node.run(SKAction.scale(by: (10/9), duration: 0.0001))
        
        let defaults = UserDefaults.standard
        
        if defaults.bool(forKey: "soundFXOn") {
            if let url = Bundle.main.url(forResource: "PressUpButtonSound", withExtension: ".wav") {
                let sound = SKAudioNode(url: url)
                sound.isPositional = false
                sound.autoplayLooped = false
                
                addChild(sound)
                
                let turnUp = SKAction.changeVolume(to: 1, duration: 0.001)
                let removeNode = SKAction.customAction(withDuration: 0.01, actionBlock: {
                    [] _,_ in
                    sound.removeFromParent()
                })
                let sequence = SKAction.sequence([turnUp, SKAction.play(), SKAction.wait(forDuration: 2), removeNode])
                
                sound.run(sequence)
            }
        }
        
        okButtonTapped = false
        
        if touchEndInside {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                [weak self] in
                let blackScreen = SKSpriteNode(color: .black, size: CGSize(width: 667, height: 375))
                blackScreen.alpha = 0
                blackScreen.position = CGPoint(x: 333.5, y: 187.5)
                blackScreen.zPosition = 20
                
                let fadeIn = SKAction.fadeIn(withDuration: 2)
                self?.parent?.addChild(blackScreen)
                blackScreen.run(fadeIn)
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5, execute: {
                [weak self] in
                guard let scene = self?.parent as? SKScene else {return}
                let mainMenu = MainMenu(size: scene.size, presentedFromGame: true, newRocket: false)
                scene.view?.presentScene(mainMenu)
            })
        }
    }
    
    func addToCoins(add number: Int) {
        let scoreAdder = SKLabelNode(fontNamed: "ChalkboardSE-Regular")
        
        let coinLabel = childNode(withName: "coinNumber") as! SKLabelNode
        let coins = Int(coinLabel.text!) ?? -1
        
        scoreAdder.fontSize = 40
        scoreAdder.horizontalAlignmentMode = .center
        scoreAdder.text = "+\(number)"
        scoreAdder.fontColor = .green
        scoreAdder.zPosition = 5
        scoreAdder.physicsBody = SKPhysicsBody()
        scoreAdder.physicsBody?.velocity = CGVector(dx: 5, dy: 10)
        scoreAdder.physicsBody?.linearDamping = 0
        scoreAdder.position = CGPoint(x: coinLabel.position.x + 60, y: coinLabel.position.y)
        
        let fadeOut = SKAction.fadeOut(withDuration: 1)
        let getSmaller = SKAction.resize(byWidth: 0, height: 0, duration: 1)
        let remove = SKAction.run {
            [] in
            scoreAdder.removeFromParent()
        }
        let sequence = SKAction.sequence([getSmaller,remove])
        scoreAdder.run(fadeOut)
        scoreAdder.run(sequence)
        
        addChild(scoreAdder)
        
        if (coins != -1) {
            coinLabel.text = "\(coins + 15)"
            
            if coins + 15 >= 1000 {
                coinLabel.position = CGPoint(x: 127.5, y: -70)
            } else if coins + 15 >= 100 {
                coinLabel.position = CGPoint(x: 119.5, y: -70)
            }
            
            if coins == 0 {
                let coin2 = SKSpriteNode(imageNamed: "coin")
                coin2.size = CGSize(width: 15, height: 15)
                coin2.position = CGPoint(x: 75, y: -60)
                addChild(coin2)
            }
            
        } else {
            print("coins not a number")
        }
    }
}
