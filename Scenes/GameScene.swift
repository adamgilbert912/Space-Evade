//
//  GameScene.swift
//  Shaky Rocket
//
//  Created by macbook on 1/11/20.
//  Copyright © 2020 example. All rights reserved.
//

import SpriteKit
import GameplayKit

//THINGS TO CHECK
//spaceships 2 physics body, 


// PROBLEMS
// weird rare glitch where game score keeps going up after death and the stat menu is messed up, happened with spaceShips_006 near bottom of screen, happened again bottom left corner of screen
// Make asteroids have more specific physics bodies

class GameScene: SKScene, SKPhysicsContactDelegate {
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var coins = 0
    var counter = 0 //counts frames
    let countDownLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    var countDown = 5 {
        didSet {
            if countDown > 0 {
                countDownLabel.text = "\(countDown)"
            } else if countDown == 0 {
                countDownLabel.text = nil
            }
        }
    }
    var stars: SKEmitterNode!
    
    //used to distinguish time between now and an event
    var sendSatelliteCount = 0
    var satelliteDistanceCount: Int?
    var sendUFOCount = 0
    var missilePowerUpCount = 0
    var fastPowerUpCount: Int?
    var slowDownCount = 0
    
    var powerUpTimes = [Int]()
    var currentUFO: UFO?
    
    var missilePosition: [CGFloat] = [13, -13]
    
    //newest points of sprites
    var asteroidPoint: CGPoint?
    var satellitePoint: CGPoint?
    
    //Sprites
    var rocketSprite: Rocket!
    var rocketName: String
    
    //Physics Bodies
    var rocketSpriteBody: CGMutablePath!
    
    var UFOSound: SKAudioNode!
    var gameMusic: SKAudioNode!

    //Game States
    var gameStarted = false
    var gameOver = false
    var misslePowerUp = false
    var moreObjects = false
    var slowingDown = false
    var fastPowerUp = false
    var isForceFieldEnding = false
    var userRewarded = false
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(size: CGSize, rocketName: String) {
        self.rocketName = rocketName
        super.init(size: size)
    }
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(showStatMenu), name: NSNotification.Name("showStats"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setUserRewarded), name: NSNotification.Name("setUserRewarded"), object: nil)
        
        let background = SKSpriteNode(color: .black, size: CGSize(width: 667, height: 375))
        background.zPosition = -2
        background.position = CGPoint(x: 333.5, y: 187.5)
        addChild(background)
            
        scene?.scaleMode = .aspectFit
        
        stars = SKEmitterNode(fileNamed: "Stars")!
        stars.position = CGPoint(x: 667, y: 187.5)
        stars.advanceSimulationTime(10)
        addChild(stars)
        
        if UserDefaults.standard.bool(forKey: "musicOn") {
            if let url = Bundle.main.url(forResource: "GameMusic", withExtension: ".mp3") {
                gameMusic = SKAudioNode(url: url)
                addChild(gameMusic)
                gameMusic.run(SKAction.changeVolume(to: 0.5, duration: 0.01))
            }
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            [weak self] in
            
            if let url = Bundle.main.url(forResource: "UFO", withExtension: ".wav") {
                self?.UFOSound = SKAudioNode(url: url)
            }
            self?.UFOSound.autoplayLooped = false
            self?.UFOSound.isPositional = true
        }
        
        scoreLabel = SKLabelNode(fontNamed: "ChalkboardSE-Regular")
        scoreLabel.fontSize = 20
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.text = "Score: \(score)"
        scoreLabel.zPosition = 4
        scoreLabel.position = CGPoint(x: 587, y: 360)
        scoreLabel.name = "scoreLabel"
        addChild(scoreLabel)
        
        countDownLabel.fontSize = 50
        countDownLabel.fontColor = .yellow
        countDownLabel.position = CGPoint(x: 333.5, y: 187.5)
        countDownLabel.text = "5"
        addChild(countDownLabel)
        
        rocketSpriteBody = CGMutablePath()
        
        rocketSprite = Rocket(imageNamed: rocketName)
        rocketSprite.rocketName = rocketName
        rocketSprite.position = CGPoint(x: 80, y: 187.5)
        rocketSprite.name = "rocket"
        rocketSprite.zPosition = 2
        
        if rocketName == "spaceRockets_003" {
            rocketSprite.zRotation = -CGFloat.pi/2
            rocketSpriteBody.addLines(between: [CGPoint(x: -16, y: 13.5), CGPoint(x: 0, y: 42.5), CGPoint(x: 16, y: 13.5), CGPoint(x: 16, y: -29.5), CGPoint(x: 8.5, y: -42.5), CGPoint(x: -8.5, y: -42.5), CGPoint(x: -16, y: -29.5)])
        } else if rocketName == "playerShip1_blue" || rocketName == "playerShip1_green" {
            rocketSprite.zRotation = -CGFloat.pi/2
            rocketSprite.size = CGSize(width: rocketSprite.size.width*0.5, height: rocketSprite.size.height*0.5)
            rocketSpriteBody.addLines(between: [CGPoint(x: 0, y: -37.5/2), CGPoint(x: 47-(49.5/2), y: -(31-(37.5/2))), CGPoint(x: 48-(49.5/2), y: (37.5/2)-16), CGPoint(x: 0, y: 37.5/2), CGPoint(x: 1-(49.5/2), y: (37.5/2)-16), CGPoint(x: 2-(49.5/2), y: -(31-(37.5/2)))])
            
        } else if rocketName == "playerShip3_blue" || rocketName == "playerShip3_green" {
            rocketSprite.zRotation = -CGFloat.pi/2
            rocketSprite.size = CGSize(width: rocketSprite.size.width*0.5, height: rocketSprite.size.height*0.5)
            rocketSpriteBody.addLines(between: [CGPoint(x: 0, y: 37.5/2), CGPoint(x: -49/2, y: -(32-(37.5/2))), CGPoint(x: 0, y: -37.5/2), CGPoint(x: 49/2, y: -(32-(37.5/2)))])
        } else if rocketName == "spaceRockets_001" {
            rocketSprite.zRotation = -CGFloat.pi/2
            let scaleFactor = 79/rocketSprite.size.height
            rocketSprite.size = CGSize(width: rocketSprite.size.width*(scaleFactor), height: 79)
            rocketSpriteBody.addLines(between: [CGPoint(x: (-122/2)*scaleFactor, y: (-374/2)*scaleFactor), CGPoint(x: (122/2)*scaleFactor, y: (-374/2)*scaleFactor), CGPoint(x: (122/2)*scaleFactor, y: ((374/2) - 201)*scaleFactor), CGPoint(x: (94-(122/2))*scaleFactor, y: ((374/2) - 201)*scaleFactor), CGPoint(x: (94 - (122/2))*scaleFactor, y: ((374/2) - 75)*scaleFactor), CGPoint(x: 0, y: (374/2)*scaleFactor), CGPoint(x: (26 - (122/2))*scaleFactor, y: ((374/2) - 75)*scaleFactor), CGPoint(x: (26 - (122/2))*scaleFactor, y: ((374/2) - 201)*scaleFactor), CGPoint(x: (-122/2)*scaleFactor, y: ((374/2) - 201)*scaleFactor)])
        } else if rocketName == "spaceRockets_004" {
            rocketSprite.zRotation = -CGFloat.pi/2
            let scaleFactor = 79/rocketSprite.size.height
            rocketSprite.size = CGSize(width: rocketSprite.size.width*scaleFactor, height: 79)
            rocketSpriteBody.addLines(between: [CGPoint(x: 0, y: 79/2), CGPoint(x: 10 - (29.12/2), y: (79/2) - 4), CGPoint(x: 10 - (29.12/2), y: (79/2) - 9), CGPoint(x: 7.5 - (29.12/2), y: (79/2) - 12.5), CGPoint(x: 7.5 - (29.12/2), y: (79/2) - 57), CGPoint(x: -29.12/2, y: (79/2) - 68), CGPoint(x: -29.12/2, y: (79/2) - 75), CGPoint(x: 7.5 - (29.12/2), y: (79/2) - 68), CGPoint(x: 9 - (29.12/2), y: (-79/2)), CGPoint(x: 20 - (29.12/2), y: -79/2), CGPoint(x: 21.5 - (29.12/2), y: (79/2) - 68), CGPoint(x: 29.12/2, y: (79/2) - 75), CGPoint(x: 29.12/2, y: (79/2) - 68), CGPoint(x: 21.5 - (29.12/2), y: (79/2) - 57), CGPoint(x: 21.5 - (29.12/2), y: (79/2) - 12.5), CGPoint(x: 18.5 - (29.12/2), y: (79/2) - 9.5), CGPoint(x: 18.5 - (29.12/2), y: (79/2) - 4.5)])
        } else if rocketName == "spaceShips_002" {
            rocketSprite.zRotation = CGFloat.pi/2
            rocketSprite.size = CGSize(width: rocketSprite.size.width*0.55, height: rocketSprite.size.height*0.55)
            rocketSpriteBody.addLines(between: [CGPoint(x: 8 - (55.55/2), y: 40.7/2), CGPoint(x: -55.55/2, y: 24.5 - (40.7/2)), CGPoint(x: 13.5 - (55.55/2), y: -40.7/2), CGPoint(x: 42.5 - (55.55/2), y: -40.7/2), CGPoint(x: 55.55/2, y: 24.5 - (40.7/2)), CGPoint(x: 48 - (55.55/2), y: 40.7/2)])
        } else if rocketName == "spaceShips_004" {
            rocketSprite.zRotation = CGFloat.pi/2
            rocketSprite.size = CGSize(width: rocketSprite.size.width*0.45, height: rocketSprite.size.height*0.45)
            rocketSpriteBody.addLines(between: [CGPoint(x: 10.5 - (56.7/2), y: -48.6/2), CGPoint(x: -56.7/2, y: 28.5 - (48.6/2)), CGPoint(x: 7.5 - (56.7/2), y: 48.6/2), CGPoint(x: 49.5 - (56.7/2), y: 48.6/2), CGPoint(x: 56.7/2, y: 28.5 - (48.6/2)), CGPoint(x: 46 - (56.7/2), y: -48.6/2)])
        } else if rocketName == "spaceShips_006" {
            rocketSprite.zRotation = CGFloat.pi/2
            rocketSprite.size = CGSize(width: rocketSprite.size.width*0.46, height: rocketSprite.size.height*0.46)
            //might be not correct
            rocketSpriteBody.addLines(between: [CGPoint(x: 12.5 - (43.24/2), y: -68.08/2), CGPoint(x: -43.24/2, y: 52.5 - (68.08/2)), CGPoint(x: 3.5 - (43.24/2), y: 30.5 - (68.08/2)), CGPoint(x: 14.5 - (43.24/2), y: 27.5 - (68.08/2)), CGPoint(x: 14.5 - (43.24/2), y: 68.08/2), CGPoint(x: 29 - (43.24/2), y: 68.08/2), CGPoint(x: 29 - (43.24/2), y: 27.5 - (68.08/2)), CGPoint(x: 40 - (43.24/2), y: 30.5 - (68.08/2)), CGPoint(x: 43.24/2, y: 52.5 - (68.08/2)), CGPoint(x: 31 - (43.24/2), y: -68.08/2)])
        } else if rocketName == "spaceShips_007" {
            rocketSprite.zRotation = CGFloat.pi/2
            rocketSprite.size = CGSize(width: rocketSprite.size.width*0.3, height: rocketSprite.size.height*0.3)
            rocketSpriteBody.addLines(between: [CGPoint(x: 8 - (51.6/2), y: 45.3/2), CGPoint(x: 11.5 - (51.6/2), y: (43.5/2) - 5), CGPoint(x: 17.5 - (51.6/2), y: (43.5/2) - 5), CGPoint(x: 17.5 - (51.6/2), y: (43.5/2) - 13.5), CGPoint(x: 33.5 - (51.6/2), y: (43.5/2) - 5), CGPoint(x: 40 - (51.6/2), y: (43.5/2) - 5), CGPoint(x: 43.5 - (51.6/2), y: 43.5/2), CGPoint(x: 46 - (51.6/2), y: (43.5/2) - 2), CGPoint(x: 42 - (51.6/2), y: (43.5/2) - 14), CGPoint(x: 43.5 - (51.6/2), y: (43.5/2) - 17.5), CGPoint(x: 40 - (51.6/2), y: (43.5/2) - 23), CGPoint(x: 51.6/2, y: (43.5/2) - 35), CGPoint(x: 50.5 - (51.6/2), y: (43.5/2) - 42.5), CGPoint(x: 44.5 - (51.6/2), y: (43.5/2) - 42.5), CGPoint(x: 38 - (51.6/2), y: (43.5/2) - 38), CGPoint(x: 13 - (51.6/2), y: (43.5/2) - 38), CGPoint(x: 7 - (51.6/2), y: -43.5/2), CGPoint(x: 0.5 - (51.6/2), y: (43.5/2) - 42.5), CGPoint(x: -51.6/2, y: (43.5/2) - 35), CGPoint(x: 11 - (51.6/2), y: (43.5/2) - 23), CGPoint(x: 7 - (51.6/2), y: (43.5/2) - 17), CGPoint(x: 9 - (51.6/2), y: (43.5/2) - 13.5), CGPoint(x: 6 - (51.6/2), y: (43.5/2) - 1.5)])
        }
        addChild(rocketSprite)
        
        powerUpTimes = [Int.random(in: 1500...1600), Int.random(in: 5000...6000), Int.random(in: 9000...9500), Int.random(in: 11500...12500), Int.random(in: 14000...15000), Int.random(in: 17500...18500), Int.random(in: 21000...22000), Int.random(in: 25000...26000), Int.random(in: 29000...30000), Int.random(in: 33000...34000), Int.random(in: 37000...38000), Int.random(in: 41000...42000), Int.random(in: 45000...46000), Int.random(in: 49000...50000), Int.random(in: 53000...54000), Int.random(in: 57000...58000), Int.random(in: 61000...62000), Int.random(in: 65000...66000), Int.random(in: 69000...70000), Int.random(in: 73000...74000), Int.random(in: 77000...78000), Int.random(in: 81000...82000), Int.random(in: 85000...86000), Int.random(in: 89000...90000), Int.random(in: 93000...94000), Int.random(in: 97000...98000)] //add more possibly
        
        let blackScreen = SKSpriteNode(color: .black, size: CGSize(width: 667, height: 375))
        blackScreen.alpha = 1
        blackScreen.position = CGPoint(x: 333.5, y: 187.5)
        blackScreen.zPosition = 7
        
        let fadeOut = SKAction.fadeOut(withDuration: 3)
        let startGame = SKAction.customAction(withDuration: .leastNonzeroMagnitude, actionBlock: {
            [weak self] _,_ in
            self?.gameStarted = true
        })
        let sequence = SKAction.sequence([fadeOut, startGame])
        
        addChild(blackScreen)
        blackScreen.run(sequence)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let _ = touches.first else {return}
        guard let rocketBody = rocketSprite.physicsBody else {return}
        
        let point = rocketSprite.position
        let force = 2917.9327 * rocketBody.mass
        
        if !fastPowerUp || !slowingDown {
            rocketBody.applyForce(CGVector(dx: 0, dy: force), at: point)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // add destroy asteroids once they are outside of the frame
            counter += 1
        
        let defaults = UserDefaults.standard
        
        for child in children {
            if child.position.x < -70 || child.position.y > 425 || child.position.y < -70 {
                child.removeFromParent()
            }
        }
        
        if !gameOver {
            if rocketSprite.position.y > 390 || rocketSprite.position.y < -15 || rocketSprite.position.x < -50 {
                rocketExplosion(rocket: rocketSprite)
            }
        }
        
        if countDown == 3 {
            if UserDefaults.standard.integer(forKey: "highScore") == 0 {
                if self.childNode(withName: "tapText") == nil {
                    let tapText = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
                    tapText.name = "tapText"
                    tapText.text = "Tap!"
                    tapText.alpha = 0.1
                    tapText.fontSize = 54
                    tapText.fontColor = .green
                    tapText.position = CGPoint(x: 333.5, y: 257.5)
                    
                    let fadeIn = SKAction.fadeAlpha(by: 0.6, duration: 1)
                    let fadeOut = SKAction.fadeAlpha(by: -0.6, duration: 1)
                    let sequence = SKAction.sequence([fadeIn, fadeOut])
                    let count = SKAction.repeat(sequence, count: 3)
                    let sequence2 = SKAction.sequence([count, SKAction.removeFromParent()])
                    
                    addChild(tapText)
                    
                    tapText.run(sequence2)
                }
            }
        }
        
        if countDown < 1 {
            if !gameOver {
                if counter % 60 == 0 {
                    score += 1
                }
            }
        }
        
        if !gameOver {
            for node in children {
                
                let xDifference = abs(rocketSprite.position.x - node.position.x)
                let yDifference = abs(rocketSprite.position.y - node.position.y)
                
                if let powerUp = node as? PowerUp {
                    
                    if powerUp.name == "missle" {
                        
                        if xDifference <= 7 && yDifference <= 20.4 {
                            misslePowerUp = true
                            missilePowerUpCount = counter
                            powerUp.removeFromParent()
                        }
                        
                    } else if powerUp.name == "fast" {
                        
                        if xDifference <= 16 && yDifference <= 22.75 {
                            rocketSprite.fireActive = true
                            fastPowerUp = true
                            moreObjects = true
                            currentUFO?.isNormalSpeed = false
                            
                            rocketSprite.physicsBody = SKPhysicsBody(circleOfRadius: 51.75)
                            rocketSprite.physicsBody?.categoryBitMask = UInt32(4)
                            rocketSprite.physicsBody?.collisionBitMask = UInt32(1)
                            rocketSprite.physicsBody?.contactTestBitMask = rocketSprite.physicsBody!.collisionBitMask
                            rocketSprite.physicsBody?.affectedByGravity = false
                            rocketSprite.physicsBody?.mass = 99999999999
                            rocketSprite.physicsBody?.linearDamping = 99999999
                            
                            physicsWorld.gravity = CGVector(dx: physicsWorld.gravity.dx, dy: physicsWorld.gravity.dy / 3)
                            
                            fastPowerUpCount = 0
                            let move = SKAction.move(to: CGPoint(x: 333.5, y: 187.5), duration: 4)
                            rocketSprite.run(move)
                            fastPowerUpCount = counter
                            physicsWorld.speed = 3
                            stars.particleSpeed = stars.particleSpeed * 3
                            scoreLabel.fontColor = .black
                            
                            powerUp.removeFromParent()
                        }
                    } else if powerUp.name == "Nuclear" {
                        
                        if xDifference <= 22 && yDifference <= 22 {
                            powerUp.removeFromParent()
                            var scoreToAdd = 0
                            
                            if defaults.bool(forKey: "soundFXOn") {
                                if let url = Bundle.main.url(forResource: "Nuke", withExtension: ".wav") {
                                    let sound = SKAudioNode(url: url)
                                    sound.autoplayLooped = false
                                    sound.isPositional = false
                                    addChild(sound)
                                    sound.run(SKAction.play())
                                }
                            }
                            for node in children {
                                if node.name == "asteroid" || node.name == "satellite" {
                                    let explosion = SKEmitterNode(fileNamed: "MissileExplosion")!
                                    explosion.position = node.position
                                    addChild(explosion)
                                    
                                    if node.name == "asteroid" {
                                        let asteroidExplosion = SKEmitterNode(fileNamed: "RockExplosion")!
                                        asteroidExplosion.position = node.position
                                        scoreToAdd += 1
                                        
                                        addChild(asteroidExplosion)
                                    } else if node.name == "satellite" {
                                        let satelliteExplosion = SKEmitterNode(fileNamed: "SatelliteExplosion")!
                                        satelliteExplosion.position = node.position
                                        scoreToAdd += 2
                                        
                                        addChild(satelliteExplosion)
                                    }
                                    
                                    for _ in 1...5 {
                                        sendCoin(blowUp: true, starting: node.position)
                                    }
                                    
                                    node.removeFromParent()
                                }
                            }
                            addToScore(add: scoreToAdd)
                        }
                    }
                } else if let coin = node as? Coin {
                    if xDifference <= 23 && yDifference <= 7 {
                        if defaults.bool(forKey: "soundFXOn") {
                            if Int.random(in: 0...1) == 0 {
                                if let url = Bundle.main.url(forResource: "Coin1", withExtension: ".wav") {
                                    let coinSound1 = SKAudioNode(url: url)
                                    coinSound1.autoplayLooped = false
                                    addChild(coinSound1)
                                    coinSound1.run(SKAction.play())
                                }
                            } else {
                                if let url = Bundle.main.url(forResource: "Coin2", withExtension: ".wav") {
                                    let coinSound2 = SKAudioNode(url: url)
                                    coinSound2.autoplayLooped = false
                                    addChild(coinSound2)
                                    coinSound2.run(SKAction.play())
                                }
                            }
                        }
                        coin.removeFromParent()
                        coins += 1
                    }
                }
            }
        }
        //480
        if counter % 480 == 0 {
            sendCoin(blowUp: false, starting: nil)
            }
        
        //countdown
            if counter % 60 == 0 {
                if countDown > -1 {
                    countDown -= 1
                }
            }
        
        //lets the rocket have physics after initial countdown
        if countDown == 0 {
            rocketSprite.physicsBody = SKPhysicsBody(polygonFrom: rocketSpriteBody)
            rocketSprite.physicsBody?.categoryBitMask = UInt32(0)
            rocketSprite.physicsBody?.collisionBitMask = UInt32(1)
            rocketSprite.physicsBody?.contactTestBitMask = rocketSprite.physicsBody!.collisionBitMask
            rocketSprite.physicsBody?.angularDamping = 99999999
        }
        
        if powerUpTimes.contains(counter) {
            sendPowerUp()
        }
        
        if misslePowerUp {
            if counter - missilePowerUpCount < 900 {
                if counter % 50 == 0 {
                    if !gameOver {
                        sendMissiles()
                    }
                }
            } else {
                misslePowerUp = false
            }
        }
    
        if let fastPowerUpCount = fastPowerUpCount {
            if counter - fastPowerUpCount > 900 {
                let move = SKAction.move(to: CGPoint(x: 80, y: 187.5), duration: 11)
                self.fastPowerUpCount = nil
                currentUFO?.isSlowingDown = true
                slowingDown = true
                moreObjects = false
                rocketSprite.run(move)
                rocketSprite.fireActive = false
                slowDown()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 11.001) {
                    [weak self] in
                    self?.slowingDown = false
                    self?.rocketSprite.physicsBody?.affectedByGravity = true
                    self?.currentUFO?.isNormalSpeed = true
                    self?.currentUFO?.isSlowingDown = false
                    self?.rocketSprite.physicsBody?.linearDamping = 0
                    self?.physicsWorld.gravity = CGVector(dx: self!.physicsWorld.gravity.dx, dy: self!.physicsWorld.gravity.dy * 3)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 12.001) {
                    [weak self] in
                    
                    let emitter = SKEmitterNode(fileNamed: "ForceFieldCountDown")!
                    self?.rocketSprite.addChild(emitter)
                    self?.fastPowerUp = false
                    self?.isForceFieldEnding = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 15.001) {
                    [weak self] in
                    //fixes problem of rocketSprite stopping movement when new physics body is created
                    let velocity = self!.rocketSprite.physicsBody!.velocity
                    
                    self?.rocketSprite.physicsBody = SKPhysicsBody(polygonFrom: self!.rocketSpriteBody)
                    self?.rocketSprite.physicsBody?.velocity = velocity
                    self?.rocketSprite.physicsBody?.collisionBitMask = UInt32(1)
                    self?.rocketSprite.physicsBody?.categoryBitMask = UInt32(0)
                    self?.rocketSprite.physicsBody?.contactTestBitMask = self!.rocketSprite.physicsBody!.collisionBitMask
                    self?.rocketSprite.physicsBody?.angularDamping = 99999999
                    self?.isForceFieldEnding = false
                }
            } else {
                if counter % 60 == 0 {
                    addToScore(add: 2)
                }
            }
        }
        
        //increasing asteroids sent
        if counter < 1080 {
            if counter % 360 == 0 {
                sendAsteroid()
            }
        } else if counter < 2280 {
            if counter % 180 == 0 {
                sendAsteroid()
            }
        } else if counter < 3480 {
            if counter % 120 == 0 {
                sendAsteroid()
            }
        } else if counter < 4680 {
            if counter % 90 == 0 {
                sendAsteroid()
            }
            
            if counter % 60 == 0 { //decreases probability of satellite appearing every 10 sec
                satelliteDistanceCount? += 1
                
                if counter - sendSatelliteCount > Int.random(in: 600...1200) {
                    sendSatellite()
                    sendSatelliteCount = counter
                }
            }
        } else if counter > 4680 {
            if !moreObjects {
                if counter % 75 == 0 {
                    sendAsteroid()
                }
                
                if counter % 60 == 0 { //decreases probability of satellite appearing every 10 sec
                    satelliteDistanceCount? += 1
                    
                    if counter - sendSatelliteCount > Int.random(in: 450...720) {
                        sendSatellite()
                        sendSatelliteCount = counter
                    }
                }
                
                if counter - sendUFOCount > 1260 {
                    sendUFOCount = counter
                    sendUFO()
                }
            } else {
                if counter % 60 == 0 {
                    sendAsteroid()
                }
                
                if counter % 60 == 0 { //decreases probability of satellite appearing every 10 sec
                    
                    if counter - sendSatelliteCount > Int.random(in: 400...640) {
                        sendSatellite()
                        sendSatelliteCount = counter
                    }
                }
                
                if counter - sendUFOCount > 960 {
                    sendUFOCount = counter
                    sendUFO()
                }
            }
        }
    }
    
    func sendAsteroid() {
        let int2 = -80
        
        let  asteroid = SKSpriteNode(imageNamed: "spaceMeteors_00\(Int.random(in: 1...4))")
        
        asteroid.size = CGSize(width: 53.78, height: 54.78) //average width and height divided by 8
        asteroid.physicsBody = SKPhysicsBody(circleOfRadius: asteroid.size.width/2) //might need to be fixed just a circle right now but the asteroids are pretty round
        asteroid.physicsBody?.affectedByGravity = false
        asteroid.physicsBody?.velocity = CGVector(dx: Int.random(in: -100...int2), dy: 0)
        asteroid.physicsBody?.linearDamping = 0
        asteroid.physicsBody?.angularVelocity = CGFloat.random(in: -2...2)
        asteroid.name = "asteroid"
        asteroid.physicsBody?.categoryBitMask = UInt32(1)
        asteroid.physicsBody?.collisionBitMask = UInt32(0) | UInt32(1) | UInt32(4)
        asteroid.physicsBody?.contactTestBitMask = asteroid.physicsBody!.collisionBitMask
        
        
        //used to ensure that asteroids dont run into satellites so often
        if let y = satellitePoint?.y {
            if y < 253.11 && y > 121.89 {
                if satelliteDistanceCount! < 5 {
                    let bottomPosition = y - 45 - 26.89
                    let topPosition = y + 45 + 26.89
                    let range1 = 20...bottomPosition
                    let range2 = topPosition...355
                    var ranges = [range1, range2]
                    ranges.shuffle()
                    asteroid.position = CGPoint(x: 700, y: CGFloat.random(in: ranges.first!))
                } else {
                    asteroid.position = CGPoint(x: 700, y: CGFloat.random(in: 20...355))
                }
            } else if y >= 253.11 {
                if satelliteDistanceCount! < 5 {
                    let bottomPosition = y-45-26.89
                    let range = 20...bottomPosition
                    asteroid.position = CGPoint(x: 700, y: CGFloat.random(in: range))
                } else {
                    asteroid.position = CGPoint(x: 700, y: CGFloat.random(in: 20...355))
                }
            } else if y <= 121.89 {
                if satelliteDistanceCount! < 5 {
                    let topPosition = y+45+26.89
                    let range = topPosition...325
                    asteroid.position = CGPoint(x: 700, y: CGFloat.random(in: range))
                } else {
                    asteroid.position = CGPoint(x: 700, y: CGFloat.random(in: 20...355))
                }
            } else {
                asteroid.position = CGPoint(x: 700, y: CGFloat.random(in: 20...355))
            }
        } else {
            asteroid.position = CGPoint(x: 700, y: CGFloat.random(in: 20...355))
        }
        
        asteroidPoint = asteroid.position
        addChild(asteroid)
    }
    
    func sendSatellite() {
        let number = Int.random(in: 8...9)
        let satellite = Satellite(imageNamed: "spaceStation_01\(number)")
        satellite.size = CGSize(width: 86, height: 26)
        satellite.physicsBody = SKPhysicsBody(rectangleOf: satellite.size)
        satellite.physicsBody?.affectedByGravity = false
        satellite.physicsBody?.angularDamping = 0
        satellite.physicsBody?.categoryBitMask = UInt32(1)
        satellite.physicsBody?.collisionBitMask = UInt32(0) | UInt32(1) | UInt32(4)
        satellite.physicsBody?.contactTestBitMask = satellite.physicsBody!.collisionBitMask
        satellite.physicsBody?.linearDamping = 0
        
            satellite.physicsBody?.velocity = CGVector(dx: -50, dy: 0)
        
        if number == 8 {
            satellite.physicsBody?.angularVelocity = 4
        } else {
            satellite.physicsBody?.angularVelocity = -4
        }
        
        //used to ensure asteroids dont run into satellites so often
        if let y = asteroidPoint?.y {
            if y < 253.11 && y > 121.89 {
                let bottomPosition = y - 45 - 26.89
                let topPosition = y + 45 + 26.89
                let range1 = 20...bottomPosition
                let range2 = topPosition...355
                var ranges = [range1, range2]
                ranges.shuffle()
                satellite.position = CGPoint(x: 700, y: CGFloat.random(in: ranges.first!))
            } else if y >= 253.11 {
                let bottomPosition = y-45-26.89
                let range = 20...bottomPosition
                satellite.position = CGPoint(x: 700, y: CGFloat.random(in: range))
            } else if y <= 121.89 {
                let topPosition = y+45+26.89
                let range = topPosition...355
                satellite.position = CGPoint(x: 700, y: CGFloat.random(in: range))
            } else {
                satellite.position = CGPoint(x: 700, y: CGFloat.random(in: 20...355))
            }
        } else {
            satellite.position = CGPoint(x: 700, y: CGFloat.random(in: 20...355))
        }
        
        satellitePoint = satellite.position
        satellite.name = "satellite"
        satelliteDistanceCount = 0
        addChild(satellite)
        
        if !gameOver {
            if UserDefaults.standard.bool(forKey: "soundFXOn") {
                if let url = Bundle.main.url(forResource: "Satellite", withExtension: ".wav") {
                    let sound = SKAudioNode(url: url)
                    sound.autoplayLooped = false
                    sound.isPositional = true
                    addChild(sound)
                    sound.run(SKAction.play())
                }
            }
        }
    }
    
    func sendUFO() {
        let UFO1 = UFO(imageNamed: "spaceStation_029")
        UFO1.configure(at: CGPoint(x: 700, y: CGFloat.random(in: 20...300)), move: 0.7)
        UFO1.name = "UFO"
        UFO1.emitter.targetNode = self
        if fastPowerUp {
            UFO1.isNormalSpeed = false
        }
        
        if slowingDown {
            UFO1.isSlowingDown = true
        }
        
        currentUFO = UFO1
        addChild(currentUFO!)
        
        if !gameOver {
            if UserDefaults.standard.bool(forKey: "soundFXOn") {
                currentUFO?.addChild(UFOSound)
                UFOSound.run(SKAction.play())
            }
        }
    }
    
    func sendPowerUp() {
        let powerUp = PowerUp()
        powerUp.configure(at: CGPoint(x: 700, y: CGFloat.random(in: 20...355)))
        addChild(powerUp)
    }
    
    func sendMissiles() {
        let missile = MissileSprite(imageNamed: "spaceMissiles_004")
        missile.zPosition = -1
        let first = missilePosition.first!
        
        missile.configure(at: CGPoint(x: rocketSprite.position.x , y: rocketSprite.position.y + missilePosition.first!))
        
        missilePosition.remove(at: 0)
        missilePosition.append(first)
        
        if UserDefaults.standard.bool(forKey: "soundFXOn") {
            if let url = Bundle.main.url(forResource: "Missile", withExtension: ".wav") {
                let sound = SKAudioNode(url: url)
                sound.name = "missileSound"
                sound.autoplayLooped = false
                sound.isPositional = false
                addChild(sound)
                sound.run(SKAction.changeVolume(to: 0.2, duration: 0.01))
                sound.run(SKAction.play())
            }
        }
        
        addChild(missile)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if let nodeA = contact.bodyA.node as? Satellite {
            guard let nodeB = contact.bodyB.node else {return}
            if nodeB.name == "missile" {
                nodeA.hitNumber += 1
                
                if nodeA.hitNumber == 3 {
                    let emitter1 = SKEmitterNode(fileNamed: "SatelliteExplosion")!
                    emitter1.position = nodeA.position
                    addChild(emitter1)
                    nodeA.removeFromParent()
                    addToScore(add: 2)
                }
                nodeB.removeFromParent()
                let emitter = SKEmitterNode(fileNamed: "MissileExplosion")!
                emitter.position = contact.contactPoint
                addChild(emitter)
                return
            }
        }
        
        if let nodeB = contact.bodyB.node as? Satellite {
            guard let nodeA = contact.bodyA.node else {return}
            if nodeA.name == "missile" {
                nodeB.hitNumber += 1
                
                if nodeB.hitNumber == 3 {
                    let emitter1 = SKEmitterNode(fileNamed: "SatelliteExplosion")!
                    emitter1.position = nodeB.position
                    addChild(emitter1)
                    nodeB.removeFromParent()
                    addToScore(add: 2)
                }
                nodeA.removeFromParent()
                let emitter = SKEmitterNode(fileNamed: "MissileExplosion")!
                emitter.position = contact.contactPoint
                addChild(emitter)
                return
            }
        }
        
        guard let nodeA = contact.bodyA.node  else {return}
        guard let nodeB = contact.bodyB.node else {return}
        
        if !fastPowerUp {
            if !isForceFieldEnding {
                
                if nodeA.name == "rocket" && nodeB.name == "asteroid" {
                    rocketExplosion(rocket: nodeA)
                } else if nodeB.name == "rocket" && nodeA.name == "asteroid" {
                    rocketExplosion(rocket: nodeB)
                } else if nodeA.name == "rocket" && nodeB.name == "satellite" {
                    rocketExplosion(rocket: nodeA)
                } else if nodeB.name == "rocket" && nodeA.name == "sattelite" {
                    rocketExplosion(rocket: nodeB)
                } else if nodeA.name == "rocket" && nodeB.name == "UFO" {
                    rocketExplosion(rocket: nodeA)
                } else if nodeB.name == "rocket" && nodeA.name == "UFO" {
                    rocketExplosion(rocket: nodeB)
                } else if nodeA.name == "missile" && nodeB.name == "asteroid" {
                    let missileExplosion = SKEmitterNode(fileNamed: "MissileExplosion")!
                    missileExplosion.position = contact.contactPoint
                    let rockExplosion = SKEmitterNode(fileNamed: "RockExplosion")!
                    rockExplosion.position = nodeB.position
                    
                    if UserDefaults.standard.bool(forKey: "soundFXOn") {
                        if let url = Bundle.main.url(forResource: "RockBreaking", withExtension: ".wav") {
                            let rockBreakSound = SKAudioNode(url: url)
                            rockBreakSound.autoplayLooped = false
                            rockBreakSound.isPositional = false
                            addChild(rockBreakSound)
                            rockBreakSound.run(SKAction.play())
                            rockBreakSound.run(SKAction.sequence([SKAction.wait(forDuration: 3), SKAction.changeVolume(to: 0.0, duration: 1)]))
                        }
                    }
                    
                    addChild(missileExplosion)
                    addChild(rockExplosion)
                    nodeA.removeFromParent()
                    nodeB.removeFromParent()
                    addToScore(add: 1)
                } else if nodeB.name == "missile" && nodeB.name == "asteroid" {
                    let missileExplosion = SKEmitterNode(fileNamed: "MissileExplosion")!
                    missileExplosion.position = contact.contactPoint
                    let rockExplosion = SKEmitterNode(fileNamed: "RockExplosion")!
                    rockExplosion.position = nodeA.position
                    
                    if UserDefaults.standard.bool(forKey: "soundFXOn") {
                        if let url = Bundle.main.url(forResource: "RockBreaking", withExtension: ".wav") {
                            let rockBreakSound = SKAudioNode(url: url)
                            rockBreakSound.autoplayLooped = false
                            rockBreakSound.isPositional = false
                            addChild(rockBreakSound)
                            rockBreakSound.run(SKAction.play())
                            rockBreakSound.run(SKAction.sequence([SKAction.wait(forDuration: 3), SKAction.changeVolume(to: 0.0, duration: 1)]))
                        }
                    }
                    
                    addChild(missileExplosion)
                    addChild(rockExplosion)
                    nodeA.removeFromParent()
                    nodeB.removeFromParent()
                    addToScore(add: 1)
                } else if nodeA.name == "missile" && nodeB.name == "missile" {
                    nodeA.removeFromParent()
                    nodeB.removeFromParent()
                }
            }
        } else {
            if !isForceFieldEnding {
                if nodeA.name == "rocket" {
                    let emitter = SKEmitterNode(fileNamed: "ForceFieldCircle")!
                    rocketSprite.addChild(emitter)
                    
                } else if nodeB.name == "rocket" {
                    let emitter = SKEmitterNode(fileNamed: "ForceFieldCircle")!
                    rocketSprite.addChild(emitter)
                }
            }
        }
    }
    
    func rocketExplosion(rocket: SKNode) {
        let defaults = UserDefaults.standard
        
        let explosionEmitter = SKEmitterNode(fileNamed: "Explosion")!
        explosionEmitter.position = rocket.position
        explosionEmitter.zPosition = 1
        addChild(explosionEmitter)
        
        if defaults.bool(forKey: "musicOn") {
            gameMusic.removeFromParent()
        }
        rocket.removeFromParent()
        gameOver.toggle()
        
        if defaults.bool(forKey: "soundFXOn") {
            if let url = Bundle.main.url(forResource: "Explosion", withExtension: ".wav") {
                let explosionSound = SKAudioNode(url: url)
                explosionSound.autoplayLooped = false
                addChild(explosionSound)
                
                explosionSound.run(SKAction.play())
            }
        }
        
        let intOrReward = Int.random(in: 1...2)
        let adOrNot = Int.random(in: 1...3)
        var time: Double
        
        if adOrNot != 1 {
            if intOrReward == 2 {
                time = 1.5
            } else {
                time = 0.5
            }
        } else {
            time = 0.5
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
            [weak self] in
            if adOrNot != 1 {
                if intOrReward != 1 {
                    NotificationCenter.default.post(name: NSNotification.Name("showInterstitial"), object: nil)
                } else {
                    let rewardNode = RewardedAd(rectOf: CGSize(width: 400, height: 200), cornerRadius: 4)
                    rewardNode.configure(color: .init(red: 0.7, green: 0.2, blue: 0.2, alpha: 1), menuSize: CGSize(width: 400, height: 200))
                    rewardNode.zPosition = 15
                    rewardNode.isUserInteractionEnabled = true
                    rewardNode.position = CGPoint(x: 333.5, y: 187.5)
                    self?.addChild(rewardNode)
                }
            } else {
                self?.showStatMenu()
            }
        })
    }
    
    @objc func showGameOver() {
        let defaults = UserDefaults.standard
        
        let gameOverLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        gameOverLabel.fontColor = .red
        gameOverLabel.fontSize = 34
        gameOverLabel.text = "GAME OVER!"
        gameOverLabel.position = CGPoint(x: 333.5, y: 187.5)
        gameOverLabel.zPosition = 2
        gameOverLabel.alpha = 0
        addChild(gameOverLabel)
        
        let fadeIn = SKAction.fadeIn(withDuration: 2)
        let sequence = SKAction.sequence([fadeIn])
        
        gameOverLabel.run(sequence)
        
        if defaults.bool(forKey: "soundFXOn") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                [weak self] in
                let url2 = Bundle.main.url(forResource: "GameOverSound3", withExtension: ".wav")!
                let gameOverSound = SKAudioNode(url: url2)
                gameOverSound.autoplayLooped = false
                gameOverSound.run(SKAction.changeVolume(to: 0.4, duration: 0.01))
                self?.addChild(gameOverSound)
                
                gameOverSound.run(SKAction.play())
                
            })
        }
    }
    
    @objc func slowDown() {
        if slowDownCount < 40 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.125) {
                [weak self] in
                self?.physicsWorld.speed -= 0.05
                self?.stars.particleSpeed -= 3.75
                self?.slowDownCount += 1
                self?.slowDown()
            }
        } else {
            stars.particleBirthRate = 20
            slowDownCount = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                [weak self] in
                self?.stars.particleBirthRate = 10
            }
        }
    }
    
    func addToScore(add number: Int) {
        let scoreAdder = SKLabelNode(fontNamed: "ChalkboardSE-Regular")
        
        scoreAdder.fontSize = 20
        scoreAdder.horizontalAlignmentMode = .center
        scoreAdder.text = "+\(number)"
        scoreAdder.fontColor = .green
        scoreAdder.zPosition = 5
        scoreAdder.physicsBody = SKPhysicsBody()
        scoreAdder.physicsBody?.velocity = CGVector(dx: 5, dy: 10)
        scoreAdder.physicsBody?.linearDamping = 0
        scoreAdder.position = CGPoint(x: 647, y: 360)
        
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
        
        score += number
    }
    
    func sendCoin(blowUp: Bool, starting position: CGPoint?) {
        let coin = Coin(imageNamed: "coin")
        
        if blowUp {
            if let startingPosition = position {
                coin.configure(starting: startingPosition, velocity: CGVector(dx: CGFloat.random(in: -50...(-25)), dy: CGFloat.random(in: -25...25)))
            }
        } else {
            coin.configure(starting: CGPoint(x: 700, y: CGFloat.random(in: 5...370)), velocity: nil)
        }
        addChild(coin)
    }
    
    @objc func showStatMenu() {
        
        showGameOver()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5, execute:  {
            [weak self] in
            
            let defaults = UserDefaults.standard
            
            let statMenu = StatMenu(rectOf: CGSize(width: 400, height: 200), cornerRadius: 4)
            statMenu.isUserInteractionEnabled = true
            statMenu.fillColor = .init(red: 0.7, green: 0.2, blue: 0.2, alpha: 1)
            statMenu.position = CGPoint(x: 333.5, y: 187.5)
            statMenu.zPosition = 10
            
            if !self!.userRewarded {
                statMenu.configure(score: self!.score, highScore: defaults.integer(forKey: "highScore"), newCoins: self!.coins, startingCoins: defaults.integer(forKey: "totalCoins"), isUserRewarded: self!.userRewarded)
            } else {
                statMenu.configure(score: self!.score, highScore: defaults.integer(forKey: "highScore"), newCoins: self!.coins + 15, startingCoins: defaults.integer(forKey: "totalCoins"), isUserRewarded: self!.userRewarded)
            }
            self?.addChild(statMenu)
            
            if self!.score > defaults.integer(forKey: "highScore") {
                defaults.set(self!.score, forKey: "highScore")
            }
            
            if !self!.userRewarded {
                defaults.set(defaults.integer(forKey: "totalCoins") + self!.coins, forKey: "totalCoins")
            } else {
                defaults.set(defaults.integer(forKey: "totalCoins") + self!.coins + 15, forKey: "totalCoins")
            }
            
            self!.userRewarded = false
            
        })
    }
    
    @objc func setUserRewarded() {
        userRewarded = true
    }
}
