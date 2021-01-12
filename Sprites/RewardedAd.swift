//
//  RewardedAd.swift
//  Space Evade!
//
//  Created by macbook on 10/24/20.
//  Copyright © 2020 example. All rights reserved.
//

import Foundation
import SpriteKit

class RewardedAd: SKShapeNode {
    
    var time: Timer?
    
    var watchButtonTapped = false
    var exitButtonTapped = false
    
    func configure(color: UIColor, menuSize: CGSize) {
        
        self.fillColor = color
        
        let exitOutline = SKShapeNode(circleOfRadius: 12)
        exitOutline.fillColor = .white
        exitOutline.zPosition = 4
        exitOutline.position = CGPoint(x: menuSize.width/2, y: menuSize.height/2)
        exitOutline.name = "exitOutline"
        addChild(exitOutline)
        
        let exitCoverColor = SKShapeNode(circleOfRadius: 11)
        exitCoverColor.fillColor = color
        exitCoverColor.zPosition = 5
        exitOutline.addChild(exitCoverColor)
        
        let exitSymbol1 = SKShapeNode(rectOf: CGSize(width: 15, height: 4), cornerRadius: 3)
        exitSymbol1.fillColor = .white
        exitSymbol1.zRotation = CGFloat.pi/4
        exitSymbol1.zPosition = 6
        exitOutline.addChild(exitSymbol1)
        
        let exitSymbol2 = SKShapeNode(rectOf: CGSize(width: 15, height: 4), cornerRadius: 3)
        exitSymbol2.fillColor = .white
        exitSymbol2.zRotation = CGFloat.pi * (3/4)
        exitSymbol2.zPosition = 6
        exitOutline.addChild(exitSymbol2)
        
        let maskNode = SKShapeNode(rectOf: menuSize, cornerRadius: 4)
        maskNode.fillColor = .red
        
        let cropNode = SKCropNode()
        cropNode.maskNode = maskNode
        cropNode.name = "cropNode"
        addChild(cropNode)
        
        let labelNode = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        labelNode.text = "Watch a Quick Video"
        labelNode.horizontalAlignmentMode = .center
        labelNode.fontSize = 35
        labelNode.fontColor = .white
        labelNode.zPosition = 1
        labelNode.position = CGPoint(x: 0, y: 65)
        addChild(labelNode)
        
        let labelNode2 = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        labelNode2.text = "for 15 FREE coins???"
        labelNode2.horizontalAlignmentMode = .center
        labelNode2.fontSize = 35
        labelNode2.fontColor = .white
        labelNode2.zPosition = 1
        labelNode2.position = CGPoint(x: 0, y: 22)
        addChild(labelNode2)
        
        let label = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        label.text = "Watch!"
        label.fontSize = 48/1.3
        label.fontColor = UIColor.init(red: 0.7, green: 0.2, blue: 0.2, alpha: 1)
        label.position = CGPoint(x: 0, y: -13)
        label.zPosition = 1
        
        let playButton = SKSpriteNode(imageNamed: "element_grey_rectangle_glossy")
        playButton.position = CGPoint(x: 0, y: -50)
        playButton.zPosition = 1
        playButton.size = CGSize(width: 192/1.2, height: 96/1.2)
        playButton.addChild(label)
        playButton.name = "watchButton"
        addChild(playButton)
        
        startCoins(size: menuSize)
    }
    
    private func startCoins(size: CGSize) {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: {
            [weak self] _ in
            
            self?.createCoin(size: size)
        })
    }
    
    private func createCoin(size: CGSize) {
        let coin = SKSpriteNode(imageNamed: "coin")
        coin.size = CGSize(width: 15, height: 15)
        coin.zPosition = 0
        coin.position = CGPoint(x: CGFloat.random(in: -size.width/2...size.width/2), y: size.height/2 + 15/2)
        coin.name = "coin"
        childNode(withName: "cropNode")!.addChild(coin)
        
        coin.run(SKAction.move(by: CGVector(dx: 0, dy: -400), duration: 2))
        
        let faster = SKAction.speed(by: 10, duration: 10)
        let sequence = SKAction.sequence([faster, SKAction.removeFromParent()])
        
        coin.run(sequence)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        
        let objects = nodes(at: location)
        
        for node in objects {
            if node.name == "watchButton" {
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
                
                watchButtonTapped = true
            } else if node.name == "exitOutline" {
                exitButtonTapped = true
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        
        let objects = nodes(at: location)
        
        guard let watchButton = childNode(withName: "watchButton") as? SKSpriteNode else {return}
        
        guard let exitButton = childNode(withName: "exitOutline") else {return}
        
        if !objects.contains(watchButton) && watchButtonTapped {
            biggerButton(name: watchButton.name!, touchEndInside: false)
        } else if !objects.contains(exitButton) && exitButtonTapped {
            exitButtonTapped = false
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        
        let objects = nodes(at: location)
        
        if watchButtonTapped {
            biggerButton(name: "watchButton", touchEndInside: true)
        } else if exitButtonTapped {
            self.removeFromParent()
            
            NotificationCenter.default.post(name: NSNotification.Name("showStats"), object: nil)
        }
    }
    
    private func biggerButton(name: String, touchEndInside: Bool) {
        let node = childNode(withName: name)!
        
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
        
        if name == "watchButton" {
            watchButtonTapped = false
            if touchEndInside {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: {
                    [weak self] in
                    
                    NotificationCenter.default.post(name: NSNotification.Name("showRewardedAd"), object: nil)
                    
                    self?.removeFromParent()
                })
            }
        }
    }
}
