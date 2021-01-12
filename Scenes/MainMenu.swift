//
//  MainMenu.swift
//  Shaky Rocket
//
//  Created by macbook on 3/24/20.
//  Copyright © 2020 example. All rights reserved.
//
import SpriteKit
import GameplayKit

class MainMenu: SKScene {
    var rocketFire: SKEmitterNode!
    var rocketCropNode: SKCropNode!
    
    var beganTouchLocation: CGPoint?
    var rocketPositions: [CGPoint] = []
    
    var playButton: SKSpriteNode!
    var playLabel: SKLabelNode!
    var playButtonTapped = false
    
    var optionsButton: SKSpriteNode!
    var optionsIcon: SKSpriteNode!
    var optionsMenu: OptionsMenu!
    var optionsButtonTapped = false
    var exitButtonTapped = false
    
    var shopButton: SKSpriteNode!
    var shopIcon: SKSpriteNode!
    var shopButtonTapped = false
    
    var soundFXButtonTapped = false
    var musicButtonTappped = false
    
    var startingGame = false
    var insideOptionsMenu = false
    var rocketsMoving = false
    
    var presentedFromGame = false
    var newRocket = false
    
    //add main menu music, maybe add button sounds
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(size: CGSize, presentedFromGame: Bool, newRocket: Bool) {
        super.init(size: size)
        self.presentedFromGame = presentedFromGame
        self.newRocket = newRocket
    }
        
    override func didMove(to view: SKView) {
        let defaults = UserDefaults.standard
        
        scene?.scaleMode = .aspectFit
        
        defaults.set(true, forKey: "spaceRockets_003")
        
        if presentedFromGame {
            let blackScreen = SKSpriteNode(color: .black, size: CGSize(width: 667, height: 375))
            blackScreen.alpha = 1
            blackScreen.position = CGPoint(x: 333.5, y: 187.5)
            blackScreen.zPosition = 7
            addChild(blackScreen)
            blackScreen.run(SKAction.fadeOut(withDuration: 2))
        }
        
        if defaults.integer(forKey: "highScore") == 0 {
            defaults.set(true, forKey: "soundFXOn")
            defaults.set(true, forKey: "musicOn")
        }
        
        let background = SKSpriteNode(color: .black, size: CGSize(width: 667, height: 375))
        background.position = CGPoint(x: 333.5, y: 187.5)
        background.zPosition = -3
        
        let stars = SKEmitterNode(fileNamed: "MainMenuStars")!
        stars.position = CGPoint(x: 333.5, y: 187.5)
        stars.advanceSimulationTime(10)
        stars.zPosition = -2
        
        if newRocket {
            let swipeText = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
            swipeText.name = "swipeText"
            swipeText.text = "Swipe →"
            swipeText.alpha = 0.1
            swipeText.fontSize = 54
            swipeText.fontColor = .green
            swipeText.position = CGPoint(x: 333.5, y: 307.5)
            
            let fadeIn = SKAction.fadeAlpha(by: 0.6, duration: 2)
            let fadeOut = SKAction.fadeAlpha(by: -0.6, duration: 2)
            let sequence = SKAction.sequence([fadeIn, fadeOut])
            let forever = SKAction.repeatForever(sequence)
            
            addChild(swipeText)
            
            swipeText.run(forever)
        }
        
        if defaults.bool(forKey: "musicOn") {
            if let url = Bundle.main.url(forResource: "MainMenu", withExtension: ".wav") {
                let music = SKAudioNode(url: url)
                music.name = "music"
                music.autoplayLooped = true
                music.isPositional = false
                music.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
                addChild(music)
                
                let play = SKAction.play()
                let turnUp = SKAction.changeVolume(to: 3, duration: 5)
                music.run(play)
                music.run(SKAction.changeVolume(to: 0, duration: 0.1))
                music.run(turnUp)
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            [weak self] in
            self?.optionsMenu = OptionsMenu(rectOf: CGSize(width: 400, height: 200), cornerRadius: 4)
            self?.optionsMenu.name = "optionsMenu"
            self?.optionsMenu.configure(color: .init(red: 0.7, green: 0.2, blue: 0.2, alpha: 1), menuSize: CGSize(width: 400, height: 200), soundFXOn: defaults.bool(forKey: "soundFXOn"), musicOn: defaults.bool(forKey: "musicOn"))
            self?.optionsMenu.position = CGPoint(x: 333.5, y: 187.5)
            self?.optionsMenu.zPosition = 3
        }
        
            let cropNodeMask = SKSpriteNode(color: .blue, size: CGSize(width: 350, height: 110))
            
            rocketCropNode = SKCropNode()
            rocketCropNode.maskNode = cropNodeMask
            rocketCropNode.position = CGPoint(x: 343.5, y: 237.5)
            rocketCropNode.name = "rocketCropNode"
        
        let rocketFileNames = ["spaceRockets_003", "spaceRockets_004", "spaceRockets_001", "playerShip1_blue", "playerShip1_green", "playerShip3_blue", "playerShip3_green", "spaceShips_002", "spaceShips_004", "spaceShips_006", "spaceShips_007"]
        var userRocketsOwned = 0
        
        for fileName in rocketFileNames {
            if defaults.bool(forKey: fileName) {
                let rocket = SKSpriteNode(imageNamed: fileName)
                rocket.size = CGSize(width: 100, height: rocket.size.height * (100/rocket.size.width))
                rocket.zPosition = 0
                rocket.name = fileName
                
                let fire = SKEmitterNode(fileNamed: "MainMenuFire")!
                fire.zPosition = -1
                fire.name = "fire"
                
                if fileName == "spaceRockets_003" {
                    rocket.zRotation = -CGFloat.pi / 2
                    
                    fire.zRotation = CGFloat.pi
                    fire.position = CGPoint(x: 0, y: -110)
                } else if fileName == "spaceRockets_004" {
                    rocket.zRotation = -CGFloat.pi / 2
                    rocket.position = CGPoint(x: -350*userRocketsOwned, y: 0)
                    
                    fire.zRotation = CGFloat.pi
                    fire.position = CGPoint(x: 0, y: -110)
                    fire.particlePositionRange.dx = 12
                } else if fileName == "spaceRockets_001" {
                    rocket.zRotation = -CGFloat.pi / 2
                    rocket.position = CGPoint(x: -350*userRocketsOwned, y: 0)
                    
                    fire.zRotation = CGFloat.pi
                    fire.position = CGPoint(x: 0, y: -99)
                    fire.particlePositionRange.dx = 2
                    fire.emissionAngleRange = 0.2
                    fire.particleBirthRate = 600
                    fire.particleSpeed = 130
                } else if fileName == "playerShip1_blue" || fileName == "playerShip1_green" {
                    rocket.zRotation = -CGFloat.pi / 2
                    rocket.position = CGPoint(x: -350*userRocketsOwned, y: 0)
                    
                    fire.zRotation = CGFloat.pi
                    fire.position = CGPoint(x: 0, y: -32)
                    fire.particlePositionRange.dx = 1
                    fire.emissionAngleRange = 1
                    fire.particleScale = 0.3
                    fire.particleScaleRange = 0.1
                    fire.particleScaleSpeed = -0.4
                } else if fileName == "playerShip3_blue" || fileName == "playerShip3_green" {
                    rocket.zRotation = -CGFloat.pi / 2
                    rocket.position = CGPoint(x: -350*userRocketsOwned, y: 0)
                    
                    fire.zRotation = CGFloat.pi
                    fire.position = CGPoint(x: 0, y: -35)
                    fire.particlePositionRange.dx = 10
                } else if fileName == "spaceShips_006" {
                    rocket.zRotation = CGFloat.pi / 2
                    rocket.position = CGPoint(x: -350*userRocketsOwned, y: 0)
                    
                    fire.position = CGPoint(x: 0, y: 65)
                    fire.particlePositionRange.dx = 5
                } else if fileName == "spaceShips_002" {
                    rocket.zRotation = CGFloat.pi / 2
                    rocket.position = CGPoint(x: -350*userRocketsOwned, y: 0)
                    
                    fire.position = CGPoint(x: 20, y: 30)
                    fire.particlePositionRange.dx = 2
                    fire.particleScale = 0.3
                    
                    let fire2 = SKEmitterNode(fileNamed: "MainMenuFire")!
                    fire2.position = CGPoint(x: -20, y: 30)
                    fire2.particlePositionRange.dx = 2
                    fire2.particleScale = 0.3
                    fire2.zPosition = -1
                    fire2.name = "fire2"
                    rocket.addChild(fire2)
                } else if fileName == "spaceShips_004" {
                    rocket.zRotation = CGFloat.pi / 2
                    rocket.position = CGPoint(x: -350*userRocketsOwned, y: 0)
                    
                    fire.position = CGPoint(x: 29, y: 30)
                    fire.particlePositionRange.dx = 2
                    fire.particleScale = 0.18
                    
                    let fire2 = SKEmitterNode(fileNamed: "MainMenuFire")!
                    fire2.position = CGPoint(x: -29, y: 30)
                    fire2.zPosition = -1
                    fire2.particlePositionRange.dx = 2
                    fire2.particleScale = 0.18
                    fire2.name = "fire2"
                    rocket.addChild(fire2)

                } else if fileName == "spaceShips_007" {
                    rocket.zRotation = CGFloat.pi / 2
                    rocket.position = CGPoint(x: -350*userRocketsOwned, y: 0)
                    
                    fire.position = CGPoint(x: 22, y: 30)
                    fire.particlePositionRange.dx = 2
                    fire.particleScale = 0.18
                    
                    let fire2 = SKEmitterNode(fileNamed: "MainMenuFire")!
                    fire2.position = CGPoint(x: -22, y: 30)
                    fire2.zPosition = -1
                    fire2.particlePositionRange.dx = 2
                    fire2.particleScale = 0.18
                    fire2.name = "fire2"
                    rocket.addChild(fire2)
                }
                
                userRocketsOwned += 1
                rocket.addChild(fire)
                rocketCropNode.addChild(rocket)
            }
        }
        
            for child in rocketCropNode.children {
                rocketPositions.append(child.position)
            }
            
            playLabel = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
            playLabel.text = "Play!"
            playLabel.fontSize = 48
            playLabel.fontColor = UIColor.init(red: 0.7, green: 0.2, blue: 0.2, alpha: 1)
            playLabel.position = CGPoint(x: 0, y: -13)
            playLabel.zPosition = 1
            
            playButton = SKSpriteNode(imageNamed: "element_grey_rectangle_glossy")
            playButton.position = CGPoint(x: 328.5, y: 117.5)
            playButton.zPosition = 0
            playButton.size = CGSize(width: 192, height: 96)
            playButton.addChild(playLabel)
            playButton.name = "playButton"
            
            optionsIcon = SKSpriteNode(imageNamed: "wrench")
            optionsIcon.size = CGSize(width: optionsIcon.size.width * (1/3), height: optionsIcon.size.height * (1/3))
            optionsIcon.zPosition = 2
            
            optionsButton = SKSpriteNode(imageNamed: "element_red_square_glossy")
            optionsButton.size = CGSize(width: 64, height: 64)
            optionsButton.position = CGPoint(x: 603, y: 311)
            optionsButton.zPosition = 1
            optionsButton.addChild(optionsIcon)
            optionsButton.name = "optionsButton"
            
            shopIcon = SKSpriteNode(imageNamed: "shoppingCart")
            shopIcon.size = CGSize(width: shopIcon.size.width * (11/10), height: shopIcon.size.height * (11/10))
            shopIcon.zPosition = 2
            shopIcon.position = CGPoint(x: shopIcon.position.x + 1, y: shopIcon.position.y)
            
            shopButton = SKSpriteNode(imageNamed: "element_red_square_glossy")
            shopButton.size = CGSize(width: 64, height: 64)
            shopButton.position = CGPoint(x: 64, y: 311)
            shopButton.zPosition = 1
            shopButton.addChild(shopIcon)
            shopButton.name = "shopButton"
        
            addChild(background)
            addChild(stars)
            addChild(rocketCropNode)
            addChild(playButton)
            addChild(optionsButton)
            addChild(shopButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        
        let objects = nodes(at: location)
        
        for node in objects {
            if node.name == "playButton" || node.name == "optionsButton" || node.name == "shopButton" {
                if !insideOptionsMenu {
                    smallerButton(node: node)
                }
            } else if node.name == "exitOutline" {
                exitButtonTapped = true
            } else if node.name == "soundFXButton" || node.name == "musicButton" {
                smallerButton(node: node)
            } else if node.name == "rocketCropNode" {
                if !objects.contains(optionsMenu) {
                    beganTouchLocation = location
                    rocketsMoving = true
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        
        let objects = nodes(at: location)
        
        guard let musicButton = optionsMenu.childNode(withName: "musicButton") else {return}
        guard let soundFXButton = optionsMenu.childNode(withName: "soundFXButton") else {return}
        
        if !objects.contains(playButton) && !objects.contains(optionsButton) && !objects.contains(shopButton) && !objects.contains(musicButton) && !objects.contains(soundFXButton) {
            
            if playButtonTapped {
                biggerButton(node: playButton, touchEndInside: false)
            } else if optionsButtonTapped {
                biggerButton(node: optionsButton, touchEndInside: false)
            } else if shopButtonTapped {
                biggerButton(node: shopButton, touchEndInside: false)
            } else if musicButtonTappped {
                biggerButton(node: optionsMenu.childNode(withName: "musicButton")!, touchEndInside: false)
            } else if soundFXButtonTapped {
                biggerButton(node: optionsMenu.childNode(withName: "soundFXButton")!, touchEndInside: false)
            } else if rocketsMoving {
                if let xValue = beganTouchLocation?.x {
                    let xDifference = location.x - xValue
                    
                    for i in 0...(rocketCropNode.children.count - 1) {
                        rocketCropNode.children[i].position.x = rocketPositions[i].x + xDifference
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if playButtonTapped {
            biggerButton(node: playButton, touchEndInside: true)
        } else if optionsButtonTapped {
            biggerButton(node: optionsButton, touchEndInside: true)
        } else if shopButtonTapped {
            biggerButton(node: shopButton, touchEndInside: true)
        } else if musicButtonTappped {
            biggerButton(node: optionsMenu.childNode(withName: "musicButton")!, touchEndInside: true)
        } else if soundFXButtonTapped {
            biggerButton(node: optionsMenu.childNode(withName: "soundFXButton")!, touchEndInside: true)
        } else if exitButtonTapped {
            for node in nodes(at: touches.first!.location(in: self)) {
                if node.name == "exitOutline" {
                    DispatchQueue.main.async {
                        [weak self] in
                        self?.optionsMenu.removeFromParent()
                        self?.insideOptionsMenu = false
                        self?.exitButtonTapped = false
                    }
                }
            }
        }   else {
            if rocketCropNode.children[0].position.x - rocketPositions[0].x != 175.0 && rocketCropNode.children[0].position.x - rocketPositions[0].x != -175.0 {
                slide()
            } else {
                for i in 0...(rocketCropNode.children.count - 1) {
                    let moveBack = SKAction.moveTo(x: rocketPositions[i].x, duration: 0.75)
                    let endRocketsMoving = SKAction.customAction(withDuration: 0.01, actionBlock: {
                                   [weak self] _,_ in
                                   self?.rocketsMoving = false
                               })
                    let sequence = SKAction.sequence([moveBack, endRocketsMoving])
                    rocketCropNode.children[i].run(sequence)
                }
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
        
        if node.name == "playButton" {
            playButtonTapped = true
        } else if node.name == "optionsButton" {
            optionsButtonTapped = true
        } else if node.name == "shopButton" {
            shopButtonTapped = true
        } else if node.name == "soundFXButton" {
            soundFXButtonTapped = true
        } else if node.name == "musicButton" {
            musicButtonTappped = true
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
        
        if node.name == "playButton" {
            playButtonTapped = false
            
            if !startingGame {
                if touchEndInside {
                    if !rocketsMoving {
                        let rocketSprite = rocketCropNode.atPoint(CGPoint(x: 0, y: 0)) as? SKSpriteNode
                        
                        rocketSprite?.move(toParent: self)
                        
                        let moveUp = SKAction.moveBy(x: 0, y: 3, duration: 0.1)
                        let moveDown = SKAction.moveBy(x: 0, y: -3, duration: 0.1)
                        let wait = SKAction.wait(forDuration: 1)
                        let middleWait = SKAction.wait(forDuration: 0.5)
                        let shortWait = SKAction.wait(forDuration: 0.25)
                        let startGravity = SKAction.customAction(withDuration: 0.1, actionBlock: {
                            [weak self] _,_ in
                            if let size = rocketSprite?.size {
                                rocketSprite?.physicsBody = SKPhysicsBody(rectangleOf: size)
                            }
                            self?.physicsWorld.gravity = CGVector(dx: 0.75, dy: 0)
                        })
                        
                        let increaseFire = SKAction.customAction(withDuration: 0.01, actionBlock: {
                            [] _,_ in
                            if let fire = rocketSprite?.childNode(withName: "fire") as? SKEmitterNode {
                                fire.particleBirthRate = fire.particleBirthRate * 1.15
                                //1.05
                                var emissionRangeFactor = 1.0
                                if fire.particlePositionRange.dx <= 12 {
                                    emissionRangeFactor = 1.01
                                } else {
                                    emissionRangeFactor = 1.05
                                }
                                fire.emissionAngleRange = fire.emissionAngleRange * CGFloat(emissionRangeFactor)
                                
                                fire.particleSpeed = fire.particleSpeed * 1.15
                                
                                if let fire2 = rocketSprite?.childNode(withName: "fire2") as? SKEmitterNode {
                                    fire2.particleBirthRate *= 1.15
                                    fire2.emissionAngleRange *= CGFloat(emissionRangeFactor)
                                    fire2.particleSpeed *= 1.15
                                }
                            }
                        })
                        
                        let fadeMusic = SKAction.customAction(withDuration: 0.01, actionBlock: {
                            [weak self] _,_ in
                            
                            if let music = self?.childNode(withName: "music") as? SKAudioNode {
                                music.run(SKAction.changeVolume(to: 0, duration: 2))
                            }
                        })
                        
                        let transition = SKAction.customAction(withDuration: 0.01, actionBlock: {
                            [weak self] _,_ in
                            
                            let blackScreen = SKSpriteNode(color: .black, size: CGSize(width: 667, height: 375))
                            blackScreen.alpha = 0
                            blackScreen.position = CGPoint(x: 333.5, y: 187.5)
                            blackScreen.zPosition = 4
                            
                            let fadeIn = SKAction.fadeIn(withDuration: 2)
                            self?.addChild(blackScreen)
                            blackScreen.run(fadeIn)
                        })
                        
                        let changeScene = SKAction.customAction(withDuration: .leastNonzeroMagnitude, actionBlock: {
                            [weak self] _,_ in
                            
                            if let name = rocketSprite?.name {
                                let scene = GameScene(size: self!.size, rocketName: name)
                                scene.physicsWorld.gravity = CGVector(dx: 0, dy: -0.4)
                                self?.view?.presentScene(scene)
                            }
                        })
                        
                        let shakeAndMove = SKAction.sequence([middleWait, moveUp, moveDown, wait, increaseFire, startGravity, shortWait, increaseFire, shortWait, increaseFire, shortWait, increaseFire, shortWait, increaseFire, shortWait, increaseFire, shortWait, increaseFire, shortWait, increaseFire, shortWait, increaseFire, fadeMusic, transition, SKAction.wait(forDuration: 2), changeScene])
                        
                        rocketSprite?.run(shakeAndMove)
                        
                        startingGame = true
                    } else {
                        print("rocketsMoving")
                    }
                }
            }
        } else if node.name == "optionsButton" {
            if !startingGame {
                optionsButtonTapped = false
                
                if touchEndInside {
                    if !insideOptionsMenu {
                        DispatchQueue.main.async {
                            [weak self] in
                            self?.addChild(self!.optionsMenu)
                            
                            let getBigger = SKAction.scale(by: 1.05, duration: 0.25)
                            let getSmaller = SKAction.scale(by: (1/1.05), duration: 0.25)
                            let sequence = SKAction.sequence([getBigger, getSmaller])
                            
                            self?.optionsMenu.run(sequence)
                            self?.insideOptionsMenu = true
                        }
                    }
                }
            }
        } else if node.name == "shopButton" {
            shopButtonTapped = false
            
            if touchEndInside {
                startingGame = true
                
                let blackScreen = SKSpriteNode(color: .black, size: CGSize(width: 667, height: 375))
                blackScreen.alpha = 0
                blackScreen.position = CGPoint(x: 333.5, y: 187.5)
                blackScreen.zPosition = 4
                
                let fadeIn = SKAction.fadeIn(withDuration: 2)
                
                let musicFade = SKAction.customAction(withDuration: 0.01, actionBlock: {
                    [weak self] _,_ in
                    
                    if let music = self?.childNode(withName: "music") as? SKAudioNode {
                        music.run(SKAction.changeVolume(to: 0, duration: 2))
                    }
                })
                
                let presentScene = SKAction.customAction(withDuration: 0.01, actionBlock: {
                    [weak self] _,_ in
                    
                    let scene = Shop(size: self!.size)
                    self?.view?.presentScene(scene)
                })
                
                let sequence = SKAction.sequence([musicFade, fadeIn, presentScene])
                addChild(blackScreen)
                blackScreen.run(sequence)
                
            }
        } else if node.name  == "musicButton" {
            musicButtonTappped = false
            
            if touchEndInside {
                let defaults = UserDefaults.standard
                let musicOn = defaults.bool(forKey: "musicOn")
                
                if musicOn {
                    let moveLeft = SKAction.moveBy(x: -30, y: 0, duration: 0.75)
                    optionsMenu.childNode(withName: "musicButton")!.childNode(withName: "cropNode2")!.childNode(withName: "greenShape2")!.run(moveLeft)
                    
                    if let musicNode = childNode(withName: "music") as? SKAudioNode {
                        musicNode.run(SKAction.pause())
                    }
                } else {
                    let moveRight = SKAction.moveBy(x: 30, y: 0, duration: 0.75)
                    optionsMenu.childNode(withName: "musicButton")!.childNode(withName: "cropNode2")!.childNode(withName: "greenShape2")!.run(moveRight)
                    if let musicNode = childNode(withName: "music") as? SKAudioNode {
                        musicNode.run(SKAction.play())
                    }
                }
                defaults.set(!musicOn, forKey: "musicOn")
            }
        } else if node.name == "soundFXButton" {
            soundFXButtonTapped = false
            
            if touchEndInside {
                let defaults = UserDefaults.standard
                let soundFXOn = defaults.bool(forKey: "soundFXOn")
                
                if soundFXOn {
                    let moveLeft = SKAction.moveBy(x: -30, y: 0, duration: 0.75)
                    optionsMenu.childNode(withName: "soundFXButton")?.childNode(withName: "cropNode1")?.childNode(withName: "greenShape1")?.run(moveLeft)
                } else {
                    let moveRight = SKAction.moveBy(x: 30, y: 0, duration: 0.75)
                    optionsMenu.childNode(withName: "soundFXButton")?.childNode(withName: "cropNode1")?.childNode(withName: "greenShape1")?.run(moveRight)
                }
                defaults.set(!soundFXOn, forKey: "soundFXOn")
            }
        }
    }
    
    func slide() {
        var allToRightCount = 0
        var allToLeftCount = 0
        
        for child in rocketCropNode.children {
            if child.position.x > 0 {
                allToRightCount += 1
            } else if child.position.x < 0 {
                allToLeftCount += 1
            }
        }
        
        if allToLeftCount == rocketCropNode.children.count || allToRightCount == rocketCropNode.children.count {
            
            for i in 0...(rocketCropNode.children.count - 1) {
                let xDifference = abs(rocketCropNode.children[i].position.x - rocketPositions[i].x)
                let timeFactor = xDifference/350
                var time = Double(1.5*timeFactor)
                
                if time < 0.1 {
                    time = 0.1
                }
                
                let moveBack = SKAction.moveTo(x: rocketPositions[i].x, duration: time)
                let endRocketsMoving = SKAction.customAction(withDuration: 0.01, actionBlock: {
                    [weak self] _,_ in
                    self?.rocketsMoving = false
                })
                
                let sequence = SKAction.sequence([moveBack, endRocketsMoving])
                
                rocketCropNode.children[i].run(sequence)
            }
            return
        }
        for child in rocketCropNode.children {
            let currentXPosition = child.position.x
            
            var closestXPosition: CGFloat = 0
            var smallestPositionDifference: CGFloat = 350
            
            for i in 0...rocketCropNode.children.count {
                let positiveXDifference = abs(child.position.x - CGFloat(i*350))
                let negativexDifference = abs(child.position.x - CGFloat(-i*350))
                
                if positiveXDifference < smallestPositionDifference {
                    closestXPosition = CGFloat(i*350)
                    smallestPositionDifference = positiveXDifference
                } else if negativexDifference < smallestPositionDifference {
                    closestXPosition = CGFloat(-i*350)
                    smallestPositionDifference = negativexDifference
                }
            }
            
            let speedFactor = abs(closestXPosition - currentXPosition)/350
            var time = Double(1.5*speedFactor)
            
            if time < 0.1 {
                time = 0.1
            }
            
            let moveRight = SKAction.moveTo(x: closestXPosition, duration: time)
            let endRocketsMoving = SKAction.customAction(withDuration: 0.01, actionBlock: {
                [weak self] _,_ in
                self?.rocketsMoving = false
            })
            let sequence = SKAction.sequence([moveRight, endRocketsMoving])
            
            child.run(sequence)
        }
        
        for i in 0...(rocketCropNode.children.count - 1) {
            var closestXPosition: CGFloat = 0
            var smallestPositionDifference: CGFloat = 350
            
            for j in 0...rocketCropNode.children.count {
                let positiveXDifference = abs(rocketCropNode.children[i].position.x - CGFloat(j*350))
                let negativexDifference = abs(rocketCropNode.children[i].position.x - CGFloat(-j*350))
                
                if positiveXDifference < smallestPositionDifference {
                    closestXPosition = CGFloat(j*350)
                    smallestPositionDifference = positiveXDifference
                } else if negativexDifference < smallestPositionDifference {
                    closestXPosition = CGFloat(-j*350)
                    smallestPositionDifference = negativexDifference
                }
            }
            
            rocketPositions[i] = CGPoint(x: closestXPosition, y: 0)
        }
    }
}
