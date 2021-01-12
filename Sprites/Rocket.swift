//
//  Missile.swift
//  Shaky Rocket
//
//  Created by macbook on 1/19/20.
//  Copyright © 2020 example. All rights reserved.
//

import SpriteKit

class Rocket: SKSpriteNode {
    var rocketName: String!
    
    var fireActive = false {
        didSet {
            if self.fireActive == true {
                let emitter = SKEmitterNode(fileNamed: "RocketFire")!
                let emitter2 = SKEmitterNode(fileNamed: "RocketFire")!
                var fireDirectionNegative = true
                var twoFires = false
                if rocketName == "spaceRockets_001" || rocketName == "spaceRockets_004" || rocketName == "spaceRockets_003" {
                    emitter.position = CGPoint(x: 0, y: -59)
                } else if rocketName == "spaceShips_002" {
                    fireDirectionNegative = false
                    twoFires = true
                    emitter.position = CGPoint(x: 12, y: 40)
                    emitter2.position = CGPoint(x: -12, y: 40)
                } else if rocketName == "spaceShips_004" {
                    fireDirectionNegative = false
                    twoFires = true
                    emitter.position = CGPoint(x: 12, y: 43)
                    emitter2.position = CGPoint(x: -12, y: 43)
                } else if rocketName == "spaceShips_006" {
                    fireDirectionNegative = false
                    emitter.position = CGPoint(x: 0, y: 55)
                } else if rocketName == "spaceShips_007" {
                    fireDirectionNegative = false
                    twoFires = true
                    emitter.position = CGPoint(x: 12, y: 40)
                    emitter2.position = CGPoint(x: -12, y: 40)
                } else {
                    emitter.position = CGPoint(x: 0, y: -37)
                }
                let sequence = SKAction.sequence([
                    SKAction.run({
                        [weak self] in
                        if fireDirectionNegative {
                            emitter.particleSpeed = -40
                            emitter.yAcceleration = -100
                        } else {
                            emitter.particleSpeed = 40
                            emitter.yAcceleration = 100
                            emitter2.particleSpeed = 40
                            emitter2.yAcceleration = 100
                        }
                        
                        let fastEffect = SKEmitterNode(fileNamed: "FastEffect")!
                        fastEffect.name = "FastEffect"
                        fastEffect.position = CGPoint(x: 333.5, y: 187.5)
                        fastEffect.xScale = 500
                        self?.parent?.addChild(fastEffect)
                        
                        if UserDefaults.standard.bool(forKey: "soundFXOn") {
                            if let url = Bundle.main.url(forResource: "WarpSpeed", withExtension: ".wav") {
                                let warpSound = SKAudioNode(url: url)
                                warpSound.autoplayLooped = false
                                warpSound.isPositional = true
                                warpSound.name = "warpSound"
                                self?.addChild(warpSound)
                                warpSound.run(SKAction.play())
                            }
                        }
                    }),
                    
                    SKAction.wait(forDuration: 8.7),
                    
                    SKAction.run ({
                        [weak self] in
                        if fireDirectionNegative {
                            emitter.particleSpeed = -200
                            emitter.yAcceleration = -1500
                        } else {
                            emitter.particleSpeed = 200
                            emitter.yAcceleration = 1500
                            emitter2.particleSpeed = 200
                            emitter2.yAcceleration = 1500
                        }
                        
                        for child in self!.parent!.children {
                            if child.name == "scoreLabel" {
                                if let scoreLabel = child as? SKLabelNode {
                                    scoreLabel.fontColor = .white
                                }
                            }
                            if child.name == "FastEffect" {
                                child.removeFromParent()
                                self?.childNode(withName: "warpSound")?.removeFromParent()
                                if UserDefaults.standard.bool(forKey: "soundFXOn") {
                                    if let url = Bundle.main.url(forResource: "Rocket", withExtension: ".wav") {
                                        let rocketSound = SKAudioNode(url: url)
                                        rocketSound.autoplayLooped = false
                                        self?.addChild(rocketSound)
                                        rocketSound.run(SKAction.play())
                                    }
                                }
                            }
                        }
                    })
                ])
                addChild(emitter)
                if twoFires {
                    addChild(emitter2)
                }
                emitter.run(sequence)
            }
            if self.fireActive == false {
                for child in children {
                    child.removeFromParent()
                }
            }
        }
    }
}
