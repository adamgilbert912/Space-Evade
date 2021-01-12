//
//  Shop.swift
//  Shaky Rocket
//
//  Created by macbook on 5/9/20.
//  Copyright © 2020 example. All rights reserved.
//

import Foundation
import SpriteKit

class Shop: SKScene {
    
    var backButton: SKSpriteNode!
    var purchaseButton: SKSpriteNode!
    var coinsButton: SKSpriteNode!
    
    var leverFrame: SKSpriteNode!
    var leverHandle: SKSpriteNode!
    var leverSlit: SKSpriteNode!
    
    var wheelFrame: SKShapeNode!
    var frameCropNode: SKCropNode!
    var wheelSpriteBackground2: WheelSprite!
    var wheelSprites: CGFloat = 0.0
    
    var newRocket = false
    
    var coinNumber: SKLabelNode = SKLabelNode()
    var totalCoins = 0 {
        didSet {
            coinNumber.text = "\(totalCoins)"
        }
    }
    
    var backButtonTapped = false
    var purchaseButtonTapped = false
    var coinsButtonTapped = false
    var leverHandleTapped = false
    
    var goingBackToMainMenu = false
    var wheelSpinning = false
    var leverActive = false
    var wheelAnimationActive = false
    
    
    var hasEnoughCoins = true
    var litUpFromPurchase = false
    
    override func didMove(to view: SKView) {
        
        scene?.scaleMode = .aspectFit
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fetchProducts"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goodLeverStartFromPurchase), name: NSNotification.Name("goodLeverStart"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(badLeverStart), name: NSNotification.Name("badLeverStart"), object: nil)
        
        let background = SKSpriteNode(color: .black, size: CGSize(width: 667, height: 375))
        background.position = CGPoint(x: 667/2, y: 375/2)
        background.zPosition = -1
        addChild(background)
        
        let cover = SKSpriteNode(color: .black, size: background.size)
        cover.zPosition = 10
        cover.position = background.position
        cover.alpha = 1
        addChild(cover)
        cover.run(SKAction.fadeOut(withDuration: 3))
        
        let stars = SKEmitterNode(fileNamed: "ShopStars")!
        stars.position = background.position
        stars.advanceSimulationTime(15)
        stars.zPosition = 0
        addChild(stars)
        
        backButton = SKSpriteNode(imageNamed: "element_red_square_glossy")
        backButton.size = CGSize(width: 64, height: 64)
        backButton.position = CGPoint(x: 44, y: 331)
        backButton.zPosition = 1
        backButton.name = "backButton"
        addChild(backButton)
        
        let backIcon = SKSpriteNode(imageNamed: "BackButton")
        backButton.addChild(backIcon)
        backIcon.zPosition = 2
        
        wheelFrame = SKShapeNode(rectOf: CGSize(width: 230*1.5, height: 230), cornerRadius: 20)
        wheelFrame.strokeColor = .init(red: 252/255, green: 194/255, blue: 0, alpha: 1)
        wheelFrame.fillColor = .init(red: 252/255, green: 194/255, blue: 0, alpha: 1)
        wheelFrame.position = CGPoint(x: 212.5 - 20, y: 375/2 - 20)
        wheelFrame.zPosition = 1
        wheelFrame.glowWidth = 2
        addChild(wheelFrame)
        
        //let wheelSpriteBackground = SKSpriteNode(color: .white, size: CGSize(width: wheelFrame.frame.width / 2, height: wheelFrame.frame.height * (0.4)))
        
        let maskNode = SKSpriteNode(color: .green, size: CGSize(width: wheelFrame.frame.width / 2, height: wheelFrame.frame.height - 4))
        
        frameCropNode = SKCropNode()
        frameCropNode.maskNode = maskNode
        wheelFrame.addChild(frameCropNode)
        
        let wheelSpriteBackground = WheelSprite(rectOf: CGSize(width: wheelFrame.frame.width / 2, height: wheelFrame.frame.height * (0.4)), cornerRadius: 10)
        wheelSpriteBackground.configure(ship: "spaceRockets_003")
        frameCropNode.addChild(wheelSpriteBackground)
        
        wheelSpriteBackground2 = WheelSprite(rectOf: CGSize(width: wheelFrame.frame.width / 2, height: wheelFrame.frame.height * (0.4)), cornerRadius: 10)
        wheelSpriteBackground2.configure(ship: "spaceShips_004")
        wheelSpriteBackground2.position = CGPoint(x: 0, y: wheelSpriteBackground.position.y + wheelSpriteBackground.frame.height + 20)
        frameCropNode.addChild(wheelSpriteBackground2)
                
        let wheelSpriteBackground3 = WheelSprite(rectOf: CGSize(width: wheelFrame.frame.width / 2, height: wheelFrame.frame.height * (0.4)), cornerRadius: 10)
        wheelSpriteBackground3.configure(ship: "spaceShips_006")
        wheelSpriteBackground3.position = CGPoint(x: 0, y: wheelSpriteBackground.position.y - wheelSpriteBackground.frame.height - 20)
        frameCropNode.addChild(wheelSpriteBackground3)
        
        let wheelFrameBar1 = SKSpriteNode(color: .lightGray, size: CGSize(width: 5, height: wheelFrame.frame.height - 4))
        wheelFrameBar1.zPosition = 2
        wheelFrameBar1.position = CGPoint(x: (wheelSpriteBackground.frame.width / 2) + (wheelFrameBar1.size.width / 2), y: 0)
        wheelFrame.addChild(wheelFrameBar1)
        
        let wheelFrameBar2 = SKSpriteNode(color: .lightGray, size: CGSize(width: wheelFrameBar1.size.width, height: wheelFrame.frame.height - 4))
        wheelFrameBar2.position = CGPoint(x: -(wheelSpriteBackground.frame.width / 2) - (wheelFrameBar2.size.width / 2), y: 0)
        wheelFrameBar2.zPosition = 2
        wheelFrame.addChild(wheelFrameBar2)
        
        let wheelFrameGlow = SKSpriteNode(imageNamed: "wheelFrameGlow2")
        wheelFrameGlow.zPosition = 4
        wheelFrameGlow.alpha = 1
        wheelFrameGlow.name = "wheelFrameGlow"
        
        let fadeOut = SKAction.fadeAlpha(by: -0.3, duration: 0.5)
        let fadeIn = SKAction.fadeAlpha(by: 0.3, duration: 0.5)
        let sequence = SKAction.sequence([fadeOut, fadeIn])
        let repeatForever = SKAction.repeatForever(sequence)
        
        wheelFrame.addChild(wheelFrameGlow)
        wheelFrameGlow.run(repeatForever)
        
        leverFrame = SKSpriteNode(imageNamed: "element_grey_rectangle_glossy")
        leverFrame.zRotation = CGFloat.pi/2
        leverFrame.size = CGSize(width: leverFrame.size.width * 3.59, height: leverFrame.size.height * 2.5)
        leverFrame.position = CGPoint(x: wheelFrame.position.x + 345/2 + leverFrame.size.height - 10, y: wheelFrame.position.y)
        leverFrame.zPosition = 1
        addChild(leverFrame)
        
        leverSlit = SKSpriteNode(color: .black, size: CGSize(width: 170, height: 10))
        leverSlit.zPosition = 2
        leverFrame.addChild(leverSlit)
        
        leverHandle = SKSpriteNode(imageNamed: "ballRed")
        leverSlit.addChild(leverHandle)
        leverHandle.zPosition = 3
        leverHandle.name = "leverHandle"
        leverHandle.size = CGSize(width: leverHandle.size.width * 0.65, height: leverHandle.size.height * 0.65)
        leverHandle.position = CGPoint(x: leverHandle.parent!.frame.maxX, y: 0)
        leverHandle.addGlow(radius: leverHandle.size.width * 1.5)
        
        coinsButton = SKSpriteNode(imageNamed: "element_grey_rectangle_glossy")
        coinsButton.size = CGSize(width: coinsButton.size.width * 2.5, height: coinsButton.size.height * 2.5)
        coinsButton.position = CGPoint(x: leverFrame.position.x + leverFrame.size.height + 55, y: leverFrame.position.y + 50)
        coinsButton.zPosition = 1
        coinsButton.name = "coinsButton"
        addChild(coinsButton)
        
        purchaseButton = SKSpriteNode(imageNamed: "element_grey_rectangle_glossy")
        purchaseButton.size = CGSize(width: purchaseButton.size.width * 2.5, height: purchaseButton.size.height * 2.5)
        purchaseButton.position = CGPoint(x: coinsButton.position.x, y: leverFrame.position.y - 50)
        purchaseButton.zPosition = 1
        purchaseButton.name = "purchaseButton"
        addChild(purchaseButton)
        
        let coinsLabel = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        coinsLabel.text = "100"
        coinsLabel.fontSize = 40
        coinsLabel.fontColor = UIColor.init(red: 0.7, green: 0.2, blue: 0.2, alpha: 1)
        coinsLabel.zPosition = 2
        coinsLabel.position = CGPoint(x: -15, y: -13)
        coinsLabel.horizontalAlignmentMode = .center
        coinsButton.addChild(coinsLabel)
        
        let purchaseLabel = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        purchaseLabel.text = "99¢"
        purchaseLabel.fontSize = 40
        purchaseLabel.fontColor = UIColor.init(red: 0.7, green: 0.2, blue: 0.2, alpha: 1)
        purchaseLabel.zPosition = 2
        purchaseLabel.position = CGPoint(x: 0, y: -13)
        purchaseLabel.horizontalAlignmentMode = .center
        purchaseButton.addChild(purchaseLabel)
        
        let coinImage1 = SKSpriteNode(imageNamed: "coin")
        coinImage1.position = CGPoint(x: (667/2) + 55, y: 360)
        coinImage1.zPosition = 2
        coinImage1.size = CGSize(width: coinImage1.size.width * (1/6), height: coinImage1.size.height * (1/6))
        addChild(coinImage1)
        
        let coinImage = SKSpriteNode(imageNamed: "coin")
        coinImage.position = CGPoint(x: 40, y: 0)
        coinImage.zPosition = 2
        coinImage.size = CGSize(width: coinImage.size.width * (1/6), height: coinImage.size.height * (1/6))
        coinsButton.addChild(coinImage)
        
        //for testing
        let defaults = UserDefaults.standard
        
        totalCoins = defaults.integer(forKey: "totalCoins")
        
        coinNumber.text = "\(totalCoins)"
        coinNumber.position = CGPoint(x: 667/2, y: 350)
        coinNumber.fontColor = .white
        addChild(coinNumber)
        
        if defaults.bool(forKey: "musicOn") {
            if let url = Bundle.main.url(forResource: "ShopMusic2", withExtension: ".mp3") {
                let music = SKAudioNode(url: url)
                music.name = "music"
                music.autoplayLooped = true
                music.isPositional = false
                
                addChild(music)
                
                music.run(SKAction.play())
                music.run(SKAction.changeVolume(to: 0, duration: 0.1))
                music.run(SKAction.changeVolume(to: 1, duration: 3))
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        
        let objects = nodes(at: location)
        
        for node in objects {
            if node.name == "backButton" || node.name == "purchaseButton" || node.name == "coinsButton" {
                smallerButton(node: node)
            } else if node.name == "leverHandle" {
                if leverActive {
                    leverHandleTapped = true
                }
            }
        }
    }
    
    //leverHandle no work
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        
        let objects = nodes(at: location)
        
        if !objects.contains(backButton) && !objects.contains(purchaseButton) && !objects.contains(coinsButton) {
            if backButtonTapped {
                biggerButton(node: backButton, touchEndInside: false)
            } else if purchaseButtonTapped {
                biggerButton(node: purchaseButton, touchEndInside: false)
            } else if coinsButtonTapped{
                biggerButton(node: coinsButton, touchEndInside: false)
            } else if leverHandleTapped {
                if objects.contains(leverHandle) {
                    if location.y < leverFrame.position.y + (leverSlit.frame.size.width / 2) && location.y > leverFrame.position.y - (leverSlit.frame.size.width / 2) {
                        
                        let point = convert(location, to: leverSlit)
                        
                        leverHandle.position.x = point.x
                        
                        if leverHandle.position.x < ((-leverSlit.frame.width / 2) + 10)  {
                            startWheel(purchased: litUpFromPurchase)
                        }
                    }
                } else {
                    let moveBack = SKAction.move(to: CGPoint(x: leverSlit.frame.width / 2, y: 0), duration: 1)
                    
                    leverHandle.run(moveBack)
                    leverHandleTapped = false
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if backButtonTapped {
            biggerButton(node: backButton, touchEndInside: true)
        } else if purchaseButtonTapped {
            biggerButton(node: purchaseButton, touchEndInside: true)
        } else if coinsButtonTapped {
            biggerButton(node: coinsButton, touchEndInside: true)
        } else if leverHandleTapped {
            if leverHandle.position.x >= ((-leverSlit.frame.width / 2) + 10) {
                let moveBack = SKAction.move(to: CGPoint(x: leverSlit.frame.width / 2, y: 0), duration: 1)
                
                leverHandle.run(moveBack)
            }
        }
    }
    
    func smallerButton(node: SKNode) {
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
        
        if node.name == "backButton" {
            backButtonTapped = true
        } else if node.name == "purchaseButton" {
            purchaseButtonTapped = true
        } else if node.name == "coinsButton" {
            coinsButtonTapped = true
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
        
        if node.name == "backButton" {
            backButtonTapped = false
            
            if touchEndInside {
                if !wheelAnimationActive {
                    let blackScreen = SKSpriteNode(color: .black, size: CGSize(width: 667, height: 375))
                    blackScreen.alpha = 0
                    blackScreen.position = CGPoint(x: 333.5, y: 187.5)
                    blackScreen.zPosition = 20
                    
                    let fadeIn = SKAction.fadeIn(withDuration: 2)
                    
                    let fadeMusic = SKAction.customAction(withDuration: 0.01, actionBlock: {
                        [weak self] _,_ in
                        
                        if let music = self?.childNode(withName: "music") as? SKAudioNode {
                            music.run(SKAction.changeVolume(to: 0, duration: 2))
                        }
                    })
                    
                    let presentScene = SKAction.customAction(withDuration: 0.01, actionBlock: {
                        [weak self] _,_ in
                        
                        let scene = MainMenu(size: self!.size, presentedFromGame: true, newRocket: self!.newRocket)
                        
                        self?.view?.presentScene(scene)
                    })
                    
                    let sequence = SKAction.sequence([fadeMusic, fadeIn, presentScene])
                    
                    addChild(blackScreen)
                    blackScreen.run(sequence)
                }
            }
        } else if node.name == "purchaseButton" {
            purchaseButtonTapped = false
            
            if touchEndInside {
                if !leverActive && !wheelAnimationActive {
                    NotificationCenter.default.post(name: NSNotification.Name("tappedBuy"), object: nil)
                }
            }
        } else if node.name == "coinsButton" {
            coinsButtonTapped = false
            
            if touchEndInside {
                if !leverActive && !wheelAnimationActive {
                    let defaults = UserDefaults.standard
                    if defaults.integer(forKey: "totalCoins") >= 100 {
                        let leverLightGood = SKSpriteNode(imageNamed: "leverLight2")
                        leverLightGood.zPosition = 2
                        leverLightGood.alpha = 0
                        
                        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
                        let fadeOut = SKAction.fadeOut(withDuration: 1.5)
                        let sequence = SKAction.sequence([fadeIn, fadeOut])
                        let forever = SKAction.repeatForever(sequence)
                        
                        leverFrame.addChild(leverLightGood)
                        leverLightGood.run(forever)
                        leverLightGood.name = "leverLightGood"
                        
                        leverActive = true
                    } else {
                        let leverLightBad = SKSpriteNode(imageNamed: "leverLight3")
                        leverLightBad.zPosition = 2
                        leverLightBad.alpha = 0
                        
                        let fadeIn = SKAction.fadeIn(withDuration: 0.01)
                        let fadeOut = SKAction.fadeOut(withDuration: 0.01)
                        let wait = SKAction.wait(forDuration: 0.25)
                        let removeNode = SKAction.customAction(withDuration: 0.01, actionBlock: {
                            [] _,_ in
                            leverLightBad.removeFromParent()
                        })
                        
                        let sequence = SKAction.sequence([fadeIn, wait, fadeOut, wait, fadeIn, wait, fadeOut, removeNode])
                        
                        leverFrame.addChild(leverLightBad)
                        leverLightBad.run(sequence)
                        
                        if defaults.bool(forKey: "soundFXOn") {
                            if let url = Bundle.main.url(forResource: "Error2", withExtension: ".wav") {
                                let errorSound = SKAudioNode(url: url)
                                errorSound.autoplayLooped = false
                                addChild(errorSound)
                                errorSound.run(SKAction.play())
                            }
                        }
                    }
                }
            }
        }
    }
    
    func startWheel(purchased: Bool) {
        leverActive = false
        leverHandleTapped = false
        wheelSpinning = true
        wheelAnimationActive = true
        
        let moveBack = SKAction.move(to: CGPoint(x: leverSlit.frame.width / 2, y: 0), duration: 1)
        leverHandle.run(moveBack)
        
        let defaults = UserDefaults.standard
        
        if !purchased {
            defaults.set(defaults.integer(forKey: "totalCoins") - 100, forKey: "totalCoins")
        
            totalCoins -= 100
        }
        
        litUpFromPurchase = false
        leverFrame.childNode(withName: "leverLightGood")?.removeFromParent()
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if wheelSpinning {
            let speedFactor: CGFloat = pow((80 - wheelSprites), 0.7)/pow(80, 0.7)
            for child in frameCropNode.children {
                if child.name == "whiteBackground" {
                    if let background = child as? WheelSprite {
                        if !background.isMoving {
                            let moveDown = SKAction.move(by: CGVector(dx: 0, dy: -30000), duration: 30)
                            
                            background.run(moveDown, withKey: "moveDown")
                            background.isMoving = true
                        } else {
                            if background.position.y < (-wheelFrame.frame.height / 2) - (background.frame.height / 2) {
                                background.removeFromParent()
                            } else if (wheelFrame.frame.height / 2) - (background.position.y / 2) >= (background.frame.height / 2) + 10 && (wheelFrame.frame.height / 2) - background.position.y / 2 <= (background.frame.height / 2) + 20 {
                                let objects = frameCropNode.nodes(at: CGPoint(x: 0, y: wheelFrame.frame.height))
                                if objects.isEmpty {
                                        wheelSprites += 1
                                    let newBackground = WheelSprite(rectOf: CGSize(width: wheelFrame.frame.width / 2, height: wheelFrame.frame.height * (0.4)), cornerRadius: 10)
                                    newBackground.configure(ship: nil)
                                    newBackground.position = CGPoint(x: 0, y: background.position.y + (background.frame.height) + 20)
                                    frameCropNode.addChild(newBackground)
                                    
                                    if let url = Bundle.main.url(forResource: "WheelSpinSound", withExtension: ".wav") {
                                        let sound = SKAudioNode(url: url)
                                        sound.autoplayLooped = false
                                        sound.isPositional = false
                                        
                                        addChild(sound)
                                        
                                        let sequence = SKAction.sequence([SKAction.play(), SKAction.wait(forDuration: 2), SKAction.removeFromParent()])
                                        
                                        sound.run(sequence)
                                        print("yup")
                                    }
                                }
                            }
                        }
                        if wheelSprites <= 80 {
                            if let action = background.action(forKey: "moveDown") {
                                action.speed = speedFactor
                            }
                        }
                    }
                }
            }
            if speedFactor == 0 {
                wheelSpinning = false
                wheelSprites = 0
                
                var middleChild = SKNode()
                var smallestYPosition: CGFloat = 100.0
                
                for child in frameCropNode.children {
                    if abs(child.position.y) < smallestYPosition {
                        middleChild = child.children[0]
                        smallestYPosition = child.position.y
                    }
                }
                let spriteName = middleChild.name!
                let defaults = UserDefaults.standard
                
                if defaults.bool(forKey: spriteName) {
                    let badGlow = SKSpriteNode(imageNamed: "WheelFrameBad")
                    badGlow.zPosition = 4
                    
                    wheelFrame.childNode(withName: "wheelFrameGlow")?.isHidden = true
                    
                    let fadeOut = SKAction.fadeAlpha(by: -0.3, duration: 0.5)
                    let fadeIn = SKAction.fadeAlpha(by: 0.3, duration: 0.5)
                    let sequence = SKAction.sequence([fadeOut, fadeIn])
                    let repeatForever = SKAction.repeatForever(sequence)
                    
                    wheelFrame.addChild(badGlow)
                    badGlow.run(repeatForever)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                        [weak self] in
                        badGlow.removeFromParent()
                        self?.wheelFrame.childNode(withName: "wheelFrameGlow")?.isHidden = false
                        self?.wheelAnimationActive = false
                    })
                } else {
                    defaults.set(true, forKey: spriteName)
                    
                    newRocket = true
                    
                    let goodGlow = SKSpriteNode(imageNamed: "WheelFrameGood")
                    goodGlow.zPosition = 4
                    
                    wheelFrame.childNode(withName: "wheelFrameGlow")?.isHidden = true
                    
                    let fadeOut = SKAction.fadeAlpha(by: -0.3, duration: 0.5)
                    let fadeIn = SKAction.fadeAlpha(by: 0.3, duration: 0.5)
                    let sequence = SKAction.sequence([fadeOut, fadeIn])
                    let repeatForever = SKAction.repeatForever(sequence)
                    
                    wheelFrame.addChild(goodGlow)
                    goodGlow.run(repeatForever)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                        [weak self] in
                        goodGlow.removeFromParent()
                        self?.wheelFrame.childNode(withName: "wheelFrameGlow")?.isHidden = false
                        self?.wheelAnimationActive = false
                    })
                }
            }
        }
    }
    
    @objc func goodLeverStart() {
        if !leverActive && !wheelAnimationActive {
            
            let leverLightGood = SKSpriteNode(imageNamed: "leverLight2")
            leverLightGood.zPosition = 2
            leverLightGood.alpha = 0
            
            let fadeIn = SKAction.fadeIn(withDuration: 0.5)
            let fadeOut = SKAction.fadeOut(withDuration: 1.5)
            let sequence = SKAction.sequence([fadeIn, fadeOut])
            let forever = SKAction.repeatForever(sequence)
            
            leverFrame.addChild(leverLightGood)
            leverLightGood.run(forever)
            leverLightGood.name = "leverLightGood"
            
            leverActive = true
        }
    }
    
    @objc func goodLeverStartFromPurchase() {
        if !leverActive && !wheelAnimationActive {
            
            let leverLightGood = SKSpriteNode(imageNamed: "leverLight2")
            leverLightGood.zPosition = 2
            leverLightGood.alpha = 0
            
            let fadeIn = SKAction.fadeIn(withDuration: 0.5)
            let fadeOut = SKAction.fadeOut(withDuration: 1.5)
            let sequence = SKAction.sequence([fadeIn, fadeOut])
            let forever = SKAction.repeatForever(sequence)
            
            leverFrame.addChild(leverLightGood)
            leverLightGood.run(forever)
            leverLightGood.name = "leverLightGood"
            
            leverActive = true
            litUpFromPurchase = true
        }
    }
    
    @objc func badLeverStart() {
        if !leverActive && !wheelAnimationActive {
            let defaults = UserDefaults.standard
            
            let leverLightBad = SKSpriteNode(imageNamed: "leverLight3")
            leverLightBad.zPosition = 2
            leverLightBad.alpha = 0
            
            let fadeIn = SKAction.fadeIn(withDuration: 0.01)
            let fadeOut = SKAction.fadeOut(withDuration: 0.01)
            let wait = SKAction.wait(forDuration: 0.25)
            let removeNode = SKAction.customAction(withDuration: 0.01, actionBlock: {
                [] _,_ in
                leverLightBad.removeFromParent()
            })
            
            let sequence = SKAction.sequence([fadeIn, wait, fadeOut, wait, fadeIn, wait, fadeOut, removeNode])
            
            leverFrame.addChild(leverLightBad)
            leverLightBad.run(sequence)
            
            if defaults.bool(forKey: "soundFXOn") {
                if let url = Bundle.main.url(forResource: "Error2", withExtension: ".wav") {
                    let errorSound = SKAudioNode(url: url)
                    errorSound.autoplayLooped = false
                    addChild(errorSound)
                    errorSound.run(SKAction.play())
                }
            }
        }
    }
}
